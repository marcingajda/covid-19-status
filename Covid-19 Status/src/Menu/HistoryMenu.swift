//
//  RegionsHistory.swift
//  Covid-19 Status
//
//  Created by Marcin Gajda on 12/04/2020.
//  Copyright © 2020 Marcin Gajda. All rights reserved.
//

import Cocoa

class HistoryMenu: NSMenu {
    var observers: [NSObjectProtocol] = []
    var settings = UserDefaults.standard
    var messenger = Messenger.shared

    var maxHistorySize = 30

    // order: [oldest, ..., newest]
    var historyItems: [String] = UserDefaults.standard.history

    // order: [newest, ..., oldest]
    var reversedHistoryItems: [String] {
        return historyItems.reversed()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        buildMenu()

        observers = [
            messenger.onSelectedRegionChange { region in
                self.onRegionChange(region: region)
            },
            messenger.onHistorySizeChange { _ in
                self.buildMenu()
            }
        ]
    }

    func onRegionChange(region: String) {
        if let index = historyItems.firstIndex(of: region) {
            historyItems.remove(at: index)
        } else if historyItems.count == maxHistorySize {
            historyItems.removeFirst()
        }

        historyItems.append(region)
        settings.saveHistory(list: historyItems)
        buildMenu()
    }

    func findItem(byName name: String) -> NSMenuItem? {
        return item(withTitle: NSLocalizedString(name, comment: ""))
    }

    @objc func regionSelectedHandler(sender: NSMenuItem) {
        guard let region = sender.representedObject as? String else {
            ErrorHandler.standard.critical(withMessage: "Button returned not a string")
            return
        }
        Messenger.shared.dispatchSelectedRegion(region: region)
    }

    @objc func clearHistoryHandler(sender: NSMenuItem) {
        historyItems = []
        settings.saveHistory(list: [])
        buildMenu()
    }

    func buildEmptyMenuItem() -> NSMenuItem {
        let emptyItem = NSMenuItem()
        emptyItem.title = NSLocalizedString("(empty)", comment: "")
        emptyItem.isEnabled = false

        return emptyItem
    }

    func buildClearHistoryMenuItem() -> NSMenuItem {
        let clearHistoryItem = NSMenuItem()
        clearHistoryItem.title = NSLocalizedString("Clear history", comment: "")
        clearHistoryItem.action = #selector(clearHistoryHandler(sender:))
        clearHistoryItem.target = self

        return clearHistoryItem
    }

    func buildMenuItem(withName name: String) -> NSMenuItem {
        let regionItem = NSMenuItem()
        regionItem.title = NSLocalizedString(name, comment: "menu")
        regionItem.action = #selector(regionSelectedHandler(sender:))
        regionItem.target = self
        regionItem.representedObject = name

        return regionItem
    }

    func buildMenu() {
        removeAllItems()

        for (index, region) in reversedHistoryItems.enumerated() {
            if index == settings.historySize {
                break
            }
            addItem(buildMenuItem(withName: region))
        }

        if reversedHistoryItems.count == 0 {
            addItem(buildEmptyMenuItem())
        } else {
            addItem(NSMenuItem.separator())
            addItem(buildClearHistoryMenuItem())
        }
    }
}
