//
//  StatsDisplay.swift
//  Covid-19 Status
//
//  Created by Marcin Gajda on 03/04/2020.
//  Copyright © 2020 Marcin Gajda. All rights reserved.
//

import Foundation
import Cocoa

class StatsDisplay: NSObject {
    var statusDisplay: NSStatusBarButton?
    var deltaDisplay: NSMenuItem?
    var currentStats: RegionStats?

    var settings = UserDefaults.standard

    func setComponents(statusItem: NSStatusBarButton, deltaItem: NSMenuItem) {
        statusDisplay = statusItem
        deltaDisplay = deltaItem
    }

    func show(stats: RegionStats) {
        currentStats = stats
        renderStats()
    }

    func renderStats() {
        guard let stats = currentStats else {
            return
        }

        let formatter = StatsFormatter(stats: stats, method: settings.formatMethod)

        DispatchQueue.main.async {
            self.statusDisplay?.attributedTitle = formatter.getRegionStatus()
            self.statusDisplay?.toolTip = formatter.getTooltip()
            self.deltaDisplay?.title = formatter.getRegionDelta()
        }
    }

    func showError(withMessage message: String?) {
        let error = message ?? NSLocalizedString("unknown cause", comment: "")

        DispatchQueue.main.async {
            self.statusDisplay?.attributedTitle = menuBarTextFormatter(
                label: NSLocalizedString("COVID-19 Status: Error", comment: "")
            )
            self.statusDisplay?.toolTip = error
            self.deltaDisplay?.title = error
        }
    }

    func showLoading() {
        DispatchQueue.main.async {
            self.statusDisplay?.attributedTitle = menuBarTextFormatter(
                label: NSLocalizedString("Loading...", comment: "")
            )
            self.statusDisplay?.toolTip = NSLocalizedString("COVID-19 Status", comment: "")
            self.deltaDisplay?.title = NSLocalizedString("Loading...", comment: "")
        }
    }
}
