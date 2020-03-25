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
    @IBOutlet weak var sourceLink: NSTextField!
    @IBOutlet weak var version: NSTextField!

    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let versionNumber = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!;
        version.stringValue = String(format: NSLocalizedString("version %@", comment: ""), versionNumber);
        
        let sourceClick = NSClickGestureRecognizer(target: self, action: #selector(self.sourceLinkHandler(sender:)));
        sourceLink.addGestureRecognizer(sourceClick);
        
        NSApplication.shared.activate(ignoringOtherApps: true);
    }
    
    @IBAction func sourceLinkHandler(sender: NSClickGestureRecognizer) {
        NSWorkspace.shared.open(URL(string:sourceLink.stringValue )!);
    }
    
    @IBAction func dismissAboutWindow(_ sender: NSButton) {
        view.window?.close();
    }
}
