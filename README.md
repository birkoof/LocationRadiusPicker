# LocationRadiusPicker

## Overview

**Location Radius Picker** is an open-source `UIViewController` subclass that allows users to select a specific location on a map and define a radius around it. The picker is highly customizable and includes integrated location search functionality, making it ideal for apps that require location-based features.

![](https://github.com/birkoof/LocationRadiusPicker/blob/main/demo.gif)

## Example Use Case

When scheduling location-based reminders using [UNLocationNotificationTrigger](https://developer.apple.com/documentation/usernotifications/unlocationnotificationtrigger), the picker can be used to pick a geographic region for which the user should be reminded upon arrival/departure.

## Features

- **Resizable circle radius** - Easily adjust the radius around a selected location.
- **Location search** - Bult-in search functionality, including search history for quick access.
- **Long press selection** - Users can long-press on the map to select a location.
- **Metric and imperial units** - Full support for both unit systems
- **Customizability** - Highly customizable appearance and behavior to fit your app's design and functionality.

## System requirements
- iOS 15.0 or later

## Installation

You can integrate Location Radius Picker using either of the following methods:
1. **Swift Package Manager**
- Add the following to your Package.swift
```
dependencies: [
  // ...
  .package(url: "https://github.com/birkoof/LocationRadiusPicker.git"),
],
```

2. **Manual Installation**
- Copy the source files to your project.

## Example Usage

Using **Location Radius Picker** is simple. First, build the configuration using the `LocationRadiusPickerConfigrationBuilder` and pass it to the initializer. You can choose whether to present or push the view controller.

**Note**: If you choose to push the view controller, you can disable the navigation bar appearance override by calling `overrideNavigationBarAppearance(false)` on the builder. This ensures the picker has the same navigation bar appearance as the view controller that is pushing it.

**Note**: If you choose to present the picker, make sure to wrap the picker with a UINavigationController.

```swift
let configuration = LocationRadiusPickerConfigurationBuilder(initialRadius: 100, minimumRadius: 50, maximumRadius: 2000)
        .title("Location Radius Picker")
        .navigationBarSaveButtonTitle("Save")
        .showNavigationBarSaveButton(true)
        .cancelButtonTitle("Cancel")
        .initialLocation(LocationCoordinates(latitude: 37.331711, longitude: -122.030773))
        .radiusBorderColor(.systemBlue)
        .radiusBorderWidth(3)
        .radiusColor(.systemBlue.withAlphaComponent(0.3))
        .radiusLabelColor(.label)
        .grabberColor(.systemBlue)
        .grabberSize(20)
        .unitSystem(.system)
        .vibrateOnResize(true)
        .circlePadding(17)
        .overrideNavigationBarAppearance(true)
        .mapPinImage(UIImage(resource: .mapPin))
        .calloutSelectButtonText("Select")
        .calloutSelectButtonTextColor(.systemBlue)
        .showSaveButton(true)
        .saveButtonTitle("Select location")
        .saveButtonBackgroundColor(.systemBlue)
        .saveButtonTextColor(.white)
        .saveButtonCornerStyle(.capsule)
        .searchFunctionality(true)
        .showSearchHistory(true)
        .historyHeaderText("Previously searched")
        .searchBarPlaceholder("Search or Enter Address")
        .build()

let picker = LocationRadiusPickerController(configuration: configuration) { result in
        let radius = result.radius
        let locationName = result.location.name
        let locationAddress = result.location.address
        let locationCenterLatitude = result.location.coordinates.latitude
        let locationCenterLongitude = result.location.coordinates.longitude
    
        // ... do something with the result
}

// if presenting, make sure to wrap the picker with a UINavigationController
present(UINavigationController(rootViewController: picker), animated: true)
```

All configuration options are optional, except for the **initial**, **minimum**, and **maximum radius** values, which are required.

**Note**: If the initial radius is outside the specified range (between the minimum and maximum values), it will automatically be adjusted to fit within the valid range.

For a fully functional example, check out the [demo app](https://github.com/birkoof/LocationRadiusPicker/blob/main/LocationRadiusPickerDemo/LocationRadiusPickerDemo/ViewController.swift) included in this repository.

## License

**LocationRadiusPicker** is licensed under the [MIT License](https://github.com/birkoof/LocationRadiusPicker/blob/main/LICENSE).
