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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let settings = UserDefaults.standard
    var alertsEnabled: Bool = false

    var aboutWindowController: NSWindowController?
    var display: StatsDisplay = StatsDisplay()
    var notificator: Notificator = Notificator()
    var provider: DataProvider?

    @IBOutlet weak var menu: NSMenu?
    var statusBarItem: NSStatusItem?
    @IBOutlet weak var retryMenuItem: NSMenuItem?
    @IBOutlet weak var deltaMenuItem: NSMenuItem?
    @IBOutlet weak var regionsMenu: RegionsMenu?
    @IBOutlet weak var alertsMenuItem: NSMenuItem?

    var currentRegion: String = SpecialRegions.world.rawValue

    func setAlertsEnabled(enabled: Bool) {
        alertsEnabled = enabled
        notificator.isEnabled = enabled
        alertsMenuItem?.state = enabled ? .on : .off
        settings.set(enabled, forKey: "alerts")
    }

    @IBAction func alertsSwitchHandler(_ sender: NSMenuItem) {
        setAlertsEnabled(enabled: !alertsEnabled)
    }

    func onRegionChange (region: String) {
        self.currentRegion = region

        guard let stats = provider?.getStatsFor(region: currentRegion) else {
            return
        }

        self.display.showStats(region: stats)
    }

    func onUpdateSuccess (stats: CoronaStats) {
        guard let currentStats = provider?.getStatsFor(region: currentRegion) else {
            print("No stats data is available")
            return
        }

        regionsMenu?.updateList(regionsStats: stats.data)
        retryMenuItem?.isHidden = true
        display.showStats(region: currentStats)
        notificator.handle(stats: currentStats)
    }

    func onUpdateFailure (error: String?) {
        display.showError(message: error)
        retryMenuItem?.isHidden = false
    }

    @IBAction func retryHandler(_ sender: AnyObject) {
        display.showLoading()
        provider?.doUpdate()
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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        PFMoveToApplicationsFolderIfNecessary()

        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

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
        guard let button = statusBarItem?.button else {
            criticalError(message: "Menu bar item was not created. Try removing some menu bar items")
            return
        }

        statusBarItem?.menu = menu
        display.setComponents(statusItem: button, deltaItem: deltaMenuItem)

        setAlertsEnabled(enabled: settings.bool(forKey: "alerts"))

        regionsMenu.onRegionChange(callback: onRegionChange)
        provider = DataProvider(onSuccess: onUpdateSuccess, onError: onUpdateFailure)

        let prefferedRegion = settings.string(forKey: "country")
        regionsMenu.setCurrent(region: prefferedRegion ?? SpecialRegions.world.rawValue)

        provider?.doUpdate()
        provider?.startTimer()
    }
}
