//
//  Forecast.swift
//  Weather
//
//  Created by jonathan saville on 04/09/2023.
//

import Foundation

public struct Forecast: Identifiable, Hashable {
    public let id = UUID()
    public var location: Location?
    public let timezone: String
    /// timezone offset in seconds from GMT
    public var timezoneOffset: Int
    public var daily: [DailyForecast]
    public var hourly: [HourlyForecast]

    /// When loading forecast information from the API service, only the coords are supplied, not the location name, etc. So we have to be able to inject these - we do that by matching the
    /// returned coordinates with those in the locations used in the intial request....
    mutating func loadLocation(with coords: DecimalCoordinates,
                               from locations: [Location]) {
        location = locations.location(withPreciseCoords: coords)
    }
    
    mutating func setHourlyFirstForecastOfDay() {
        guard let timezone = TimeZone(secondsFromGMT: timezoneOffset),
              hourly.isEmpty == false else { return }
        
        var calendar = Calendar.current
        calendar.timeZone = timezone
        
        hourly[0].isFirstForecastOfDay = true // note - cannot use .first? here, but checked guard !isEmpty
        
        for index in 1..<hourly.count {
            let currDate = hourly[index].date
            if let previousDate = hourly[safe: index - 1]?.date {
                hourly[index].isFirstForecastOfDay = currDate.isNotSameDayAndLater(previousDate, calendar: calendar)
            }
        }
    }

    mutating func appendMissingHourlyForecasts() {
        guard let timezone = TimeZone(secondsFromGMT: timezoneOffset) else { return }
        var calendar = Calendar.current
        calendar.timeZone = timezone

        guard let dayAfterLast = daily.last?.date.nextDay,
              var currHourlyDate = hourly.last?.date.nextDay else { return }
        
        let lastDateAtMidnight = calendar.startOfDay(for: dayAfterLast).addingTimeInterval(-1)
        while currHourlyDate < lastDateAtMidnight {
            hourly.append(HourlyForecast(date: currHourlyDate, isFirstForecastOfDay: true, detail: nil))
            currHourlyDate = currHourlyDate.nextDay
        }
    }
}


public extension Array where Element == Forecast {
   
    // A 'simple' sort, i.e. not particularly complex code. Not the most efficient, but in reality we will be dealing
    // here with a very small number of locations, so performance is secondary to simplicity.
    mutating func simpleSort(by locations: [Location]) {

        self.sort{ e0, e1 in
            let i = locations.firstIndex(where: { loc in e0.location?.coordinates == loc.coordinates }) ?? 0
            let j = locations.firstIndex(where: { loc in e1.location?.coordinates == loc.coordinates }) ?? 0
            return i < j
        }
    }
}

public struct DailyForecast: Identifiable, Hashable {
    public let id = UUID()
    public var date: Date
    public let sunrise: Date
    public let sunset: Date
    public let moonrise: Date
    public let moonset: Date
    public let moonPhase: Decimal
    public let summary: String
    public let pressure: Int
    public let humidity: Int
    public let windSpeed: Decimal
    public let windDirection: Int
    public let displayable: [DisplayableForecast]
    public let windGust: Decimal
    public let temperature: TemperatureForecast
}

public struct HourlyForecast: Identifiable, Hashable {
    public let id = UUID()
    public var date: Date
    public var isFirstForecastOfDay: Bool
    public let detail: HourlyForecastDetail?
}

public struct HourlyForecastDetail: Hashable {
    public let temp: Decimal
    public let feels_like: Decimal
    public let pressure: Int
    public let humidity: Int
    public let dew_point: Decimal
    public let uvIndex: Decimal
    public let cloudCoverage: Int
    public let precipitation: Decimal
    public let windSpeed: Decimal
    public let windDirection: Int
    public let windGust: Decimal
    public let displayable: [DisplayableForecast]
}

public struct TemperatureForecast: Hashable {
    public let day: Decimal
    public let min: Decimal
    public let max: Decimal
    public let night: Decimal
    public let eve: Decimal
    public let morn: Decimal
}

public struct DisplayableForecast: Hashable {
    public let id: Int
    public let main: String
    public let description: String
    public let icon: String
}
