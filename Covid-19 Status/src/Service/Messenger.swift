//
//  Messenger.swift
//  Covid-19 Status
//
//  Created by Marcin Gajda on 13/04/2020.
//  Copyright © 2020 Marcin Gajda. All rights reserved.
//

import Cocoa

extension NSNotification.Name {
    static let SelectedRegionChanged = NSNotification.Name(rawValue: "SelectedRegionChanged")
    static let HistorySizeChanged = NSNotification.Name(rawValue: "HistorySizeChanged")
    static let FetchIntervalChange = NSNotification.Name(rawValue: "FetchIntervalChange")
    static let AlertsStatusChange = NSNotification.Name(rawValue: "AlertsStatusChange")
    static let FetchRequest = NSNotification.Name(rawValue: "FetchRequest")
    static let FormatMethodChange = NSNotification.Name(rawValue: "FormatMethodChange")
}

class Messenger: NSObject {
    static let shared = Messenger()

    let notifier = NotificationCenter.default

    // selected region

    func dispatchSelectedRegion(region: String) {
        notifier.post(name: .SelectedRegionChanged, object: self, userInfo: ["region": region])
    }

    func onSelectedRegionChange(listener: @escaping (_ region: String) -> Void) -> NSObjectProtocol {
        return notifier.addObserver(forName: .SelectedRegionChanged, object: nil, queue: nil) { notification in
            if let region = notification.userInfo?["region"] as? String {
              listener(region)
            }
        }
    }

    // fetch interval

    func dispatchFetchInterval(interval: Int) {
        notifier.post(name: .FetchIntervalChange, object: self, userInfo: ["interval": interval])
    }

    func onFetchIntervalChange(listener: @escaping (_ region: Int) -> Void) -> NSObjectProtocol {
        return notifier.addObserver(forName: .FetchIntervalChange, object: nil, queue: nil) { notification in
            if let interval = notification.userInfo?["interval"] as? Int {
              listener(interval)
            }
        }
    }

    // fetch request (eg.: retry)

    func dispatchFetchRequest() {
        notifier.post(name: .FetchRequest, object: self)
    }

    func onFetchRequest(listener: @escaping () -> Void) -> NSObjectProtocol {
        return notifier.addObserver(forName: .FetchRequest, object: nil, queue: nil) { _ in
            listener()
        }
    }

    // history size

    func dispatchHistorySize(size: Int) {
        notifier.post(name: .HistorySizeChanged, object: self, userInfo: ["size": size])
    }

    func onHistorySizeChange(listener: @escaping (_ size: Int) -> Void) -> NSObjectProtocol {
        return notifier.addObserver(forName: .HistorySizeChanged, object: nil, queue: nil) { notification in
            if let size = notification.userInfo?["size"] as? Int {
              listener(size)
            }
        }
    }

    // alerts

    func dispatchAlertsStatus(enabled: Bool) {
        notifier.post(name: .AlertsStatusChange, object: self, userInfo: ["alerts": enabled])
    }

    func onAlertsStatusChange(listener: @escaping (_ enabled: Bool) -> Void) -> NSObjectProtocol {
        return notifier.addObserver(forName: .AlertsStatusChange, object: nil, queue: nil) { notification in
            if let enabled = notification.userInfo?["alerts"] as? Bool {
              listener(enabled)
            }
        }
    }

    // format method

    func dispatchFormatMethod(method: StatsFormatMethod) {
        notifier.post(name: .FormatMethodChange, object: self, userInfo: ["method": method])
    }

    func onFormatMethodChange(listener: @escaping (_ enabled: StatsFormatMethod) -> Void) -> NSObjectProtocol {
        return notifier.addObserver(forName: .FormatMethodChange, object: nil, queue: nil) { notification in
            if let method = notification.userInfo?["method"] as? StatsFormatMethod {
              listener(method)
            }
        }
    }
}
