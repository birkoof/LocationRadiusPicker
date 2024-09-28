//
//  LocationRadiusPickerResult.swift
//
//
//  Created by Eman Basic on 27.09.24.
//

import CoreLocation

public struct LocationRadiusPickerResult: CustomDebugStringConvertible {
    public let location: CLLocationCoordinate2D
    public let radius: CLLocationDistance
    public let geolocation: String
    
    public var debugDescription: String {
        "Radius: \(radius); Latitude: \(location.latitude)°, Longitude: \(location.longitude)°; Geolocation: \(geolocation.isEmpty ? "-" : geolocation)"
    }
}
