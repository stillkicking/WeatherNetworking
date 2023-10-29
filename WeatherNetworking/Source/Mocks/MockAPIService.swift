//
//  MockAPIService.swift
//  Weather
//
//  Created by jonathan saville on 05/10/2023.
//

import Foundation
import Combine

/// Mocks the Combine-enabled API service by implementing APIServiceProtocol, publishing locally-held JSON responses to service requests.
public class MockAPIService: APIServiceProtocol {

    public init() { }

    public func getLocations(query: String) -> AnyPublisher<Result<[LocationDataModel], Error>, Never> {
        let emptyResult: Result<[LocationDataModel], Error> = .success([])
        return Just(emptyResult).eraseToAnyPublisher()
    }
    
    /// Publishes the mocked forecasts associated with an array of locations. Daily and hourly timestamps loaded form the mock data is overwritten to reflect the current date.
    ///
    ///  Mock forecast data must be available in JSON files with names formated as OneCall(<latitude>,<longitude>).json, e.g. OneCall(35.71,139.454).json. JSON structure to be added to this doc asap.
    /// - Parameter locations: array of locations
    /// - Returns: array of forecasts
    public func getForecasts(locations: [Location]) -> AnyPublisher<Result<[Forecast], Error>, Never> {
        guard locations.isEmpty == false else {
            let emptyResult: Result<[Forecast], Error> = .success([])
            return Just(emptyResult).eraseToAnyPublisher()
        }

        var forecasts: [Forecast] = []
        for location in locations {
            do {
                let forecast = try getForecast(for: location.coordinates, from: locations)
                forecasts.append(forecast)
            }
            catch {
                let errorResult: Result<[Forecast], Error> = .failure(APIError.jsonError(error))
                return Just(errorResult).eraseToAnyPublisher()
            }
        }

        let result: Result<[Forecast], Error> = .success(forecasts)
        return Just(result).eraseToAnyPublisher()
    }

    /// Publishes the mocked forecast associated with a set of coordinates (these coordinates must match that of a location in a given array of locations so that information such as location name can be injected into the returned object). Daily and hourly timestamps loaded from the mock data are reset to reflect a call date at the current time.
    ///
    ///  Mock forecast data must be available in JSON files with names formated as OneCall(<latitude>,<longitude>).json, e.g. OneCall(35.71,139.454).json. JSON structure to be added to this doc asap.
    /// - Parameters:
    ///   - coordinates: coordinates of location whose forecast is required
    ///   - locations: array of locations
    /// - Returns: forecast
    public func getForecast(for coordinates: DecimalCoordinates, from locations: [Location], in bundle: Bundle = .main) throws -> Forecast {
        let filename = "OneCall(\(coordinates.latitude.rounded(3)),\(coordinates.longitude.rounded(3)))"
        let dataModel: OneCallDataModel = try decodeJSON(from: filename, in: bundle)
        var forecast = dataModel.toModel()
        forecast.loadLocation(with: (dataModel.lat, dataModel.lon), from: locations)
        forecast.resetDates()
        forecast.setHourlyLastForecastOfDay()
        return forecast
    }

    func getOriginalTimezoneOffsetForForecast(for coordinates: DecimalCoordinates, from locations: [Location], in bundle: Bundle = .main) throws -> Int {
        let filename = "OneCall(\(coordinates.latitude.rounded(3)),\(coordinates.longitude.rounded(3)))"
        let dataModel: OneCallDataModel = try decodeJSON(from: filename, in: bundle)
        return dataModel.timezone_offset
    }

    private func decodeJSON<T: Decodable>(from resource: String, type: String = "json", in bundle: Bundle) throws -> T {
        print("\(Bundle.main.bundleIdentifier!)")
        let data: Data
        if let filepath = bundle.path(forResource: resource, ofType: type) {
            let json = try String(contentsOfFile: filepath)
            data = json.data(using: .utf8)!
         } else {
            throw (NSError(domain: "", code: 0))
        }
        return try JSONDecoder().decode(T.self, from: data)
   }
}

extension Forecast {
    static let secondsInEachHour: Double = 60 * 60
    static let secondsInEachDay: Double = secondsInEachHour * 24
    
    mutating func resetDates() {
        timezoneOffset = Calendar.current.timeZone.secondsFromGMT()
        
        let dailyStartDate = Date()
        for i in 0..<daily.count {
            daily[i].date = dailyStartDate.addingTimeInterval(Double(i) * Forecast.secondsInEachDay)
        }
       
        let hourlyStartDate = dailyStartDate.startOfHour
        var adjustment: Double = 0
        for i in 0..<hourly.count {
            adjustment += hourly[i].detail == nil ? Forecast.secondsInEachDay : Forecast.secondsInEachHour
            hourly[i].date = hourlyStartDate.addingTimeInterval(adjustment)
        }
    }
}
