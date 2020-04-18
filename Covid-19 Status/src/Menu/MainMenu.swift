//
//  MainMenu.swift
//  Covid-19 Status
//
//  Created by Marcin Gajda on 12/04/2020.
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
    var observers: [NSObjectProtocol] = []

    required init(coder: NSCoder) {
        super.init(coder: coder)
        addActions()

        showHistory(show: settings.historySize > 0)
        setAlertsStatus(enabled: settings.alertsEnabled)

        observers = [
            Messenger.shared.onHistorySizeChange { size in
                self.showHistory(show: size > 0)
            }
        ]
    }

    func findItem(byTag: MainMenuItem) -> NSMenuItem? {
        guard let founding = item(withTag: byTag.rawValue) else {
            ErrorHandler.standard.critical(withMessage: "The app UI is broken (main menu)")
            return nil
        }
        return founding
    }

    func addActions() {
        findItem(byTag: .alerts)?.target = self
        findItem(byTag: .alerts)?.action = #selector(alertsStatusChangeHandler(sender:))

        findItem(byTag: .retry)?.target = self
        findItem(byTag: .retry)?.action = #selector(fetchRequestHandler(sender:))

        findItem(byTag: .preferences)?.target = self
        findItem(byTag: .preferences)?.action = #selector(openPreferencesHandler(sender:))

        findItem(byTag: .about)?.target = self
        findItem(byTag: .about)?.action = #selector(openAboutHandler(sender:))
    }

    var regionsSubmenu: RegionsMenu? {
        guard let menuItem = findItem(byTag: .regions) else {
            ErrorHandler.standard.critical(withMessage: "The app UI is broken (regions menu item)")
            return nil
        }

        guard let submenu = menuItem.submenu as? RegionsMenu else {
            ErrorHandler.standard.critical(withMessage: "The app UI is broken (regions menu)")
            return nil
        }
        return submenu
    }

    var historySubmenu: HistoryMenu? {
        guard let menuItem = findItem(byTag: .history) else {
            ErrorHandler.standard.critical(withMessage: "The app UI is broken (history menu item)")
            return nil
        }
        guard let submenu = menuItem.submenu as? HistoryMenu else {
            ErrorHandler.standard.critical(withMessage: "The app UI is broken (history menu)")
            return nil
        }
        return submenu
    }

    @objc func openPreferencesHandler(sender: NSMenuItem) {
        WindowManager.standard.open("Preferences Window Controller")
    }

    @objc func openAboutHandler(sender: NSMenuItem) {
        WindowManager.standard.open("About Window Controller")
    }

    @objc func alertsStatusChangeHandler(sender: NSMenuItem) {
        let newStatus = !settings.alertsEnabled
        setAlertsStatus(enabled: newStatus)
        Messenger.shared.dispatchAlertsStatus(enabled: newStatus)
    }

    @objc func fetchRequestHandler(sender: NSMenuItem) {
        Messenger.shared.dispatchFetchRequest()
    }

    func setAlertsStatus(enabled: Bool) {
        findItem(byTag: .alerts)?.state = enabled ? .on : .off
    }

    func showRetry(show: Bool) {
        findItem(byTag: .retry)?.isHidden = !show
    }

    func showHistory(show: Bool) {
        findItem(byTag: .history)?.isHidden = !show
    }
}
