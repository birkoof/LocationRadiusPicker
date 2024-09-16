//
//  File.swift
//  
//
//  Created by Eman Basic on 16.09.24.
//

import CoreLocation
import UIKit

public struct LocationRadiusPickerConfiguration {
    var title: String = "Location Radius Picker"
    var saveButtonTitle: String = "Save"
    var cancelButtonTitle: String = "Cancel"
    var radius: CLLocationDistance
    var minimumRadius: Double
    var maximumRadius: Double
    var location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.331711, longitude: -122.030773)
    var radiusBorderColor: UIColor = .systemBlue
    var radiusBorderWidth: CGFloat = 3
    var radiusColor: UIColor = .systemBlue.withAlphaComponent(0.2)
    var radiusLabelColor: UIColor = .label
    var grabberColor: UIColor = .systemBlue
    var grabberSize: CGFloat = 20
    var unitSystem: UnitSystemType = .system
    var vibrateOnResize: Bool = true
}
