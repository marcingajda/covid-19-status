//
//  Types.swift
//  Covid-19 Status
//
//  Created by Marcin Gajda on 24/03/2020.
//  Copyright © 2020 Marcin Gajda. All rights reserved.
//

struct RegionStats: Decodable {
    let country: String;
    let cases: Int;
    let todayCases: Int?;
    let deaths: Int;
    let todayDeaths: Int?;
    let recovered: Int;
    let active: Int;
    let critical: Int;
}

struct CoronaStats: Decodable {
    let data: [RegionStats];
    let worldStats: RegionStats;
}
