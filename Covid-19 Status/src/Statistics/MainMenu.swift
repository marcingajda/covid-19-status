//
//  MainMenu.swift
//  Covid-19 Status
//
//  Created by Marcin Gajda on 13/04/2020.
//  Copyright © 2020 Marcin Gajda. All rights reserved.
//

import Cocoa

enum MainMenuItem: Int {
    case delta = 0
    case retry = 1
    case regions = 2
    case history = 3
    case alerts = 4
    case preferences = 5
    case about = 6
    case quit = 7
}

class MainMenu: NSMenu {
    var settings = UserDefaults.standard
    var messenger = Messenger.shared
    var observers: [NSObjectProtocol] = []

    var aboutWindowController: NSWindowController?
    var preferencesWindowController: NSWindowController?

    required init(coder: NSCoder) {
        super.init(coder: coder)
        addActions()
        setAlertsStatus(enabled: settings.alertsEnabled)

        observers = [
            messenger.onAlertsStatusChange { enabled in
                self.setAlertsStatus(enabled: enabled)
            },
            messenger.onHistorySizeChange { _ in
                self.updateHistorySize()
            }
        ]
    }

    func findItem(tag: MainMenuItem) -> NSMenuItem? {
        guard let founding = item(withTag: tag.rawValue) else {
            criticalError(message: "item not found", terminate: false)
            return nil
        }
        return founding
    }

    var regionsSubmenu: RegionsMenu? {
        guard let menu = findItem(tag: .regions)?.submenu else {
            criticalError(message: "Submenu not found (regions)")
            return nil
        }

        guard let regionsMenu: RegionsMenu = menu as? RegionsMenu else {
            criticalError(message: "Failed to convert regions menu")
            return nil
        }

        return regionsMenu
    }

    var historySubmenu: HistoryMenu? {
        guard let menu = findItem(tag: .regions)?.menu as? HistoryMenu? else {
            criticalError(message: "Submenu not found (history)", terminate: false)
            return nil
        }
        return menu
    }

    func showRetry(show: Bool) {
        guard let item = findItem(tag: .retry) else {
            criticalError(message: "Missing menu item (retry)")
            return
        }
        item.isEnabled = show
    }

    func setAlertsStatus(enabled: Bool) {
        guard let item = findItem(tag: .alerts) else {
            criticalError(message: "Missing menu item (alerts)")
            return
        }
        item.state = enabled ? .on : .off
    }

    func addActions() {
        guard let aboutItem = findItem(tag: .about) else {
            criticalError(message: "Missing menu item (about)")
            return
        }
        guard let preferencesItem = findItem(tag: .preferences) else {
            criticalError(message: "Missing menu item (about)")
            return
        }
        guard let alertsItem = findItem(tag: .alerts) else {
            criticalError(message: "Missing menu item (alerts)")
            return
        }

        aboutItem.target = self
        aboutItem.action = #selector(showAboutWindow(sender:))

        preferencesItem.target = self
        preferencesItem.action = #selector(showPreferencesWindow(sender:))

        alertsItem.target = self
        alertsItem.action = #selector(onAlertsStatusChange(sender:))
    }

    @objc func onAlertsStatusChange(sender: NSMenuItem) {
        let newState = sender.state == .off
        Messenger.shared.dispatchAlertsStatus(enabled: newState)
    }

    @objc func showAboutWindow(sender: NSMenuItem) {
        WindowManager.standard.open("About Window Controller")
    }

    @objc func showPreferencesWindow(sender: NSMenuItem) {
        WindowManager.standard.open("Preferences Window Controller")
    }

    func updateHistorySize() {
        findItem(tag: .history)?.isHidden = settings.historySize == 0
    }
}
