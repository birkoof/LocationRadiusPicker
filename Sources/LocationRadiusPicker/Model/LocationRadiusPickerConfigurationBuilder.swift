//
//  LocationRadiusPickerConfigurationBuilder.swift
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
    /// - Note: Default value: **"Location Radius Picker"** (not localized).
    public func title(_ title: String) -> LocationRadiusPickerConfigurationBuilder {
        configuration.title = title
        return self
    }
    
    /// The title of the save button, located on the navigation bar.
    /// - Parameter title: title of the save button
    /// - Returns: updated builder
    ///
    /// - Note: Default value: **"Save"** (not localized).
    public func navigationBarSaveButtonTitle(_ title: String) -> LocationRadiusPickerConfigurationBuilder {
        configuration.navigationBarSaveButtonTitle = title
        return self
    }
    
    /// Whether the save button on the navigation bar will be displayed.
    /// - Parameter show: shows the button if set to true, otherwise hides it
    /// - Returns: updated builder
    public func showNavigationBarSaveButton(_ show: Bool) -> LocationRadiusPickerConfigurationBuilder {
        configuration.showNavigationBarSaveButton = show
        return self
    }
    
    /// The title of the cancel button, located on the navigation bar.
    /// - Parameter title: title of the cancel button
    /// - Returns: updated builder
    ///
    /// - Note: Default value: **"Cancel"** (not localized).
    public func cancelButtonTitle(_ title: String) -> LocationRadiusPickerConfigurationBuilder {
        configuration.navigationBarCancelButtonTitle = title
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
    
    /// Padding around the radius circle. This value affects the bounding map rect, and is applied in combination with current radius.
    /// - Parameter padding: padding to apply to the circle
    /// - Returns: updated builder
    ///
    /// - Note: Default value is 17. Allowed range is [0, 100].
    public func circlePadding(_ padding: Double) -> LocationRadiusPickerConfigurationBuilder {
        let padding = max(0, min(padding, 100))
        configuration.circlePadding = padding
        return self
    }
    
    /// Whether the controller applies custom appearance for the navigation bar. This should be disabled if you want to keep the navigation bar appearance
    /// from the navigation controller that pushes the LocationRadiusPicker.
    /// - Parameter override: picker applies custom appearance if set to true, otherwise keeps the appearance from the navigation controller that pushes it
    /// - Returns: updated builder
    public func overrideNavigationBarAppearance(_ override: Bool) -> LocationRadiusPickerConfigurationBuilder {
        configuration.overrideNavigationBarAppearance = override
        return self
    }
    
    /// The annotation image displayed when user long presses on a map in order to select a location. If none set, a default image will be used.
    /// - Parameter image: the image to be used on the annotation
    /// - Returns: updated builder
    public func mapPinImage(_ image: UIImage) -> LocationRadiusPickerConfigurationBuilder {
        configuration.mapPinImage = image
        return self
    }
    
    /// The text of the select button on the map callout when user long presses a location.
    /// - Parameter text: text of the button
    /// - Returns: updated builder
    public func calloutSelectButtonText(_ text: String) -> LocationRadiusPickerConfigurationBuilder {
        configuration.calloutSelectButtonText = text
        return self
    }
    
    /// The text color of the select button on the map callout when user long presses a location.
    /// - Parameter color: text color of the button
    /// - Returns: updated builder
    public func calloutSelectButtonTextColor(_ color: UIColor) -> LocationRadiusPickerConfigurationBuilder {
        configuration.calloutSelectButtonTextColor = color
        return self
    }
    
    /// Whether the save button will be shown at the bottom of the controller.
    /// - Parameter show: shows the button if set to true, otherwise hides it
    /// - Returns: updated builder
    public func showSaveButton(_ show: Bool) -> LocationRadiusPickerConfigurationBuilder {
        configuration.showSaveButton = show
        return self
    }
    
    /// Title of the save button.
    /// - Parameter title: title of the save button
    /// - Returns: updated builder
    ///
    /// - Note: Default value: **"Save"** (not localized).
    public func saveButtonTitle(_ title: String) -> LocationRadiusPickerConfigurationBuilder {
        configuration.saveButtonTitle = title
        return self
    }
    
    /// The background color of the save button.
    /// - Parameter color: background color
    /// - Returns: updated builder
    ///
    /// - Note: Default value: **UIColor.systemBlue**.
    public func saveButtonBackgroundColor(_ color: UIColor) -> LocationRadiusPickerConfigurationBuilder {
        configuration.saveButtonBackgroundColor = color
        return self
    }

    /// The text color of the save button.
    /// - Parameter color: text color
    /// - Returns: updated builder
    ///
    /// - Note: Default value: **UIColor.white**.
    public func saveButtonTextColor(_ color: UIColor) -> LocationRadiusPickerConfigurationBuilder {
        configuration.saveButtonTextColor = color
        return self
    }
    
    /// The corner style of the save button.
    /// - Parameter style: corner style
    /// - Returns: updated builder
    ///
    /// - Note: Default value: **UIButton.Configuration.CornerStyle.capsule**.
    public func saveButtonCornerStyle(_ style: UIButton.Configuration.CornerStyle) -> LocationRadiusPickerConfigurationBuilder {
        configuration.saveButtonCornerStyle = style
        return self
    }
    
    /// Whether to enable search functionality
    /// - Parameter show: enables the search functionality if set to true, otherwise disables it
    /// - Returns: updated builder
    public func searchFunctionality(_ enabled: Bool) -> LocationRadiusPickerConfigurationBuilder {
        configuration.searchFunctionality = enabled
        return self
    }
    
    /// Whether to store & show the search history
    /// - Parameter show: enables search history if set to true, otherwise disables it
    /// - Returns: updated builder
    public func showSearchHistory(_ show: Bool) -> LocationRadiusPickerConfigurationBuilder {
        configuration.showSearchHistory = show
        return self
    }
    
    /// Placeholder text for the search bar.
    /// - Parameter text: placeholder text for the search bar
    /// - Returns: updated builder
    public func searchBarPlaceholder(_ text: String) -> LocationRadiusPickerConfigurationBuilder {
        configuration.searchBarPlaceholder = text
        return self
    }
    
    /// Text of the header label that sits above recent searches.
    /// - Parameter text: history header text
    /// - Returns: updated builder
    public func historyHeaderText(_ text: String) -> LocationRadiusPickerConfigurationBuilder {
        configuration.historyHeaderText = text
        return self
    }
    
    /// Builds the configuration from the configured builder
    /// - Returns: configuration for the location radius picker
    public func build() -> LocationRadiusPickerConfiguration {
        // ensure radius is within bounds
        configuration.radius = min(max(configuration.minimumRadius, configuration.radius), configuration.maximumRadius)
        return configuration
    }
}
