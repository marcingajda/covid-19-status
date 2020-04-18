//
//  RegionsMenu.swift
//  Covid-19 Status
//
//  Created by Marcin Gajda on 01/04/2020.
//  Copyright © 2020 Marcin Gajda. All rights reserved.
//

import Cocoa

enum SpecialRegions: String {
    case world = "World"
}

class RegionsMenu: NSMenu {
    var observers: [NSObjectProtocol] = []
    var settings = UserDefaults.standard
    var messenger = Messenger.shared

    var currentRegion: String
    var regions: [String] = []
    var regionChangeCallback: ((String) -> Void)?

    required init(coder: NSCoder) {
        currentRegion = settings.selectedRegion
        super.init(coder: coder)

        observers = [
            messenger.onSelectedRegionChange { region in
                self.setCurrent(region: region)
            }
        ]
    }

    func onRegionChange(callback: @escaping (String) -> Void) {
        regionChangeCallback = callback
    }

    func setCurrent(region: String) {
        findItem(byName: currentRegion)?.state = .off
        findItem(byName: region)?.state = .on
        currentRegion = region
    }

    func sortRegionsStats(data: [RegionStats]) -> [RegionStats] {
        return data.sorted(by: {
            let name1 = NSLocalizedString($0.country, comment: "")
            let name2 = NSLocalizedString($1.country, comment: "")

            return name1.localizedCompare(name2) == .orderedAscending
        })
    }

    func updateList(withStats: [RegionStats]) {
        if regions.count == withStats.count {
            return
        }

        regions.removeAll()

        for region in sortRegionsStats(data: withStats) {
            regions.append(region.country)
        }

        buildMenu()
    }

    @objc func changeRegionHandler(sender: NSMenuItem) {
        guard let region = sender.representedObject as? String else {
            ErrorHandler.standard.critical(withMessage: "Button returned not a string")
            return
        }

        setCurrent(region: region)
        Messenger.shared.dispatchSelectedRegion(region: region)
    }

    func findItem(byName: String) -> NSMenuItem? {
        return item(withTitle: NSLocalizedString(byName, comment: ""))
    }

    func buildMenuItem(withName: String) -> NSMenuItem {
        let regionItem = NSMenuItem()
        regionItem.title = NSLocalizedString(withName, comment: "menu")
        regionItem.action = #selector(changeRegionHandler(sender:))
        regionItem.target = self
        regionItem.representedObject = withName
        return regionItem
    }

    func buildMenu() {
        self.removeAllItems()

        addItem(buildMenuItem(withName: SpecialRegions.world.rawValue))
        addItem(NSMenuItem.separator())

        for region in regions {
            let regionItem = buildMenuItem(withName: region)
            addItem(regionItem)

            #if DEBUG
            if Locale.current.languageCode != "en" {
                if NSLocalizedString(region, value: "__missing", comment: "menu") == "__missing" {
                    print("MISSING TRANS:", regionItem.title)
                }
            }
            #endif
        }

        findItem(byName: currentRegion)?.state = .on
    }
}
