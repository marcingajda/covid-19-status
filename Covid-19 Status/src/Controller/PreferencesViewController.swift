//
//  PreferencesViewController.swift
//  Covid-19 Status
//
//  Created by Marcin Gajda on 07/04/2020.
//  Copyright © 2020 Marcin Gajda. All rights reserved.
//

import Cocoa
import Foundation

enum SettingsKey: String {
    case selectedRegion
    case alertsEnabled
    case fetchInterval
    case historySize
    case history
    case formatMethod
}

class PreferencesViewController: NSViewController {
    let settings = UserDefaults.standard
    var observers: [NSKeyValueObservation] = []
    let observationField = \NSArrayController.selectionIndex

    @IBOutlet var intervalSelect: NSArrayController?
    @IBOutlet var historySelect: NSArrayController?
    @IBOutlet var formatMethodButton: NSButton?

    @objc dynamic var allowedIntervals = PreferencesOptions.fetchIntervals
    @objc dynamic var allowedHistorySizes = PreferencesOptions.historySizes

    func findOption(options: [SelectIntegerOption], value: Int) -> SelectIntegerOption {
        return options.first(where: { $0.value == value }) ?? options[0]
    }

    func intervalChangeHandler(value: Int) {
        settings.saveFetchInterval(interval: value)
        Messenger.shared.dispatchFetchInterval(interval: value)
    }

    func historySizeChangeHandler(value: Int) {
        settings.setHistorySize(count: value)
        Messenger.shared.dispatchHistorySize(size: value)
    }

    @IBAction func formatMethodChangeHandler(_ sender: NSButton) {
        let newMethod: StatsFormatMethod = sender.state == .on ? .short : .long
        settings.saveFormatMethod(method: newMethod)
        Messenger.shared.dispatchFormatMethod(method: newMethod)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NSApplication.shared.activate(ignoringOtherApps: true)

        guard let formatMethodButton = formatMethodButton else {
            ErrorHandler.standard.critical(withMessage: "The app is broken (format method button)")
            return
        }
        guard let intervalSelect = intervalSelect else {
            ErrorHandler.standard.critical(withMessage: "The app is broken (interval select)")
            return
        }
        guard let historySelect = historySelect else {
            ErrorHandler.standard.critical(withMessage: "The app is broken (history select)")
            return
        }

        print("format method:", settings.formatMethod)
        formatMethodButton.state = settings.formatMethod == .short ? .on : .off

        let intervalOption = findOption(options: allowedIntervals, value: settings.fetchInterval)
        intervalSelect.setSelectedObjects([intervalOption])

        let historySizeOption = findOption(options: allowedHistorySizes, value: settings.historySize)
        historySelect.setSelectedObjects([historySizeOption])

        setupObservers()
    }

    func setupObservers() {
        guard let intervalSelect = intervalSelect else {
            ErrorHandler.standard.critical(withMessage: "The app is broken (interval select controller)")
            return
        }

        guard let historySelect = historySelect else {
            ErrorHandler.standard.critical(withMessage: "The app is broken (history select controller)")
            return
        }

        observers = [
            intervalSelect.observe(observationField, options: [.new]) { (controller, _) in
                guard let intervals = controller.selectedObjects as? [SelectIntegerOption] else {
                    ErrorHandler.standard.critical(withMessage: "Failed to change")
                    return
                }

                if intervals.count > 0 {
                    self.intervalChangeHandler(value: intervals[0].value)
                }
            },
            historySelect.observe(observationField, options: [.new]) { (controller, _) in
                guard let historySizes = controller.selectedObjects as? [SelectIntegerOption] else {
                    ErrorHandler.standard.critical(withMessage: "Failed to change")
                    return
                }

                if historySizes.count > 0 {
                    self.historySizeChangeHandler(value: historySizes[0].value)
                }
            }
        ]
    }

    @IBAction func dismissPreferencesWindow(_ sender: NSButton) {
        view.window?.close()
    }
}
