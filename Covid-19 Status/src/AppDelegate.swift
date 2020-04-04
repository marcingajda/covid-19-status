//
//  AppDelegate.swift
//  Covid-19 Poland
//
//  Created by Marcin Gajda on 22/03/2020.
//  Copyright © 2020 Marcin Gajda. All rights reserved.
//

import Cocoa
import Foundation
import LetsMove

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

    var display: StatsDisplay = StatsDisplay()

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

    @IBAction func alertsSwitchHandler(_ sender: NSMenuItem) {
        setAlertsEnabled(enabled: !alertsEnabled)
    }

    @objc func doUpdate() {
        print("Updating data")
        fetchData { coronaStats, error in
            guard let coronaStats = coronaStats else {
                self.display.showError(message: error)
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

            self.display.showStats(region: currentStats)
            self.notificator.handle(stats: currentStats)
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        PFMoveToApplicationsFolderIfNecessary()

        statusBarItem =  NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let statusBarItem = statusBarItem else {
            criticalError(message: "The app UI is broken (status bar item)")
            return
        }

        guard let menu = menu else {
            criticalError(message: "The app UI is broken (menu)")
            return
        }

        guard let regionsMenu = regionsMenu else {
            criticalError(message: "The app UI is broken (regions menu)")
            return
        }

        guard let deltaMenuItem = deltaMenuItem else {
            criticalError(message: "The app UI is broken (delta menu item)")
            return
        }

        guard let button = statusBarItem.button else {
            criticalError(message: "Menu bar item was not created. Try removing some menu bar items")
            return
        }

        statusBarItem.menu = menu
        display.setComponents(statusItem: button, deltaItem: deltaMenuItem)

        regionsMenu.onRegionChange { region in
            self.currentRegion = region
            guard let stats = self.getCurrentRegionStats() else {
                return
            }
            self.display.showStats(region: stats)
        }

        regionsMenu.setCurrent(region: settings.string(forKey: "country") ?? WORLD)
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
            criticalError(message: "The About window failed", terminate: false)
            return
        }

        aboutWindowController.showWindow(self)
    }

    @IBAction func retryHandler(_ sender: AnyObject) {
        display.showLoading()
        doUpdate()
    }
}
