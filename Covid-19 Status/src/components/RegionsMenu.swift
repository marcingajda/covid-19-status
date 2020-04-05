//
//  RegionsMenu.swift
//  Covid-19 Status
//
//  Created by Marcin Gajda on 01/04/2020.
//  Copyright © 2020 Marcin Gajda. All rights reserved.
//

import Cocoa

class RegionsMenu: NSMenu {
    var regions: [String] = []
    var currentRegion: String = SpecialRegions.world.rawValue
    let settings = UserDefaults.standard
    var regionChangeCallback: ((String) -> Void)?

    func onRegionChange(callback: @escaping (String) -> Void) {
        regionChangeCallback = callback
    }

    func setCurrent(region: String) {
        print("Changing region:", region)

        findItem(name: currentRegion)?.state = .off
        findItem(name: region)?.state = .on

        currentRegion = region
        settings.set(region, forKey: "country")
        regionChangeCallback?(region)
    }

    func sortRegionsStats(data: [RegionStats]) -> [RegionStats] {
        return data.sorted(by: {
            let name1 = NSLocalizedString($0.country, comment: "")
            let name2 = NSLocalizedString($1.country, comment: "")

            return name1.localizedCompare(name2) == .orderedAscending
        })
    }

    func updateList(regionsStats: [RegionStats]) {
        if regions.count == regionsStats.count {
            return
        }

        regions.removeAll()

        for region in sortRegionsStats(data: regionsStats) {
            regions.append(region.country)
        }

        rebuildMenu()
    }

    @objc func changeRegionHandler(sender: NSMenuItem) {
        guard let region = sender.representedObject as? String else {
            criticalError(message: "Button returned not a string")
            return
        }

        setCurrent(region: region)
    }

    func findItem(name: String) -> NSMenuItem? {
        return item(withTitle: NSLocalizedString(name, comment: ""))
    }

    func rebuildMenu() {
        self.removeAllItems()

        let worldItem = NSMenuItem()
        worldItem.title = NSLocalizedString(SpecialRegions.world.rawValue, comment: "menu")
        worldItem.action = #selector(changeRegionHandler(sender:))
        worldItem.target = self
        worldItem.representedObject = SpecialRegions.world.rawValue
        self.addItem(worldItem)

        addItem(NSMenuItem.separator())

        for region in regions {
            let regionItem = NSMenuItem()
            regionItem.title = NSLocalizedString(region, comment: "menu")
            regionItem.action = #selector(changeRegionHandler(sender:))
            regionItem.target = self
            regionItem.representedObject = region
            addItem(regionItem)

            #if DEBUG
            if Locale.current.languageCode != "en" {
                if NSLocalizedString(region, value: "__mising__", comment: "menu") == "__mising__" {
                    print("MISSING TRANS:", regionItem.title)
                }
            }
            #endif
        }

        findItem(name: currentRegion)?.state = .on
    }
}
