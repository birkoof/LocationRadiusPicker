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
    ///   - initialRadius: the initial radius (in meters) the circle will be set to
    ///   - minimumRadius: minimum allowed radius (in meters) the circle can shrink to
    ///   - maximumRadius: maximum allowed radius (in meters) the circle can expand to
    ///
    /// - Note: If the initial radius is outside the range [min, max], the value will be capped to fit that interval.
    public init(initialRadius: Double, minimumRadius: Double, maximumRadius: Double) {
        configuration = LocationRadiusPickerConfiguration(radius: initialRadius, minimumRadius: minimumRadius, maximumRadius: maximumRadius)
    }
    
    /// The title of the picker, shown on the navigation bar.
    /// - Parameter title: title of the picker
    /// - Returns: updated builder
    ///
    /// - Note: Default value: **"Location Radius Picker"** (not localised).
    public func title(_ title: String) -> LocationRadiusPickerConfigurationBuilder {
        configuration.title = title
        return self
    }
    
    /// The title of the save button, located on the navigation bar.
    /// - Parameter title: title of the save button
    /// - Returns: updated builder
    ///
    /// - Note: Default value: **"Save"** (not localised).
    public func saveButtonTitle(_ title: String) -> LocationRadiusPickerConfigurationBuilder {
        configuration.saveButtonTitle = title
        return self
    }
    
    /// The title of the cancel button, located on the navigation bar.
    /// - Parameter title: title of the cancel button
    /// - Returns: updated builder
    ///
    /// - Note: Default value: **"Cancel"** (not localised).
    public func cancelButtonTitle(_ title: String) -> LocationRadiusPickerConfigurationBuilder {
        configuration.cancelButtonTitle = title
        return self
    }
    
    /// Initial location where the circle will be placed on the map.
    /// - Parameter location: location coordinates of the circle
    /// - Returns: updated builder
    ///
    /// - Note: Default value: **Apple Inc. - Infinite Loop Campus** (Lat: 37.331711, Lon: -122.030773)
    public func initialLocation(_ location: CLLocationCoordinate2D) -> LocationRadiusPickerConfigurationBuilder {
        configuration.location = location
        return self
    }
    
    /// Color of the radius circle border.
    /// - Parameter color: color of the radius circle border
    /// - Returns: updated builder
    ///
    /// - Note: Default value: `UIColor.systemBlue`
    public func radiusBorderColor(_ color: UIColor) -> LocationRadiusPickerConfigurationBuilder {
        configuration.radiusBorderColor = color
        return self
    }
    
    /// Width of the radius circle border.
    /// - Parameter width: width of the radius circle border
    /// - Returns: updated builder
    ///
    /// - Note: Default value: `3.0`
    public func radiusBorderWidth(_ width: Double) -> LocationRadiusPickerConfigurationBuilder {
        configuration.radiusBorderWidth = width
        return self
    }
    
    /// Fill color of the radius circle.
    /// - Parameter color: Color of the radius circle
    /// - Returns: updated builder
    ///
    /// - Note: Default value: `UIColor.systemBlue.withAlphaComponent(0.2)`
    public func radiusColor(_ color: UIColor) -> LocationRadiusPickerConfigurationBuilder {
        configuration.radiusColor = color
        return self
    }
    
    /// Color of the radius label, which displays the current radius size.
    /// - Parameter color: text color of the radius label
    /// - Returns: updated builder
    ///
    /// - Note: Default value: `UIColor.label`
    public func radiusLabelColor(_ color: UIColor) -> LocationRadiusPickerConfigurationBuilder {
        configuration.radiusLabelColor = color
        return self
    }
    
    /// Color of the radius grabber (small circle with a pan gesture that resizes the radius).
    /// - Parameter color: color of the radius grabber
    /// - Returns: updated builder
    ///
    /// - Note: Default value: `UIColor.systemBlue`
    public func grabberColor(_ color: UIColor) -> LocationRadiusPickerConfigurationBuilder {
        configuration.grabberColor = color
        return self
    }
    
    /// Size of the grabber view (small circle with a pan gesture that resizes the radius). Aspect ratio is 1:1.
    /// - Parameter size: size of the grabber view
    /// - Returns: updated builder
    ///
    /// - Note: Default value: `20.0`
    public func grabberSize(_ size: CGFloat) -> LocationRadiusPickerConfigurationBuilder {
        configuration.grabberSize = size
        return self
    }
    
    /// Enables/disables the vibration effect when resizing the radius circle.
    /// - Parameter vibrate: enables vibration if set to true, otherwise disables it.
    /// - Returns: updated builder
    ///
    /// - Note: Default value: `true`
    public func vibrateOnResize(_ vibrate: Bool) -> LocationRadiusPickerConfigurationBuilder {
        configuration.vibrateOnResize = vibrate
        return self
    }
    
    /// Defines what unit system type should be used to displayed the length.
    /// - Parameter type: type of the unit system
    /// - Returns: updated builder
    ///
    /// - Note: Default value: `UnitSystemType.system`
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
