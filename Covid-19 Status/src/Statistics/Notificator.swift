//
//  Notificator.swift
//  Covid-19 Status
//
//  Created by Marcin Gajda on 24/03/2020.
//  Copyright © 2020 Marcin Gajda. All rights reserved.
//

import Foundation

class Notificator {
    var lastUpdates: [String: RegionStats] = [:]
    var isEnabled = false
    var settings = UserDefaults.standard

    func showNotification(stats: RegionStats) {
        let formatter = StatsFormatter(stats: stats, method: settings.formatMethod)
        let regionName = NSLocalizedString(stats.country, comment: "")

        let notification = NSUserNotification()
        notification.identifier = formatter.getUniqueId()
        notification.title = String(format: NSLocalizedString("COVID-19 Update (%@)", comment: ""), regionName)
        notification.subtitle = formatter.getRegionStatus().string
        notification.informativeText = formatter.getRegionDelta()
        notification.soundName = NSUserNotificationDefaultSoundName

        let notificationCenter = NSUserNotificationCenter.default
        notificationCenter.deliver(notification)
    }

    func isUpdated(nextStats: RegionStats) -> Bool {
        guard let previousStats = lastUpdates[nextStats.country] else {
            return false
        }

        return (
            previousStats.cases != nextStats.cases ||
            previousStats.deaths != nextStats.deaths ||
            previousStats.recovered != nextStats.recovered
        )
    }

    func handle(stats: RegionStats) {
        if isUpdated(nextStats: stats) && isEnabled {
            showNotification(stats: stats)
        }

        lastUpdates[stats.country] = stats
    }
}
