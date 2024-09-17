//
//  LocationRadiusPickerConfiguration.swift
//
//
//  Created by Eman Basic on 16.09.24.
//

import CoreLocation
import UIKit

/// Defines the configuration for the Location Radius Picker
public struct LocationRadiusPickerConfiguration {
    /// The title displayed on the navigation bar.
    var title: String = "Location Radius Picker"
    
    /// The title displayed on the save button.
    var saveButtonTitle: String = "Save"
    
    /// The title displayed on the cancel button.
    var cancelButtonTitle: String = "Cancel"
    
    /// The initial radius of the circle (in meters).
    var radius: CLLocationDistance
    
    /// The minimum allowable radius of the circle (in meters).
    var minimumRadius: Double
    
    /// The maximum allowable radius of the circle (in meters).
    var maximumRadius: Double
    
    /// The initial geographic location of the circle's center, defined by latitude and longitude.
    var location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.331711, longitude: -122.030773)
    
    /// The color of the circle's border (outline).
    var radiusBorderColor: UIColor = .systemBlue
    
    /// The width of the circle's border (outline), in points.
    var radiusBorderWidth: CGFloat = 3
    
    /// The fill color of the circle's interior.
    var radiusColor: UIColor = .systemBlue.withAlphaComponent(0.2)
    
    /// The color of the label that displays the current radius value.
    var radiusLabelColor: UIColor = .label
    
    /// The color of the grabber (a small draggable circle used to adjust the radius).
    var grabberColor: UIColor = .systemBlue
    
    /// The diameter (in points) of the grabber (a small draggable circle used to adjust the radius), maintaining a 1:1 aspect ratio.
    var grabberSize: CGFloat = 20
    
    /// The unit system (metric/imperial/system default) used to display the radius measurement.
    var unitSystem: UnitSystemType = .system
    
    /// Whether the device vibrates (haptic feedback) when resizing the circle.
    var vibrateOnResize: Bool = true
}
