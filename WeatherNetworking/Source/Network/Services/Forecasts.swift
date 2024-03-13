//
//  Forecasts.swift
//  Weather
//
//  Created by jonathan saville on 06/09/2023.
//

import Foundation
import Combine

extension APIService {
    
    /// Publishes the forecasts associated with an array of locations.
    /// - Parameter locations: array of locations
    /// - Returns: array of forecasts
    public func getForecasts(locations: [Location]) -> AnyPublisher<Result<[Forecast], Error>, Never> {
        guard locations.isEmpty == false else {
            let emptyResult: Result<[Forecast], Error> = .success([])
            return Just(emptyResult).eraseToAnyPublisher()
        }

        typealias ForecastPublisher = AnyPublisher<Forecast, Error>
 
        let publishers: [ForecastPublisher] = locations.map{
            get(endpoint: .oneCall(for: ($0.coordinates.latitude, $0.coordinates.longitude)))
                .map{
                    var m = $0.toModel()
                    m.loadLocation(with: ($0.lat, $0.lon), from: locations)
                    return m
                }
            .eraseToAnyPublisher() }
        
        let overallPublisher = publishers.dropFirst().reduce(into: AnyPublisher(publishers[0].map{ [$0] })) {
            result, publisher in
            result = result.zip(publisher) {
                i1, i2 -> [Forecast] in
                return i1 + [i2]
            }
            .eraseToAnyPublisher()
        }
        return overallPublisher.toResult()
    }
}

struct OneCallDataModel: DataModel {
    var lat: Decimal
    var lon: Decimal
    var timezone: String
    var timezone_offset: Int
    var daily: [DailyDataModel]
    var hourly: [HourlyDataModel]

    func toModel() -> Forecast {
        var forecast = Forecast.init(timezone: timezone,
                                     timezoneOffset: timezone_offset,
                                     daily: daily.map{ $0.toModel() },
                                     hourly: hourly.map{ $0.toModel() })
        forecast.setHourlyFirstForecastOfDay()
        forecast.appendMissingHourlyForecasts()
        return forecast
    }
}

struct DailyDataModel: DataModel {
    var dt: Double
    var sunrise: Double
    var sunset: Double
    var moonrise: Double
    var moonset: Double
    var moon_phase: Decimal
    var summary: String
    var pressure: Int
    var humidity: Int
    var wind_deg: Int
    var wind_speed: Decimal
    var weather: [WeatherDataModel]
    var wind_gust: Decimal
    var temp: DailyTempDataModel
    
    func toModel() -> DailyForecast {
        DailyForecast.init(date: Date(timeIntervalSince1970: dt),
                           sunrise: Date(timeIntervalSince1970: sunrise),
                           sunset: Date(timeIntervalSince1970: sunset),
                           moonrise: Date(timeIntervalSince1970: moonrise),
                           moonset: Date(timeIntervalSince1970: moonset),
                           moonPhase: moon_phase,
                           summary: summary,
                           pressure: pressure,
                           humidity: humidity,
                           windSpeed: wind_speed,
                           windDirection: wind_deg,
                           displayable: weather.map { $0.toModel() },
                           windGust: wind_gust,
                           temperature: temp.toModel())
    }
}

struct HourlyDataModel: DataModel {
    var dt: Double
    var temp: Decimal
    var feels_like: Decimal
    var pressure: Int
    var humidity: Int
    var dew_point: Decimal
    var uvi: Decimal
    var clouds: Int
    var pop: Decimal
    var wind_speed: Decimal
    var wind_deg: Int
    var wind_gust: Decimal
    var weather: [WeatherDataModel]

    func toModel() -> HourlyForecast {
        let detail = HourlyForecastDetail(temp: temp,
                                          feels_like: feels_like,
                                          pressure: pressure,
                                          humidity: humidity,
                                          dew_point: dew_point,
                                          uvIndex: uvi,
                                          cloudCoverage: clouds,
                                          precipitation: pop,
                                          windSpeed: wind_speed,
                                          windDirection: wind_deg,
                                          windGust: wind_gust,
                                          displayable: weather.map { $0.toModel() })

        return HourlyForecast.init(date: Date(timeIntervalSince1970: dt),
                                   isFirstForecastOfDay: false,
                                   detail: detail)
    }
}

struct DailyTempDataModel: DataModel {
    var day: Decimal
    var min: Decimal
    var max: Decimal
    var night: Decimal
    var eve: Decimal
    var morn: Decimal
    
    func toModel() -> TemperatureForecast {
        TemperatureForecast.init(day: day,
                                 min: min,
                                 max: max,
                                 night: night,
                                 eve: eve,
                                 morn: morn)
    }
}

struct WeatherDataModel: DataModel {
    var id: Int
    var main: String
    var description: String
    var icon: String
    
    func toModel() -> DisplayableForecast {
        DisplayableForecast.init(id: id,
                                 main: main,
                                 description: description,
                                 icon: icon)
    }
}

private extension Endpoint where T == OneCallDataModel {
    static func oneCall(for coords: (lat: Decimal, lon: Decimal)) -> Self {
        Endpoint(path: "/data/3.0/onecall", queryItems: [
            URLQueryItem(name: "exclude", value: "alerts,minutely,current"),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "lat", value: "\(coords.lat)"),
            URLQueryItem(name: "lon", value: "\(coords.lon)")
        ])
    }
}
