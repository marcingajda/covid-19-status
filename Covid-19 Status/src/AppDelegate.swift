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

    var appController: AppController?

    var statusBarItem: NSStatusItem?
    @IBOutlet weak var mainMenu: MainMenu?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        PFMoveToApplicationsFolderIfNecessary()

        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let statusBarItem = statusBarItem else {
            ErrorHandler.standard.critical(withMessage: "The app UI is broken (status bar item)")
            return
        }

        guard let menu = mainMenu else {
            ErrorHandler.standard.critical(withMessage: "The app UI is broken (menu)")
            return
        }

        guard let button = statusBarItem.button else {
            ErrorHandler.standard.critical(withMessage: "Menu bar item was not created. Not enough space?")
            return
        }

        statusBarItem.menu = menu
        appController = AppController(statusButton: button, statusMenu: menu)
    }
}
