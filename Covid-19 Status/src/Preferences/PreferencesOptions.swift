//
//  PreferencesOptions.swift
//  Covid-19 Status
//
//  Created by Marcin Gajda on 18/04/2020.
//  Copyright © 2020 Marcin Gajda. All rights reserved.
//

import Foundation
import Cocoa

class SelectIntegerOption: NSObject {
    @objc dynamic var name: String
    @objc dynamic var value: Int

    init(name: String, value: Int) {
        self.name = name
        self.value = value
    }
}

class PreferencesOptions {
    static var fetchIntervals = [
        SelectIntegerOption(name: NSLocalizedString("1 minute", comment: ""), value: 1),
        SelectIntegerOption(name: NSLocalizedString("3 minute", comment: ""), value: 3),
        SelectIntegerOption(name: NSLocalizedString("10 minute", comment: ""), value: 10),
        SelectIntegerOption(name: NSLocalizedString("30 minute", comment: ""), value: 30),
        SelectIntegerOption(name: NSLocalizedString("60 minute", comment: ""), value: 60)
    ]

    static var defaultFetchInterval: Int {
        return PreferencesOptions.fetchIntervals[1].value
    }

    static var historySizes = [
        SelectIntegerOption(name: NSLocalizedString("None", comment: ""), value: 0),
        SelectIntegerOption(name: NSLocalizedString("3 entries", comment: ""), value: 3),
        SelectIntegerOption(name: NSLocalizedString("5 entries", comment: ""), value: 5),
        SelectIntegerOption(name: NSLocalizedString("10 entries", comment: ""), value: 10),
        SelectIntegerOption(name: NSLocalizedString("20 entries", comment: ""), value: 20),
        SelectIntegerOption(name: NSLocalizedString("30 entries", comment: ""), value: 30)
    ]

    static var defaultHistorySize: Int {
        return PreferencesOptions.historySizes[4].value
    }

    static var defaultAlertsStatus = true

    static var defaultFormatMethod = StatsFormatMethod.short
}
