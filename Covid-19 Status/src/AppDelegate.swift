//
//  AppDelegate.swift
//  Covid-19 Poland
//
//  Created by Marcin Gajda on 22/03/2020.
//  Copyright © 2020 Marcin Gajda. All rights reserved.
//

import Cocoa
import Foundation

var WORLD = "World"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let settings = UserDefaults.standard

    var statusBarItem: NSStatusItem?
    var button: NSStatusBarButton?
    var notificator: Notificator = Notificator()
    var aboutWindowController: NSWindowController?

    var lastCoronaStats: CoronaStats?
    var timer: Timer?

    @IBOutlet weak var menu: NSMenu?
    @IBOutlet weak var regionsMenu: RegionsMenu?
    @IBOutlet weak var retryMenuItem: NSMenuItem?
    @IBOutlet weak var deltaMenuItem: NSMenuItem?
    @IBOutlet weak var alertsMenuItem: NSMenuItem?

    var currentRegion: String = WORLD
    var alertsEnabled: Bool = false

    func setAlertsEnabled(enabled: Bool) {
        alertsEnabled = enabled
        notificator.isEnabled = enabled
        alertsMenuItem?.state = enabled ? .on : .off
        settings.set(enabled, forKey: "alerts")
    }

    func getCurrentRegionStats() -> RegionStats? {
        guard let lastCoronaStats = lastCoronaStats else {
            return nil
        }

        return currentRegion == WORLD
            ? lastCoronaStats.worldStats
            : lastCoronaStats.data.first(where: { (countryStats) -> Bool in
                countryStats.country == self.currentRegion
            }) ?? lastCoronaStats.worldStats
    }

    func refreshView(stats: RegionStats) {
        let formatter = StatsFormatter(stats: stats)

        DispatchQueue.main.async {
            guard let deltaMenuItem = self.deltaMenuItem else {
                showError(text: "The 'deltaMenuItem' element does not exists")
                return
            }

            guard let button = self.button else {
                showError(text: "The 'button' element does not exists")
                return
            }

            button.attributedTitle = formatter.getRegionStatus()
            deltaMenuItem.title = formatter.getRegionDelta()
            button.toolTip = formatter.getTooltip()
        }
    }

    @IBAction func alertsSwitchHandler(_ sender: NSMenuItem) {
        setAlertsEnabled(enabled: !alertsEnabled)
    }

    func showErrorState(message: String) {
        DispatchQueue.main.async {
            guard let deltaMenuItem = self.deltaMenuItem else {
                showError(text: "The app UI is broken (delta menu item)")
                NSApp.terminate(nil)
                return
            }

            guard let button = self.button else {
                showError(text: "The app UI is broken (button)")
                NSApp.terminate(nil)
                return
            }

            button.attributedTitle = menuBarTextFormatter(
                label: NSLocalizedString("COVID-19 Status: Error", comment: "")
            )
            deltaMenuItem.title = message
            button.toolTip = message
        }
    }

    @objc func doUpdate() {
        print("Updating data")
        fetchData { coronaStats, error in
            guard let coronaStats = coronaStats else {
                self.showErrorState(message: error ?? NSLocalizedString("unknown cause", comment: ""))
                self.retryMenuItem?.isHidden = false
                return
            }

            if self.regionsMenu?.items.count != coronaStats.data.count + 2 {
                print("Updating region menu")
                self.regionsMenu?.updateList(regionsStats: coronaStats.data)
            }

            self.retryMenuItem?.isHidden = true
            self.lastCoronaStats = coronaStats

            guard let currentStats = self.getCurrentRegionStats() else {
                print("No stats data is available")
                return
            }

            self.refreshView(stats: currentStats)
            self.notificator.handle(stats: currentStats)
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)

        guard let statusBarItem = statusBarItem else {
            showError(text: "The app UI is broken (status bar item)")
            NSApp.terminate(nil)
            return
        }

        guard statusBarItem.button != nil else {
            showError(text: "Menu bar item was not created. Try removing some menu bar items")
            NSApp.terminate(nil)
            return
        }

        guard let menu = menu else {
            showError(text: "The app UI is broken (menu)")
            NSApp.terminate(nil)
            return
        }

        guard let regionsMenu = regionsMenu else {
            showError(text: "The app UI is broken (regions menu)")
            NSApp.terminate(nil)
            return
        }

        button = statusBarItem.button
        statusBarItem.menu = menu

        regionsMenu.onRegionChange { region in
            self.currentRegion = region

            guard let stats = self.getCurrentRegionStats() else {
                return
            }

            self.refreshView(stats: stats)
        }

        regionsMenu.setCurrent(
            region: settings.string(forKey: "country") ?? WORLD
        )

        setAlertsEnabled(enabled: settings.bool(forKey: "alerts"))

        doUpdate()

        timer = Timer.scheduledTimer(
            timeInterval: 3 * 60,
            target: self,
            selector: #selector(self.doUpdate),
            userInfo: nil,
            repeats: true
        )
    }

    @IBAction func showAboutWindow(_ sender: AnyObject) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)

        if let aboutWindowController = aboutWindowController {
            aboutWindowController.close()
        }

        aboutWindowController = storyboard.instantiateController(
            withIdentifier: "About Window Controller"
        ) as? NSWindowController

        guard let aboutWindowController = aboutWindowController else {
            showError(text: "The About window failed")
            return
        }

        aboutWindowController.showWindow(self)
    }

    @IBAction func retryHandler(_ sender: AnyObject) {
        doUpdate()
    }
}
