//
//  AboutViewController.swift
//  Covid-19 Status
//
//  Created by Marcin Gajda on 25/03/2020.
//  Copyright © 2020 Marcin Gajda. All rights reserved.
//

import Cocoa
import Foundation

class AboutViewController: NSViewController {
    @IBOutlet weak var sourceLink: NSTextField?
    @IBOutlet weak var version: NSTextField?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let version = version else {
            ErrorHandler.standard.critical(withMessage: "The app UI is broken (version)")
            return
        }

        guard let sourceLink = sourceLink else {
            ErrorHandler.standard.critical(withMessage: "The app UI is broken (source link)")
            return
        }

        let versionNumber = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)

        version.stringValue = String(
            format: NSLocalizedString("version %@", comment: ""),
            versionNumber ?? "??"
        )

        let sourceClickHandler = NSClickGestureRecognizer(
            target: self,
            action: #selector(self.sourceLinkHandler(sender:))
        )

        sourceLink.addGestureRecognizer(sourceClickHandler)

        NSApplication.shared.activate(ignoringOtherApps: true)
    }

    @IBAction func sourceLinkHandler(sender: NSClickGestureRecognizer) {
        guard let link = sourceLink?.stringValue else {
            ErrorHandler.standard.critical(withMessage: "Can't open the URL address.")
            return
        }

        guard let urlAddress = URL(string: link) else {
            ErrorHandler.standard.critical(withMessage: "Can't open the URL address.")
            return
        }

        NSWorkspace.shared.open(urlAddress)
    }

    @IBAction func dismissAboutWindow(_ sender: NSButton) {
        view.window?.close()
    }
}
