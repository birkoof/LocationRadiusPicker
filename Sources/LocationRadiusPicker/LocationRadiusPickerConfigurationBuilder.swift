//
//  File.swift
//  
//
//  Created by Eman Basic on 16.09.24.
//

import CoreLocation
import UIKit

/// Builder for LocationRadiusPickerConfiguration
public class LocationRadiusPickerConfigurationBuilder {
    private var configuration: LocationRadiusPickerConfiguration
    
    /// Creates the LocationRadiusPickerConfigurationBuilder with default radius parameters.
    /// - Parameters:
    ///   - initialRadius: the initial radius the circle will be set to
    ///   - minimumRadius: minimum allowed radius the circle can shrink to
    ///   - maximumRadius: maximum allowed radius the circle can expand to
    public init(initialRadius: Double, minimumRadius: Double, maximumRadius: Double) {
        configuration = LocationRadiusPickerConfiguration(radius: initialRadius, minimumRadius: minimumRadius, maximumRadius: maximumRadius)
    }
    
    /// The title of the picker, shown on the navigation bar. Defaults to "Location Radius Picker".
    /// - Parameter title: title of the picker
    /// - Returns: updated builder
    public func title(_ title: String) -> LocationRadiusPickerConfigurationBuilder {
        configuration.title = title
        return self
    }
    
    /// The title of the save button, located on the navigation bar. Defaults to "Save".
    /// - Parameter title: title of the save button
    /// - Returns: updated builder
    public func saveButtonTitle(_ title: String) -> LocationRadiusPickerConfigurationBuilder {
        configuration.saveButtonTitle = title
        return self
    }
    
    /// The title of the cancel button, located on the navigation bar. Defaults to "Cancel".
    /// - Parameter title: title of the cancel button
    /// - Returns: updated builder
    public func cancelButtonTitle(_ title: String) -> LocationRadiusPickerConfigurationBuilder {
        configuration.cancelButtonTitle = title
        return self
    }
    
    /// Initial location where the circle will be placed on the map. Defaults to Apple Inc. - Infinite Loop Campus.
    /// - Parameter location: location coordinates of the circle
    /// - Returns: updated builder
    public func initialLocation(_ location: CLLocationCoordinate2D) -> LocationRadiusPickerConfigurationBuilder {
        configuration.location = location
        return self
    }
    
    /// Color of the radius circle border. Defaults to UIColor.systemBlue.
    /// - Parameter color: color of the radius circle border
    /// - Returns: updated builder
    public func radiusBorderColor(_ color: UIColor) -> LocationRadiusPickerConfigurationBuilder {
        configuration.radiusBorderColor = color
        return self
    }
    
    /// Width of the radius circle border. Defaults to 3.0.
    /// - Parameter width: width of the radius circle border
    /// - Returns: updated builder
    public func radiusBorderWidth(_ width: Double) -> LocationRadiusPickerConfigurationBuilder {
        configuration.radiusBorderWidth = width
        return self
    }
    
    /// Fill color of the radius circle. Defaults to UIColor.systemBlue.withAlphaComponent(0.2).
    /// - Parameter color: Color of the radius circle
    /// - Returns: updated builder
    public func radiusColor(_ color: UIColor) -> LocationRadiusPickerConfigurationBuilder {
        configuration.radiusColor = color
        return self
    }
    
    /// Color of the radius label, which displays the current radius size. Defaults to UIColor.label.
    /// - Parameter color: text color of the radius label
    /// - Returns: updated builder
    public func radiusLabelColor(_ color: UIColor) -> LocationRadiusPickerConfigurationBuilder {
        configuration.radiusLabelColor = color
        return self
    }
    
    /// Color of the radius grabber (small circle with a pan gesture that resizes the radius). Defaults to UIColor.systemBlue.
    /// - Parameter color: color of the radius grabber
    /// - Returns: updated builder
    public func grabberColor(_ color: UIColor) -> LocationRadiusPickerConfigurationBuilder {
        configuration.grabberColor = color
        return self
    }
    
    /// Size of the grabber view (small circle with a pan gesture that resizes the radius). Aspect ratio is 1:1. Defaults to 20pt.
    /// - Parameter size: size of the grabber view
    /// - Returns: updated builder
    public func grabberSize(_ size: CGFloat) -> LocationRadiusPickerConfigurationBuilder {
        configuration.grabberSize = size
        return self
    }
    
    /// Enables/disables the vibration effect when resizing the radius circle. Defaults to true.
    /// - Parameter vibrate: enables vibration if set to true, otherwise disables it.
    /// - Returns: updated builder
    public func vibrateOnResize(_ vibrate: Bool) -> LocationRadiusPickerConfigurationBuilder {
        configuration.vibrateOnResize = vibrate
        return self
    }
    
    /// Defines what unit system type should be used to displayed the length. Defaults to UnitSystemType.system.
    /// - Parameter type: type of the unit system
    /// - Returns: updated builder
    public func unitSystem(_ type: UnitSystemType) -> LocationRadiusPickerConfigurationBuilder {
        configuration.unitSystem = type
        return self
    }
    
    /// Builds the configuration from the configured builder
    /// - Returns: configuration for the location radius picker
    public func build() -> LocationRadiusPickerConfiguration {
        configuration
    }
}
