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
        attributes:[
            .font: NSFont.menuBarFont(ofSize: 12),
            .baselineOffset: -1.5
        ]
    ))
    
    return text;
}

class StatsFormatter {
    var stats: RegionStats;
    
    init(stats: RegionStats) {
        self.stats = stats;
    }
    
    func formatStatistic(value: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.groupingSeparator = " "
        return numberFormatter.string(from: NSNumber(value: value)) ?? "??"
    }
    
    func getUniqueId() -> String {
        return "\(stats.country) \(stats.cases) \(stats.deaths) \(stats.recovered)";
    }

    func getRegionStatus() -> NSMutableAttributedString {
        let value1 = formatStatistic(value: stats.cases);
        let value2 = formatStatistic(value: stats.deaths);
        let value3 = formatStatistic(value: stats.recovered);
        
        return menuBarTextFormatter(label: "😷 \(value1)  💀 \(value2)  ❤️ \(value3)");
    }
    
    func getRegionDelta() -> String {
        let value1 = formatStatistic(value: stats.todayCases ?? 0);
        let value2 = formatStatistic(value: stats.todayDeaths ?? 0);
        
        return String(format:  NSLocalizedString("Today: +%@ confirmed +%@ deaths", comment: ""), value1, value2);
    }
    
    func getTooltip() -> String {
        let countryName = NSLocalizedString(stats.country, comment: "");
        return String(format: NSLocalizedString("COVID-19 (%@): Confirmed | Deaths | Recured", comment: ""), countryName);
    }
    
}
