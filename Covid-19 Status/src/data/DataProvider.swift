//
//  DataProvider.swift
//  Covid-19 Status
//
//  Created by Marcin Gajda on 04/04/2020.
//  Copyright © 2020 Marcin Gajda. All rights reserved.
//

import Cocoa

class DataProvider: NSObject {
    let settings = UserDefaults.standard
    var timer: Timer?

    let onSuccessCallback: (CoronaStats) -> Void
    let onErrorCallback: (String?) -> Void

    var lastCoronaStats: CoronaStats?

    init(onSuccess: @escaping (CoronaStats) -> Void, onError: @escaping (String?) -> Void) {
        onSuccessCallback = onSuccess
        onErrorCallback = onError
    }

    func getStatsFor(region: String) -> RegionStats? {
        guard let lastCoronaStats = lastCoronaStats else {
            return nil
        }

        return region == SpecialRegions.world.rawValue
            ? lastCoronaStats.worldStats
            : lastCoronaStats.data.first(where: { (countryStats) -> Bool in
                countryStats.country == region
            }) ?? lastCoronaStats.worldStats
    }

    func startTimer() {
        let prefferedInterval = settings.double(forKey: SettingsKey.fetchInterval.rawValue)
        let interval = max(prefferedInterval, 1)

        if let timer = timer {
            timer.invalidate()
        }

        timer = Timer.scheduledTimer(
            timeInterval: interval * 60,
            target: self,
            selector: #selector(self.doUpdate),
            userInfo: nil,
            repeats: true
        )
    }

    @objc func doUpdate() {
        print("Updating data")

        ApiClient.fetchData { coronaStats, error in
            guard let coronaStats = coronaStats else {
                self.onErrorCallback(error)
                return
            }

            self.lastCoronaStats = coronaStats
            self.onSuccessCallback(coronaStats)
        }
    }
}
