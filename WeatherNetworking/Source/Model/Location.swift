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
    
    public init(coordinates: DecimalCoordinates,
                name: String,
                country: String = "",
                state: String = "") {
        self.coordinates = coordinates
        self.country = country
        self.name = name
        self.state = state
    }
    
    public convenience init(coordinates: CLLocationCoordinate2D,
                            name: String,
                            country: String = "",
                            state: String = "") {
        self.init(coordinates: DecimalCoordinates(latitude: Decimal(coordinates.latitude),
                                                  longitude: Decimal(coordinates.longitude)),
                  name: name,
                  country: country,
                  state: state)
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

public extension Array where Element == Location {

    /// Return a Location matching the supplied coordinates. Those coordinates may have been returned by an API call, in which case they will not necessarily
    /// match those sent in the request - some precision can be lost for some reason. To successfull match the coordinates, rounding to two decimal places seems
    /// to allow the match.
    func location(withPreciseCoords coords: DecimalCoordinates) -> Location? {
        let places = 2
        let latitude = coords.latitude.rounded(places)
        let longitude = coords.longitude.rounded(places)
        
        return self.first {
            latitude == $0.coordinates.latitude.rounded(places) &&
            longitude == $0.coordinates.longitude.rounded(places)
        }
    }
}
