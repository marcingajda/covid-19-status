//
//  Format.swift
//  Covid-19 Status
//
//  Created by Marcin Gajda on 24/03/2020.
//  Copyright © 2020 Marcin Gajda. All rights reserved.
//

import Cocoa
import Foundation

func menuBarTextFormatter(label: String) -> NSMutableAttributedString {
    let text = NSMutableAttributedString()

    text.append(NSAttributedString(
        string: label,
        attributes: [
            .font: NSFont.menuBarFont(ofSize: 12),
            .baselineOffset: -1.5
        ]
    ))

    return text
}

enum StatsFormatMethod: String {
    case short
    case long
}

class StatsFormatter {
    var stats: RegionStats
    var method: StatsFormatMethod

    init(stats: RegionStats, method: StatsFormatMethod) {
        self.stats = stats
        self.method = method
    }

    func formatStatistic(value: Int) -> String {
        if method == .long {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            numberFormatter.groupingSeparator = " "
            return numberFormatter.string(from: NSNumber(value: value)) ?? "??"
        } else {
            return Double(value).shortStringRepresentation
        }
    }

    func getUniqueId() -> String {
        return "\(stats.country) \(stats.cases) \(stats.deaths) \(stats.recovered)"
    }

    func getRegionStatus() -> NSMutableAttributedString {
        let value1 = formatStatistic(value: stats.cases)
        let value2 = formatStatistic(value: stats.deaths)
        let value3 = formatStatistic(value: stats.recovered)

        return menuBarTextFormatter(label: "😷 \(value1)  💀 \(value2)  ❤️ \(value3)")
    }

    func getRegionDelta() -> String {
        let value1 = formatStatistic(value: stats.todayCases ?? 0)
        let value2 = formatStatistic(value: stats.todayDeaths ?? 0)

        return String(format: NSLocalizedString("Today: +%@ confirmed +%@ deaths", comment: ""), value1, value2)
    }

    func getTooltip() -> String {
        let countryName = NSLocalizedString(stats.country, comment: "")

        return String(
            format: NSLocalizedString("COVID-19 (%@)\nConfirmed | Deaths | Recured", comment: ""),
            countryName
        )
    }
}

extension Double {
    var shortStringRepresentation: String {
        if self.isNaN {
            return "NaN"
        }
        if self.isInfinite {
            return "\(self < 0.0 ? "-" : "+")Infinity"
        }
        if self == 0 {
            return "0"
        }

        let units = ["", "k", "M", "B"]
        var value = self
        var unitIndex = 0

        while unitIndex < units.count - 1 {
            if abs(value) < 1000.0 {
                break
            }
            unitIndex += 1
            value /= 1000.0
        }

        return "\(String(format: "%0.*g", Int(log10(abs(value))) + 2, value))\(units[unitIndex])"
    }
}
