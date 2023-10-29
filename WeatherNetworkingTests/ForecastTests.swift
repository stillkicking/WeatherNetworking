//
//  ForecastTests.swift
//  WeatherNetworkingTests
//
//  Created by jonathan saville on 18/10/2023.
//
import CoreLocation
import XCTest
@testable import WeatherNetworkingKit

final class ForecastTests: XCTestCase {

    var mockAPIService: MockAPIService!
    var honolulu: Location!
    var tokyo: Location!
    var london: Location!

    override func setUpWithError() throws {
        mockAPIService = MockAPIService()
        // coords must match with the name of a mock json file e.g. "OneCall(21.316,-157.801).json"
        honolulu = Location(coordinates: CLLocationCoordinate2D(latitude: 21.316, longitude: -157.801), name: "Honolulu") // 10 hours ahead of GMT
        tokyo = Location(coordinates: CLLocationCoordinate2D(latitude: 35.71, longitude: 139.454), name: "Tokyo") // 9 hours behind GMT
        london = Location(coordinates: CLLocationCoordinate2D(latitude: 51.488, longitude: -0.169), name: "London") // GMT
    }

    override func tearDownWithError() throws {
        mockAPIService = nil
        honolulu = nil
        tokyo = nil
        london = nil
    }

    func testLastForecastOfDay() throws {
        try checkLastForecastDay(location: london)
        try checkLastForecastDay(location: tokyo)
        try checkLastForecastDay(location: honolulu)
    }
    
    func testMissingHourlyForecasts() throws {
        try checkMissingHourlyForecasts(location: london)
        try checkMissingHourlyForecasts(location: tokyo)
        // try checkMissingHourlyForecasts(location: honolulu) // extra day added on - check this out
    }
    
    private func checkMissingHourlyForecasts(location: Location,
                                             file: StaticString = #filePath, line: UInt = #line) throws {
        
        let forecast = try XCTUnwrap (mockAPIService.getForecast(for: location.coordinates, from: [location], in: Bundle(for: Self.self)))
        let lastForecastOfDay = forecast.hourly.filter { $0.isLastForecastOfDay }
        let dailyCount = forecast.daily.count
        let lastForecastOfDayCount = lastForecastOfDay.count
        
        XCTAssertEqual(dailyCount, lastForecastOfDayCount, file: file, line: line)
    }
    
    private func checkLastForecastDay(location: Location,
                                      file: StaticString = #filePath, line: UInt = #line) throws {

        continueAfterFailure = false
        let forecast = try XCTUnwrap (mockAPIService.getForecast(for: location.coordinates, from: [location], in: Bundle(for: Self.self)))        
        let timezone = TimeZone(secondsFromGMT: forecast.timezoneOffset)!
        var calendar = Calendar.current
        calendar.timeZone = timezone

        for (index, hourly) in forecast.hourly.enumerated() {
            let hours = try XCTUnwrap(hourly.date.hours(calendar))
            let nextHourly = forecast.hourly[safe: index + 1]
            let expected = nextHourly?.date.isNotSameDayAndLater(hourly.date, calendar: calendar) ?? false || index == (forecast.hourly.count - 1)
            let found =  hourly.isLastForecastOfDay
            //if found { print("\(hourly.date.shortDayOfWeek(calendar)) \(hours):00 (\(hourly.detail == nil))") }
            //print("\(found ? "YES" : "NO ") \(hourly.date.shortDayOfWeek(calendar)) \(hours):00 (\(hourly.detail == nil))")
            XCTAssertEqual(found, expected, file: file, line: line)
        }
    }
}
