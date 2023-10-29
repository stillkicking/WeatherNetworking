//
//  Date+Ext.swift
//  WeatherNetworkingKit
//
//  Created by jonathan saville on 24/10/2023.
//

import Foundation

extension Date {

    func isNotSameDayAndLater(_ date: Date, calendar: Calendar) -> Bool {
        guard self > date else { return false }
        return !calendar.isDate(self, inSameDayAs: date)
    }

    func midnight(_ calendar: Calendar) -> Date {
        calendar.nextDate(after: self, matching: DateComponents(hour: 23, minute: 59, second: 59), matchingPolicy: .nextTime)!
    }
    
    var nextDay: Date {
        addingTimeInterval(Double(86400))
    }

    private func startOf(_ dateComponent : Calendar.Component, secondsFromGMT: Int = 0) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: secondsFromGMT)!
        var startOfComponent = self
        var timeInterval : TimeInterval = 0.0
        let _ = calendar.dateInterval(of: dateComponent, start: &startOfComponent, interval: &timeInterval, for: self)
        return startOfComponent
    }
}

#if DEBUG
extension Date {
    
    func hours(_ calendar: Calendar) -> Int? {
        calendar.component(.hour, from: self)
    }
    
    func shortDayOfWeek(_ calendar: Calendar)  -> String {
        guard calendar.isDateInToday(self) == false else { return "Today" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = calendar.timeZone
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: self).capitalized
    }
    
    var startOfHour: Date {
        // don't need to worry about timezone as the beginning of the hour is independent of that
        startOf(.hour)
    }

}
#endif
