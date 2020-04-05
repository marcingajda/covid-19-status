//
//  constants.swift
//  Covid-19 Status
//
//  Created by Marcin Gajda on 04/04/2020.
//  Copyright © 2020 Marcin Gajda. All rights reserved.
//

import Foundation

enum SpecialRegions: String {
    case world = "World"
}

enum ApiEndpoint: String {
    case stats = "https://corona-stats.online?format=json&source=2"
}

enum SettingsKey: String {
    case selectedRegion = "country"
    case alertsEnabled = "alerts"
    case fetchInterval = "interval"
}
