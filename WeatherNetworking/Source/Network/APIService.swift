//
//  APIService.swift
//  Weather
//
//  Created by jonathan saville on 04/09/2023.
//

import Foundation
import Combine

public protocol APIServiceProtocol {
    func getForecasts(locations: [Location]) -> AnyPublisher<Result<[Forecast], Error>, Never>
    func getLocations(query: String) -> AnyPublisher<Result<[LocationDataModel], Error>, Never>
}

public enum APIError: LocalizedError {
    case badURL
    case networkError(Error)
    case invalidResponse
    case authError
    case clientError(String)
    case serverError(String)
    case jsonError(Error)
    case unexpected(String)
    
    public var errorDescription: String? {
        switch self {
        case .badURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response received"
        case .authError:
            return "Authorization failure - the OpenWeather apiKey is likely out-of-date. Please contact the app's author."
        case .clientError(let message):
            return "Client Error: \(message)"
        case .serverError(let message):
            return "Server Error: \(message)"
        case .jsonError:
            return "Unexpected data received from server"
        case .unexpected(let message):
            return "Received unexpected error: \(message)"
        }
    }
}

private struct APIErrorMessage: Decodable {
    var error: Bool
    var reason: String
    
    static func decodeFromJSON(_ data: Data) -> String {
        let message = try? JSONDecoder().decode(APIErrorMessage.self, from: data)
        return message?.reason ?? "Unexpected data received from server"
    }
}

public class APIService: APIServiceProtocol {
    
    public static let shared = APIService()

    private let urlSession = URLSession.shared

    func get<T: Decodable>(endpoint: Endpoint<T>) -> AnyPublisher<T, Error> {
        
        guard let request = endpoint.request else {
            return Fail(error: APIError.badURL).eraseToAnyPublisher()
        }

        return urlSession.dataTaskPublisher(for: request)
            .mapError { error -> Error in return APIError.networkError(error) }
            .tryMap { (data, response) -> (data: Data, response: URLResponse) in
               guard let urlResponse = response as? HTTPURLResponse else { throw APIError.invalidResponse }
               
               if (200..<300) ~= urlResponse.statusCode {
               }
               else {
                   switch urlResponse.statusCode {
                   case 300..<400: throw APIError.unexpected(APIErrorMessage.decodeFromJSON(data))
                   case 401: throw APIError.authError
                   case 400..<500: throw APIError.clientError(APIErrorMessage.decodeFromJSON(data))
                   case 500..<600: throw APIError.serverError(APIErrorMessage.decodeFromJSON(data))
                   default: throw APIError.invalidResponse
                   }
               }
               return (data, response)
             }
            .map(\.data)
            .tryMap { data -> T in
              do { return try JSONDecoder().decode(T.self, from: data) }
              catch { throw APIError.jsonError(error) }
            }
            .eraseToAnyPublisher()
    }
    
    // No error handling - returns an empty array
    func getArray<T: Decodable>(endpoint: Endpoint<T>) -> AnyPublisher<[T], Never> {
        guard let request = endpoint.request else {
            return Just([T].init()).eraseToAnyPublisher()
        }

        return urlSession.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .map { datum -> [T] in [T].init(arrayLiteral: datum) }
            .catch{ (error) -> AnyPublisher<[T], Never> in
                print("\(error)")
                return Just([T].init()).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
