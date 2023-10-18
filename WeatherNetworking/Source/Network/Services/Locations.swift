//
//  Locations.swift
//  Weather
//
//  Created by jonathan saville on 06/09/2023.
//

import Foundation
import Combine

private extension Endpoint where T == [LocationDataModel] {
    static func locationSearch(for query: String) -> Self {
        Endpoint(path: "/geo/1.0/direct", queryItems: [
            URLQueryItem(name: "limit", value: "5"),
            URLQueryItem(name: "q", value: query)
        ])
    }
}

extension APIService {
    
    typealias LocationPublisher = AnyPublisher<[Location], Error>

    public func getLocations(query: String) -> AnyPublisher<Result<[LocationDataModel], Error>, Never> {
        get(endpoint: .locationSearch(for: query))
            .map{ $0 }
        .toResult()
        .eraseToAnyPublisher()
    }
}

public struct LocationDataModel: Decodable {
    var name: String
    var lat: Decimal
    var lon: Decimal
    var country: String
    var state: String?
}
