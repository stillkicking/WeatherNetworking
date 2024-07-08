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

    func testFirstForecastOfDay() throws {
        try checkFirstForecastDay(location: london)
        try checkFirstForecastDay(location: tokyo)
        try checkFirstForecastDay(location: honolulu)
    }
    
    func testMissingHourlyForecasts() throws {
        try checkMissingHourlyForecasts(location: london)
        try checkMissingHourlyForecasts(location: tokyo)
    }
    
    func testLoadLocation() throws {
        let locations: [Location] = [honolulu, tokyo, london].compactMap { $0 }
        let preciseLocation = honolulu.copy().withMorePreciseCoordinates()
        
        var forecast = Forecast(location: nil, timezone: "", timezoneOffset: 0, daily: [], hourly: [])
        XCTAssertNil(forecast.location)
        forecast.loadLocation(with: preciseLocation.coordinates, from: locations)
        XCTAssertEqual(forecast.location, honolulu)
    }
    
    func testSimpleSort() {
        let forecastLocations = [london, tokyo, honolulu].compactMap { $0 }
        continueAfterFailure = false

        checkSimpleSort(forecastLocations: forecastLocations,
                        sortedBy: forecastLocations)
        
        checkSimpleSort(forecastLocations: forecastLocations,
                        sortedBy: [honolulu, tokyo, london])
        
        checkSimpleSort(forecastLocations: forecastLocations,
                        sortedBy: [honolulu, london, tokyo])

        checkSimpleSort(forecastLocations: forecastLocations,
                        sortedBy: [],
                        expected: [london, tokyo, honolulu])
 
        checkSimpleSort(forecastLocations: forecastLocations,
                        sortedBy: [tokyo],
                        expected: [london, tokyo, honolulu])

        checkSimpleSort(forecastLocations: forecastLocations,
                        sortedBy: [tokyo, london],
                        expected: [tokyo, honolulu, london])
        
        checkSimpleSort(forecastLocations: forecastLocations,
                        sortedBy: [honolulu, tokyo],
                        expected: [london, honolulu, tokyo])
    }

    private func checkSimpleSort(forecastLocations: [Location],
                                 sortedBy sortByLocations: [Location],
                                 expected: [Location]? = nil,
                                 file: StaticString = #filePath, line: UInt = #line) {
        
        var forecasts = forecastLocations.map { Forecast(location: $0, timezone: "", timezoneOffset: 0, daily: [], hourly: []) }
        let expectedLocations = expected ?? sortByLocations
        forecasts.simpleSort(by: sortByLocations)
        XCTAssertEqual(forecasts.compactMap { $0.location }, expectedLocations, file: file, line: line)
    }

    private func checkMissingHourlyForecasts(location: Location,
                                             file: StaticString = #filePath, line: UInt = #line) throws {
        
        let forecast = try XCTUnwrap (mockAPIService.getForecast(for: location.coordinates, from: [location], in: Bundle(for: Self.self)))
        let firstForecastOfDay = forecast.hourly.filter { $0.isFirstForecastOfDay }
        let firstForecastOfDayCount = firstForecastOfDay.count
        let dailyCount = forecast.daily.count
        
        XCTAssertEqual(dailyCount, firstForecastOfDayCount, file: file, line: line)
    }
    
    private func checkFirstForecastDay(location: Location,
                                       file: StaticString = #filePath, line: UInt = #line) throws {

        continueAfterFailure = false
        let forecast = try XCTUnwrap (mockAPIService.getForecast(for: location.coordinates, from: [location], in: Bundle(for: Self.self)))
        let timezone = TimeZone(secondsFromGMT: forecast.timezoneOffset)!
        var calendar = Calendar.current
        calendar.timeZone = timezone

        for (index, hourly) in forecast.hourly.enumerated() {
            let expected: Bool
            if let previousHourly = forecast.hourly[safe: index - 1] {
                expected = hourly.date.isNotSameDayAndLater(previousHourly.date, calendar: calendar)
             } else {
                expected = true
            }
            let found =  hourly.isFirstForecastOfDay
            /*
            let hours = try XCTUnwrap(hourly.date.hours(calendar))
            if found { print("\(hourly.date.shortDayOfWeek(calendar)) \(hours):00 (\(hourly.detail == nil))") }
            print("\(found ? "YES" : "NO ") \(hourly.date.shortDayOfWeek(calendar)) \(hours):00 (\(hourly.detail == nil))")
            */
            XCTAssertEqual(found, expected, file: file, line: line)
        }
    }
}

private extension Location {
    
    func copy() -> Location {
        Location(coordinates: self.coordinates, name: self.name, country: self.country, state: self.state)
    }
    
    func withMorePreciseCoordinates(addedPrecision: Decimal = 0.000666) -> Location {
        let newCoords = DecimalCoordinates(latitude: self.coordinates.latitude + addedPrecision,
                                           longitude: self.coordinates.longitude + addedPrecision)
        self.coordinates = newCoords
        return self
    }
}
