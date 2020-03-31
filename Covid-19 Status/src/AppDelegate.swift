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
    @IBOutlet weak var regionMenu: NSMenu?
    @IBOutlet weak var retryMenuItem: NSMenuItem?
    @IBOutlet weak var deltaMenuItem: NSMenuItem?
    @IBOutlet weak var alertsMenuItem: NSMenuItem?

    var currentRegion: String = WORLD
    var alertsEnabled: Bool = false

    func findRegionMenuItem(regionName: String) -> NSMenuItem? {
        return regionMenu?.item(withTitle: NSLocalizedString(regionName, comment: ""))
    }

    func setCurrentRegion(newRegion: String) {
        findRegionMenuItem(regionName: currentRegion)?.state = .off
        findRegionMenuItem(regionName: newRegion)?.state = .on

        currentRegion = newRegion
        settings.set(newRegion, forKey: "country")
    }

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

    func sortCountries(data: [RegionStats]) -> [RegionStats] {
        return data.sorted(by: {
            let name1 = NSLocalizedString($0.country, comment: "")
            let name2 = NSLocalizedString($1.country, comment: "")

            return name1.localizedCompare(name2) == .orderedAscending
        })
    }

    func updateRegionMenu(coronaStats: CoronaStats) {
        self.regionMenu?.removeAllItems()

        let worldItem = NSMenuItem()
        worldItem.title = NSLocalizedString(WORLD, comment: "menu")
        worldItem.action = #selector(self.changeRegionHandler(sender:))
        worldItem.representedObject = WORLD
        self.regionMenu?.addItem(worldItem)

        self.regionMenu?.addItem(NSMenuItem.separator())

        for countryStats in sortCountries(data: coronaStats.data) {
            //print(countryStats.country)
            let countryItem = NSMenuItem()
            countryItem.title = NSLocalizedString(countryStats.country, comment: "menu")
            countryItem.action = #selector(self.changeRegionHandler(sender:))
            countryItem.representedObject = countryStats.country
            self.regionMenu?.addItem(countryItem)
        }

        findRegionMenuItem(regionName: currentRegion)?.state = .on
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

    @objc func changeRegionHandler(sender: NSMenuItem) {
        guard let region = sender.representedObject as? String else {
            showError(text: "Button returned not a string")
            return
        }

        setCurrentRegion(newRegion: region)

        guard let currentStats = self.getCurrentRegionStats() else {
            print("No stats data available")
            return
        }

        refreshView(stats: currentStats)
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

            if self.regionMenu?.items.count != coronaStats.data.count + 2 {
                print("Updating region menu")
                self.updateRegionMenu(coronaStats: coronaStats)
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

        button = statusBarItem.button
        statusBarItem.menu = menu

        setCurrentRegion(newRegion: settings.string(forKey: "country") ?? WORLD)
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
