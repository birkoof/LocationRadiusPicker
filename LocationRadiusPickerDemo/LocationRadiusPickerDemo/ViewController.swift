//
//  ViewController.swift
//  LocationRadiusPickerDemo
//
//  Created by Eman Basic on 08.09.24.
//

import LocationRadiusPicker
import UIKit

class ViewController: UIViewController {
    
    // MARK: - Views
    
    private lazy var openPickerButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.background.backgroundColor = .systemBlue
        config.title = "Open picker"
        
        let view = UIButton(configuration: config)
        view.addAction(UIAction { [unowned self] _ in
            onOpenPickerButtonPressed()
        }, for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
     
        setup()
    }
}

// MARK: - Setup

extension ViewController {
    private func setup() {
        title = "Demo"
        
        view.addSubview(openPickerButton)
        
        NSLayoutConstraint.activate([
            openPickerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openPickerButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - Action

extension ViewController {
    private func onOpenPickerButtonPressed() {
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
            // .mapPinImage(UIImage(named: "mapPin"))
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
            print(result)
        }
        
        // navigationController?.pushViewController(picker, animated: true)
        present(UINavigationController(rootViewController: picker), animated: true)
    }
}
