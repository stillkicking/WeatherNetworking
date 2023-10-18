//
//  Location.swift
//  Weather
//
//  Created by jonathan saville on 03/10/2023.
//

import Foundation
import CoreLocation

public typealias DecimalCoordinates = (latitude: Decimal, longitude: Decimal)

public class Location {
    public var coordinates: DecimalCoordinates
    public var name: String
    public var state: String
    public var country: String

    public var fullName: String {
        let stateDescr = state.isEmpty ? "" : " (\(state))"
        return "\(name)\(stateDescr)"
    }
    
    public init(coordinates: CLLocationCoordinate2D,
                name: String,
                country: String = "",
                state: String = "") {
        self.coordinates = (Decimal(coordinates.latitude), Decimal(coordinates.longitude))
        self.country = country
        self.name = name
        self.state = state
    }
}
