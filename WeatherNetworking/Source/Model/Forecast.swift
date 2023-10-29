//
//  Forecast.swift
//  Weather
//
//  Created by jonathan saville on 04/09/2023.
//

import Foundation

public struct Forecast {
    public var location: Location?
    public let timezone: String
    /// timezone offset in seconds from GMT
    public var timezoneOffset: Int
    public var daily: [DailyForecast]
    public var hourly: [HourlyForecast]

    /// When loading forecast information from the API service, only the coords are supplied, not the location name, etc. So we have to be able to inject these - we do that by matching the
    /// returned coordinates with those in the locations used in the intial request. Sounds straightforward, but unfortunately the API does not necessarily return exactly the same coordinates
    /// as was requested - some precision is lost, for some reason. Two decimal places seem OK, however, so we restrict the match to just those two decimal places.
    mutating func loadLocation(with coords: DecimalCoordinates,
                               from locations: [Location]) {
        let places = 2
        let latitude = coords.latitude.rounded(places)
        let longitude = coords.longitude.rounded(places)
        
        self.location = locations.first{
            latitude == $0.coordinates.latitude.rounded(places) &&
            longitude == $0.coordinates.longitude.rounded(places)
        }
    }
    
    mutating func setHourlyLastForecastOfDay() {
        guard let timezone = TimeZone(secondsFromGMT: timezoneOffset) else { return }
        var calendar = Calendar.current
        calendar.timeZone = timezone
        
        for index in 0..<hourly.count {
            let lastForecastOfDay: Bool
            if let nextDate = hourly[safe: index + 1]?.date {
                lastForecastOfDay = nextDate.isNotSameDayAndLater(hourly[index].date, calendar: calendar)
            } else {
                lastForecastOfDay = index == hourly.count - 1
            }
            hourly[index].isLastForecastOfDay = lastForecastOfDay
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
            hourly.append(HourlyForecast(date: currHourlyDate, isLastForecastOfDay: true, detail: nil))
            currHourlyDate = currHourlyDate.nextDay
        }
    }
}

public struct DailyForecast: Identifiable {
    public let id = UUID()
    public var date: Date
    public let sunrise: Int
    public let sunset: Int
    public let pressure: Int
    public let humidity: Int
    public let windSpeed: Decimal
    public let windDirection: Int
    public let displayable: [DisplayableForecast]
    public let windGust: Decimal
    public let temperature: TemperatureForecast
}

public struct HourlyForecast: Identifiable {
    public let id = UUID()
    public var date: Date
    public var isLastForecastOfDay: Bool
    public let detail: HourlyForecastDetail?
}

public struct HourlyForecastDetail {
    public let temp: Decimal
    public let feels_like: Decimal
    public let pressure: Int
    public let humidity: Int
    public let dew_point: Decimal
    public let uvIndex: Decimal
    public let cloudCoverage: Int
    public let visibility: Int
    public let precipitation: Decimal
    public let windSpeed: Decimal
    public let windDirection: Int
    public let windGust: Decimal
    public let displayable: [DisplayableForecast]
}

public struct TemperatureForecast {
    public let day: Decimal
    public let min: Decimal
    public let max: Decimal
    public let night: Decimal
    public let eve: Decimal
    public let morn: Decimal
}

public struct DisplayableForecast {
    public let id: Int
    public let main: String
    public let description: String
    public let icon: String
}
