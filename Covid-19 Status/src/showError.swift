//
//  showError.swift
//  Covid-19 Status
//
//  Created by Marcin Gajda on 29/03/2020.
//  Copyright © 2020 Marcin Gajda. All rights reserved.
//

import Foundation
import Cocoa

func showError(text: String) {
    let alert = NSAlert()
    alert.messageText = NSLocalizedString("An error occured", comment: "")
    alert.informativeText = text
    alert.alertStyle = .critical
    alert.addButton(withTitle: "OK")
    alert.runModal()
}
