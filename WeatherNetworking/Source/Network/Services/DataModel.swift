//
//  DataModel.swift
//  Weather
//
//  Created by jonathan saville on 10/09/2023.
//

import Foundation

protocol DataModel<T>: Decodable {
    associatedtype T
    func toModel() -> T
}
