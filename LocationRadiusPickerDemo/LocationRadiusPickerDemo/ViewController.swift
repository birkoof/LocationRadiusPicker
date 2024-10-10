//
//  ViewController.swift
//  LocationRadiusPickerDemo
//
//  Created by Eman Basic on 08.09.24.
//

import LocationRadiusPicker
import UIKit
import MapKit

struct LocationRadiusModel: Hashable, Equatable {
    var id: UUID = UUID()
    var latitude: Double
    var longitude: Double
    var radius: Double
    var name: String
}

class ViewController: UIViewController {
    
    // MARK: - Views
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.register(UITableViewCell.self, forCellReuseIdentifier: "LocationCell")
        view.delegate = self
        view.contentInset.bottom = 100
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var pickLocationButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.background.backgroundColor = .systemBlue
        config.title = "Pick a location"
        config.cornerStyle = .capsule
        config.buttonSize = .large
        
        let view = UIButton(configuration: config)
        view.addAction(UIAction { [unowned self] _ in
            openLocationRadiusPicker()
        }, for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emptyViewTitleLabel: UILabel = {
        let view = UILabel()
        view.text = "Tap to add"
        view.font = .systemFont(ofSize: 20, weight: .semibold)
        view.textAlignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emptyViewArrowImage: UIImageView = {
        let view = UIImageView(image: UIImage(resource: .arrow))
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Private properties
    
    private let radiusFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .medium
        formatter.unitOptions = .naturalScale
        formatter.numberFormatter.maximumFractionDigits = 1
        return formatter
    }()
    
    private lazy var dataSource: UITableViewDiffableDataSource<Int, LocationRadiusModel> = UITableViewDiffableDataSource(tableView: tableView) { [unowned self] tableView, indexPath, item in
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        
        var config = UIListContentConfiguration.valueCell()
        config.text = item.name
        config.secondaryText = radiusFormatter.string(from: Measurement<UnitLength>(value: item.radius, unit: .meters))
        
        cell.contentConfiguration = config
        return cell
    }
    
    private var items = [LocationRadiusModel]()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
     
        setup()
    }
}

// MARK: - Setup

extension ViewController {
    private func setup() {
        title = "Location Radius Picker Demo"
        
        view.addSubview(tableView)
        view.addSubview(emptyViewTitleLabel)
        view.addSubview(emptyViewArrowImage)
        view.addSubview(pickLocationButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            emptyViewArrowImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyViewArrowImage.bottomAnchor.constraint(equalTo: pickLocationButton.topAnchor),
            emptyViewArrowImage.heightAnchor.constraint(equalTo: tableView.heightAnchor, multiplier: 0.4),
            
            emptyViewTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyViewTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyViewTitleLabel.bottomAnchor.constraint(equalTo: emptyViewArrowImage.topAnchor, constant: -10),
            
            pickLocationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickLocationButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            pickLocationButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            pickLocationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
        
        applySnapshot()
    }
}

// MARK: - Table view

extension ViewController: UITableViewDelegate {
    private func applySnapshot(animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, LocationRadiusModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(items)
        
        emptyViewArrowImage.isHidden = !items.isEmpty
        emptyViewTitleLabel.isHidden = !items.isEmpty
        
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            guard let self else { return }
            
            if let item = dataSource.itemIdentifier(for: indexPath) {
                items.removeAll { $0 == item }
                applySnapshot()
            }
            
            completionHandler(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openLocationRadiusPicker(item: dataSource.itemIdentifier(for: indexPath))
    }
}

// MARK: - Action

extension ViewController {
    private func openLocationRadiusPicker(item: LocationRadiusModel? = nil) {
        let initialCoordinates = {
            if let item {
                return LocationCoordinates(latitude: item.latitude, longitude: item.longitude)
            }
            
            return LocationCoordinates(latitude: 37.331711, longitude: -122.030773)
        }()
        
        let configuration = LocationRadiusPickerConfigurationBuilder(initialRadius: item?.radius ?? 100, minimumRadius: 50, maximumRadius: 2000)
            .title("Location Radius Picker")
            .navigationBarSaveButtonTitle("Save")
            .showNavigationBarSaveButton(true)
            .cancelButtonTitle("Cancel")
            .initialLocation(initialCoordinates)
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
        
        let picker = LocationRadiusPickerController(configuration: configuration) { [weak self] result in
            var newItem = LocationRadiusModel(
                latitude: result.location.coordinates.latitude,
                longitude: result.location.coordinates.longitude,
                radius: result.radius,
                name: result.location.address
            )
            
            if let item, let index = self?.items.firstIndex(of: item) {
                // update
                newItem.id = item.id
                self?.items[index] = newItem
                self?.applySnapshot(animated: false)
            } else {
                // create
                self?.items.append(newItem)
                self?.applySnapshot()
            }
        }
        
        // navigationController?.pushViewController(picker, animated: true)
        present(UINavigationController(rootViewController: picker), animated: true)
    }
}
