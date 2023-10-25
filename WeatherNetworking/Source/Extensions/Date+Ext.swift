//
//  Date+Ext.swift
//  WeatherNetworkingKit
//
//  Created by jonathan saville on 24/10/2023.
//

import Foundation

extension Date {

    func hours(_ secondsFromGMT: Int) -> Int? {
        guard let timezone = TimeZone(secondsFromGMT: secondsFromGMT) else { return nil }
        var calendar = Calendar.current
        calendar.timeZone = timezone
        return calendar.component(.hour, from: self)
    }
}
