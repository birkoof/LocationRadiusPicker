//
//  LocationRadiusPickerResult.swift
//
//
//  Created by Eman Basic on 27.09.24.
//

import CoreLocation

public struct LocationRadiusPickerResult: CustomDebugStringConvertible {
    /// The geographic location of the circle's center
    public let location: CLLocationCoordinate2D
    /// The radius of the circle in meters
    public let radius: CLLocationDistance
    /// Geocoded address of the circle location
    public let geolocation: String
    
    public var debugDescription: String {
        "Radius: \(radius); Latitude: \(location.latitude)°, Longitude: \(location.longitude)°; Geolocation: \(geolocation.isEmpty ? "-" : geolocation)"
    }
}
