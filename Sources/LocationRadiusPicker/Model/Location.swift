//
//  Location.swift
//
//
//  Created by Eman Basic on 28.09.24.
//

import MapKit

struct Location: Equatable {
    var name: String
    var address: String
    var longitude: Double
    var latitude: Double
 
    func toCoordinates() -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
