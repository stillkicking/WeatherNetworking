//
//  Array+Ext.swift
//  WeatherNetworkingKit
//
//  Created by jonathan saville on 24/10/2023.
//

import Foundation

extension Array {

    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
