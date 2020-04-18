//
//  AppController.swift
//  Covid-19 Status
//
//  Created by Marcin Gajda on 13/04/2020.
//  Copyright © 2020 Marcin Gajda. All rights reserved.
//

import Cocoa

class AppController {
    let settings = UserDefaults.standard
    var observers: [NSObjectProtocol] = []

    var statusButton: NSStatusBarButton
    var statusMenu: MainMenu
    var provider: DataProvider?

    var display: StatsDisplay = StatsDisplay()
    var notificator: Notificator = Notificator()

    init(statusButton: NSStatusBarButton, statusMenu: MainMenu) {
        self.statusButton = statusButton
        self.statusMenu = statusMenu

        guard let deltaItem = statusMenu.findItem(byTag: .delta) else {
            ErrorHandler.standard.critical(withMessage: "The app UI is broken (delta menu item)")
            return
        }

        display.setComponents(statusItem: statusButton, deltaItem: deltaItem)
        onAlertsStatusChange(enabled: settings.alertsEnabled)
        provider = DataProvider(onSuccess: onUpdateSuccess, onError: onUpdateFailure)

        observers = [
            Messenger.shared.onSelectedRegionChange { region in
                self.onRegionChange(region: region)
            },
            Messenger.shared.onFetchIntervalChange { _ in
                self.provider?.doUpdate()
                self.provider?.setupTimer()
            },
            Messenger.shared.onAlertsStatusChange { status in
                self.onAlertsStatusChange(enabled: status)
            },
            Messenger.shared.onFetchRequest {
                self.display.showLoading()
                self.provider?.doUpdate()
            },
            Messenger.shared.onFormatMethodChange { _ in
                self.display.renderStats()
            }
        ]

        provider?.doUpdate()
        provider?.setupTimer()
    }

    func onUpdateSuccess(stats: CoronaStats) {
        guard let currentStats = provider?.getStats(forRegion: settings.selectedRegion) else {
            print("No stats data is available")
            return
        }

        statusMenu.regionsSubmenu?.updateList(withStats: stats.data)
        statusMenu.showRetry(show: false)

        display.show(stats: currentStats)
        notificator.handle(stats: currentStats)
    }

    func onUpdateFailure (error: String?) {
        display.showError(withMessage: error)
        statusMenu.showRetry(show: true)
    }

    func onAlertsStatusChange(enabled: Bool) {
        notificator.isEnabled = enabled
        if enabled != settings.alertsEnabled {
            settings.saveAlertsEnabled(enabled: enabled)
        }
    }

    func onRegionChange(region: String) {
        guard let stats = provider?.getStats(forRegion: region) else {
            return
        }
        display.show(stats: stats)
        notificator.handle(stats: stats)
        settings.saveSelectedRegion(region: region)
    }
}
