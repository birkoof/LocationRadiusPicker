//
//  LocationCoordinates.swift
//
//
//  Created by Eman Basic on 08.10.24.
//

import Foundation

public struct LocationCoordinates: Equatable {
    public let latitude: Double
    public let longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension LocationCoordinates {
    func latitudeToString() -> String {
        String(format: "%.5f°", latitude)
    }
    
    func longitudeToString() -> String {
        String(format: "%.5f°", longitude)
    }
}
