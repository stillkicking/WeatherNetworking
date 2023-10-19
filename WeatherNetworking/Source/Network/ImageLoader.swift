//
//  ImageLoader.swift
//  Weather
//
//  Created by jonathan saville on 11/09/2023.
//

import Foundation
import UIKit

/// Provides access to the icons & images provided by the OpenWeather service
@globalActor public actor ImageLoader {
    
    public static let shared = ImageLoader()

    private var images: [URLRequest: LoaderStatus] = [:]
    
    /// Returns an optional URL to download an OpenWeather icon
    /// - Parameter iconId: id of weather icon
    /// - Returns: URL  to download the weather icon associated with  iconId (nil if iconID is not valid in a URL query string)
    public static func iconURL(for iconId: String) -> URL? {
        URL(string: "https://openweathermap.org/img/wn/\(iconId)@2x.png")
    }
    
    /// Asynchronously returns an OpenWeather weather icon
    /// - Parameter iconId: id of weather icon
    /// - Returns: the weather icon (nil if not found)
    public func fetchIcon(for iconId: String) async throws -> UIImage? {
        guard let url = ImageLoader.iconURL(for: iconId) else { return nil }
        return try await fetch(url)
    }

    func fetch(_ url: URL) async throws -> UIImage? {
        let request = URLRequest(url: url)
        return try await fetch(request)
    }

    func fetch(_ urlRequest: URLRequest) async throws -> UIImage? {
        if let status = images[urlRequest] {
            switch status {
            case .fetched(let image):
                return image
            case .inProgress(let task):
                return try await task.value // can throw
            }
        }

        let task: Task<UIImage?, Error> = Task {
            let (imageData, _) = try await URLSession.shared.data(for: urlRequest)
            return UIImage(data: imageData)
        }

        images[urlRequest] = .inProgress(task)
        let image = try await task.value // can throw
        if let image = image {
            images[urlRequest] = .fetched(image)
        }
        return image
    }

    private enum LoaderStatus {
        case inProgress(Task<UIImage?, Error>)
        case fetched(UIImage)
    }
}
