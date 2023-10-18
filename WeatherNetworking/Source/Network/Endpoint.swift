//
//  Endpoint.swift
//  Weather
//
//  Created by jonathan saville on 06/09/2023.
//

import Foundation

struct Endpoint<T: Decodable> {
    var path: String
    var queryItems = [URLQueryItem]()
}

extension Endpoint {
    var request: URLRequest? {
        let defaultQueryItems = [URLQueryItem(name: "apiKey", value: "5188f5c9af2c5d545d8640c21b6f5f60")]
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/" + path
        components.queryItems = defaultQueryItems + queryItems

        guard let url = components.url else {
            return nil
        }

        return URLRequest(url: url)
    }
}
