//
//  openWindow.swift
//  Covid-19 Status
//
//  Created by Marcin Gajda on 13/04/2020.
//  Copyright © 2020 Marcin Gajda. All rights reserved.
//

import Foundation
import Cocoa

class WindowManager {
    static var standard = WindowManager()

    var controllers: [String: NSWindowController] = [:]

    func open(_ storyboardId: String) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)

        if let windowController = controllers[storyboardId] {
            windowController.close()
        }

        controllers[storyboardId] = storyboard.instantiateController(
            withIdentifier: storyboardId
        ) as? NSWindowController

        guard let windowController = controllers[storyboardId] else {
            ErrorHandler.standard.critical(withMessage: "Creating window failed")
            return
        }

        windowController.showWindow(self)
    }
}
