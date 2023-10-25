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
    
    override func setUpWithError() throws {
        mockAPIService = MockAPIService()
    }

    override func tearDownWithError() throws {
        mockAPIService = nil
    }

    func testIsLastForecastOfDay() throws {
        continueAfterFailure = false
        let location = Location(coordinates: CLLocationCoordinate2D(latitude: 21.316, longitude: -157.8), name: "honolulu")
        var forecast = try mockAPIService.getForecast(for: location.coordinates, from: [location], in: Bundle(for: Self.self))
        XCTAssertNotNil(forecast)
        
        for (index, hourly) in forecast.hourly.enumerated() {
            let hours = try XCTUnwrap(hourly.date.hours(forecast.timezoneOffset))
            let expected =  hours == 23 || index == (forecast.hourly.count - 1)
            
            XCTAssertEqual(hourly.isLastForecastOfDay, expected)

            let last: String
            if let isLastForecastOfDay = hourly.isLastForecastOfDay { last = "\(isLastForecastOfDay)" } else { last = "EMPTY"}
            print("\(hourly.date.hours(forecast.timezoneOffset)!), \(last) (timezoneOffset: \(forecast.timezoneOffset)")
        }
    }

 }
