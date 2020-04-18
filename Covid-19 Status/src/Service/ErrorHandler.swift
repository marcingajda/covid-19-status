//
//  ErrorHandler.standard.critical.swift
//  Covid-19 Status
//
//  Created by Marcin Gajda on 29/03/2020.
//  Copyright © 2020 Marcin Gajda. All rights reserved.
//

import Foundation
import Cocoa

class ErrorHandler {
    static var standard = ErrorHandler()

    func critical(withMessage message: String, terminate: Bool = true) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = NSLocalizedString("An error occured", comment: "")
            alert.informativeText = message
            alert.alertStyle = .critical
            alert.addButton(withTitle: "OK")
            alert.runModal()

            if terminate {
                NSApp.terminate(nil)
            }
        }
    }
}
