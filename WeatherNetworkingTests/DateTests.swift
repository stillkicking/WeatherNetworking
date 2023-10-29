//
//  DateTests.swift
//  WeatherNetworkingTests
//
//  Created by jonathan saville on 27/10/2023.
//

import CoreLocation
import XCTest
@testable import WeatherNetworkingKit

final class DateTests: XCTestCase {
    
    var dateFormatter: DateFormatter!

    override func setUpWithError() throws {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd MMM yyyy HH:mm:ssZZZZZ"
    }
    
    override func tearDownWithError() throws {
    }
 
    func testIsNotSameDayAndLater() {
        continueAfterFailure = true
        let date = dateFormatter.date(from:"Friday, 20 October 2023 07:44:05+00:00")!
        let calendar = Calendar.current
        
        let previousDay = dateFormatter.date(from:"Thursday, 19 October 2023 05:44:05+00:00")!
        XCTAssertFalse(previousDay.isNotSameDayAndLater(date, calendar: calendar))
        
        let sameDayEarlier = dateFormatter.date(from:"Friday, 20 October 2023 05:44:05+00:00")!
        XCTAssertFalse(sameDayEarlier.isNotSameDayAndLater(date, calendar: calendar))

        let sameDayLater = dateFormatter.date(from:"Friday, 20 October 2023 08:44:05+00:00")!
        XCTAssertFalse(sameDayLater.isNotSameDayAndLater(date, calendar: calendar))
        
        let nextDay = dateFormatter.date(from:"Saturday, 21 October 2023 07:44:05+00:00")!
        XCTAssertTrue(nextDay.isNotSameDayAndLater(date, calendar: calendar))
    }
 
    func testRoundedHourGMT() {
        let date = dateFormatter.date(from:"Friday, 27 October 2023 07:44:05+00:00")!
        let expectedDate = dateFormatter.date(from:"Friday, 27 October 2023 07:00:00+00:00")!

        checkRoundedHour(date: date, expectedDate: expectedDate)
    }

    func testRoundedHourAheadGMT() {
        let date = dateFormatter.date(from:"Friday, 27 October 2023 18:44:05+11:00")!
        let expectedDate = dateFormatter.date(from:"Friday, 27 October 2023 18:00:00+11:00")!

        checkRoundedHour(date: date, expectedDate: expectedDate)
    }

    func testRoundedHourBehindGMT() {
        let date = dateFormatter.date(from:"Friday, 27 October 2023 07:44:05-11:00")!
        let expectedDate = dateFormatter.date(from:"Friday, 27 October 2023 07:00:00-11:00")!

        checkRoundedHour(date: date, expectedDate: expectedDate)
    }

    private func checkRoundedHour(date: Date, expectedDate: Date,
                                  file: StaticString = #filePath, line: UInt = #line) {
        let roundedDate = date.startOfHour
        XCTAssertEqual(roundedDate, expectedDate, file: file, line: line)
    }
}
