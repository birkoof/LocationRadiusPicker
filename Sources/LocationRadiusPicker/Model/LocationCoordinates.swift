//
//  LocationCoordinates.swift
//
//
//  Created by Eman Basic on 08.10.24.
//

import Foundation

public struct LocationCoordinates: Equatable {
    var latitude: Double
    var longitude: Double
}

extension LocationCoordinates {
    func latitudeToString() -> String {
        String(format: "%.5f°", latitude)
    }
    
    func longitudeToString() -> String {
        String(format: "%.5f°", longitude)
    }
}
