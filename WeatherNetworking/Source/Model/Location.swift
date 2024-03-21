//
//  Location.swift
//  Weather
//
//  Created by jonathan saville on 03/10/2023.
//

import Foundation
import CoreLocation

public struct DecimalCoordinates: Hashable {
    public let latitude: Decimal
    public let longitude: Decimal
}

public class Location: Identifiable {
    public let id = UUID()
    public var coordinates: DecimalCoordinates
    public var name: String
    public var state: String
    public var country: String
    
    ///  A string describing the name of the location, optionally appended with its state, e.g. London, Rome (Lazio)
    public var fullName: String {
        let stateDescr = state.isEmpty ? "" : " (\(state))"
        return "\(name)\(stateDescr)"
    }
    
    public init(coordinates: CLLocationCoordinate2D,
                name: String,
                country: String = "",
                state: String = "") {
        self.coordinates = DecimalCoordinates(latitude: Decimal(coordinates.latitude),
                                              longitude: Decimal(coordinates.longitude))
        self.country = country
        self.name = name
        self.state = state
    }
}

extension Location: Equatable, Hashable {
    public static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.coordinates == rhs.coordinates &&
        lhs.country == rhs.country &&
        lhs.name == rhs.name &&
        lhs.state == rhs.state
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
