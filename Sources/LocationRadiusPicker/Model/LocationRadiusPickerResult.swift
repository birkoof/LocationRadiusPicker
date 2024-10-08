//
//  LocationRadiusPickerResult.swift
//
//
//  Created by Eman Basic on 27.09.24.
//

public struct LocationRadiusPickerResult: CustomDebugStringConvertible {
    /// The location properties of the circle's center
    public let location: LocationModel
    /// The radius of the circle in meters
    public let radius: Double
    
    public var debugDescription: String {
        let geolocation = location.name.isEmpty ? "" : location.name + (location.address.isEmpty ? "" : location.address)
        return """
        Radius: \(radius);
        Latitude: \(location.coordinates.latitude)°, Longitude: \(location.coordinates.longitude)°;
        Geolocation: \(geolocation.isEmpty ? "-" : geolocation)
        """
    }
}
