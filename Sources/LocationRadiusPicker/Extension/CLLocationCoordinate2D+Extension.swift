//
//  CLLocationCoordinate2D+Extension.swift
//
//
//  Created by Eman Basic on 28.09.24.
//

import CoreLocation

extension CLLocationCoordinate2D {
    func latitudeToString() -> String {
        String(format: "%.5f°", latitude)
    }
    
    func longitudeToString() -> String {
        String(format: "%.5f°", longitude)
    }
}
