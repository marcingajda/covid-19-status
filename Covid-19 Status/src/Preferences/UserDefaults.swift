//
//  Settings.swift
//  Covid-19 Status
//
//  Created by Marcin Gajda on 11/04/2020.
//  Copyright © 2020 Marcin Gajda. All rights reserved.
//

import Foundation

extension UserDefaults {
    func exists(key: String) -> Bool {
        return object(forKey: key) != nil
    }

    // selected region

    var selectedRegion: String {
        if let region = string(forKey: SettingsKey.selectedRegion.rawValue) {
            return region
        }
        return SpecialRegions.world.rawValue
    }

    func saveSelectedRegion(region: String) {
        print("Changing region:", region)
        set(region, forKey: SettingsKey.selectedRegion.rawValue)
    }

    // fetch interval

    var fetchInterval: Int {
        if exists(key: SettingsKey.fetchInterval.rawValue) {
            return integer(forKey: SettingsKey.fetchInterval.rawValue)
        }
        return PreferencesOptions.defaultFetchInterval
    }

    func saveFetchInterval(interval: Int) {
        print("Changing interval:", interval)
        set(interval, forKey: SettingsKey.fetchInterval.rawValue)
    }

    // history size

    var historySize: Int {
        if exists(key: SettingsKey.historySize.rawValue) {
            return integer(forKey: SettingsKey.historySize.rawValue)
        }
        return PreferencesOptions.defaultHistorySize
    }

    func setHistorySize(count: Int) {
        print("Changing history size:", count)
        set(count, forKey: SettingsKey.historySize.rawValue)
    }

    // history

    var history: [String] {
        guard let list = array(forKey: SettingsKey.history.rawValue) else {
            return []
        }
        return list.map { item in
            return String(describing: item)
        }
    }

    func saveHistory(list: [String]) {
        set(list, forKey: SettingsKey.history.rawValue)
    }

    // alerts

    var alertsEnabled: Bool {
        if exists(key: SettingsKey.alertsEnabled.rawValue) {
            return bool(forKey: SettingsKey.alertsEnabled.rawValue)
        }
        return PreferencesOptions.defaultAlertsStatus
    }

    func saveAlertsEnabled(enabled: Bool) {
        print("Setting alerts enabled status:", enabled)
        set(enabled, forKey: SettingsKey.alertsEnabled.rawValue)
    }

    // format method

    var formatMethod: StatsFormatMethod {
        if exists(key: SettingsKey.formatMethod.rawValue) {
            if let method = StatsFormatMethod(rawValue: string(forKey: SettingsKey.formatMethod.rawValue) ?? "long") {
                return method
            }
            return PreferencesOptions.defaultFormatMethod
        }
        return PreferencesOptions.defaultFormatMethod
    }

    func saveFormatMethod(method: StatsFormatMethod) {
        print("Setting format method:", method)
        set(method.rawValue, forKey: SettingsKey.formatMethod.rawValue)
    }
}
