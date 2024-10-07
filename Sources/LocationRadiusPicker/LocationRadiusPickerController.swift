//
//  LocationRadiusPickerController.swift
//
//
//  Created by Eman Basic on 08.09.24.
//

import Contacts
import MapKit
import UIKit

public final class LocationRadiusPickerController: UIViewController {
    
    // MARK: - Views
    
    private lazy var mapView: MKMapView = {
        let view = MKMapView()
        view.showsUserLocation = false
        view.delegate = self
        view.isPitchEnabled = false
        view.isRotateEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var circleView: UIView = {
        let view = UIView()
        view.layer.borderColor = configuration.radiusBorderColor.cgColor
        view.layer.borderWidth = configuration.radiusBorderWidth
        view.backgroundColor = configuration.radiusColor
        view.isHidden = true
        return view
    }()
    
    private lazy var grabberView: UIView = {
        let view = UIView()
        view.backgroundColor = configuration.grabberColor
        view.layer.cornerRadius = configuration.grabberSize / 2
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleGrabberViewPan(_:))))
        view.isHidden = true
        return view
    }()
    
    private lazy var radiusLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        view.textColor = configuration.radiusLabelColor
        view.isHidden = true
        return view
    }()
    
    private lazy var saveButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.buttonSize = .large
        config.title = configuration.saveButtonTitle
        config.cornerStyle = configuration.saveButtonCornerStyle
        config.baseBackgroundColor = configuration.saveButtonBackgroundColor
        config.baseForegroundColor = configuration.saveButtonTextColor
        config.titleAlignment = .center
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 17, weight: .bold)
            return outgoing
        }
        
        let view = UIButton(configuration: config)
        view.addAction(UIAction { [unowned self] _ in
            let result = LocationRadiusPickerResult(
                location: currentLocation.toCoordinates(),
                radius: currentRadius,
                geolocation: currentLocation.address
            )
            
            completion(result)
            popOrDismissPicker()
        }, for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Private properties
        
    private let isMetricSystem: Bool
    private let completion: (_ result: LocationRadiusPickerResult) -> (Void)
    
    private let geocoder = CLGeocoder()
    private let historyManager = LocationSearchHistoryManager()
    
    private var circle: MKCircle

    private var isFirstMapRender = true
    private var circleCenterBeforePan: CGPoint = .zero
    private var grabberCenterBeforePan: CGPoint = .zero
    private var radiusBeforePan = 0.0
    private var currentMetersPerPixel = 0.0
    private var selectedAnnotation: (any MKAnnotation)?
    private var localSearch: MKLocalSearch?
    private var searchTimer: Timer?

    private var currentRadius: CLLocationDistance {
        didSet {
            updateRadiusLabel(with: currentRadius)
        }
    }
    
    private var currentLocation: Location {
        didSet {
            saveButton.configuration?.subtitle = currentLocation.address
        }
    }
    
    private lazy var searchResultsController: LocationSearchResultsController = {
        let headerText = configuration.showSearchHistory ? configuration.historyHeaderText : ""
        
        let results = LocationSearchResultsController(previouslySearchedText: headerText)
        results.onSelectLocation = { [weak self] location in
            guard let self else { return }
            
            dismiss(animated: true)
            mapView.removeOverlay(circle)
            
            currentLocation = location
            circle = MKCircle(center: location.toCoordinates(), radius: currentRadius)
            mapView.addOverlay(circle)
            setVisibleMapRegionForCircle()
            searchBar.text = ""
            
            historyManager.addToHistory(location)
        }
        
        results.onDeleteLocation = { [weak self] location in
            self?.historyManager.remove(location)
        }
        
        return results
    }()
    
    private lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: self.searchResultsController)
        search.searchResultsUpdater = self
        search.hidesNavigationBarDuringPresentation = false
        return search
    }()
    
    private lazy var searchBar: UISearchBar = {
        let view = searchController.searchBar
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Public properties
    
    public let configuration: LocationRadiusPickerConfiguration
    
    // MARK: - Init
    
    public init(configuration: LocationRadiusPickerConfiguration, completion: @escaping (_ result: LocationRadiusPickerResult) -> (Void)) {
        self.configuration = configuration
        self.completion = completion
        
        currentLocation = Location(name: "", address: "", longitude: configuration.location.longitude, latitude: configuration.location.latitude)
        currentRadius = configuration.radius
        circle = MKCircle(center: configuration.location, radius: configuration.radius)
        
        isMetricSystem = switch configuration.unitSystem {
            case .metric: true
            case .imperial: false
            case .system: UnitSystemType.current == .metric
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }
}

// MARK: - Lifecycle

extension LocationRadiusPickerController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
}

// MARK: - Setup

extension LocationRadiusPickerController {
    private func setup() {
        setupNavigationBar()
        setupSubviews()
        setupConstraints()
        
        // fetch geolocation for initial location
        fetchGeolocation(for: currentLocation.toCoordinates()) { [weak self] geolocation in
            self?.currentLocation.address = geolocation
        }
    }
    
    private func setupNavigationBar() {
        title = configuration.title
        
        if configuration.overrideNavigationBarAppearance {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.tintColor = .label
        }
        
        let cancelButton = UIBarButtonItem(
            title: configuration.navigationBarCancelButtonTitle,
            style: .plain,
            target: self,
            action: #selector(onCancelButtonPressed)
        )
        
        navigationItem.setLeftBarButton(cancelButton, animated: false)
        
        if configuration.showNavigationBarSaveButton {
            let saveButton = UIBarButtonItem(
                title: configuration.navigationBarSaveButtonTitle,
                style: .plain,
                target: self,
                action: #selector(onSaveButtonPressed)
            )
            
            navigationItem.setRightBarButton(saveButton, animated: false)
        }
        
        if configuration.searchFunctionality {
            navigationItem.searchController = searchController
            searchBar.placeholder = configuration.searchBarPlaceholder
        }
    }
    
    private func setupSubviews() {
        view.addSubview(mapView)
        
        if configuration.showSaveButton {
            view.addSubview(saveButton)
        }
        
        mapView.addOverlay(circle)
        setVisibleMapRegionForCircle()
        
        // gesture for long press to select location
        let locationSelectGesture = UILongPressGestureRecognizer(target: self, action: #selector(onMapLongPressed(_:)))
        locationSelectGesture.delegate = self
        mapView.addGestureRecognizer(locationSelectGesture)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        if configuration.showSaveButton {
            NSLayoutConstraint.activate([
                saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30)
            ])
        }
    }
}

// MARK: - Map

extension LocationRadiusPickerController: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circleOverlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: circleOverlay)
            circleRenderer.fillColor = configuration.radiusColor
            circleRenderer.strokeColor = configuration.radiusBorderColor
            circleRenderer.lineWidth = configuration.radiusBorderWidth
            return circleRenderer
        }
        
        return MKOverlayRenderer()
    }
    
    public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        hideGrabberView()
    }
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        showGrabberView()
    }
    
    public func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        guard fullyRendered, isFirstMapRender else { return }
        
        isFirstMapRender = false
        
        let locationInMap = mapView.convert(circle.coordinate, toPointTo: view)
        let region = MKCoordinateRegion(circle.boundingMapRect)
        let diameter =  mapView.convert(region, toRectTo: view).width
        
        circleView.frame = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        circleView.center = locationInMap
        circleView.layer.cornerRadius = diameter / 2
        view.addSubview(circleView)
        
        grabberView.frame = CGRect(x: 0, y: 0, width: configuration.grabberSize, height: configuration.grabberSize)
        grabberView.center = locationInMap
        grabberView.center.x += diameter / 2
        view.addSubview(grabberView)
        
        updateRadiusLabel(with: currentRadius)
        setRadiusLabelFrame()
        view.addSubview(radiusLabel)
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        let pin = MKAnnotationView(annotation: annotation, reuseIdentifier: CustomMapPinAnnotationView.reuseIdentifier)
        pin.image = configuration.mapPinImage ?? UIImage(resource: .defaultMapPin)
        pin.canShowCallout = true
        pin.rightCalloutAccessoryView = selectLocationButton()
        return pin
    }
    
    public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let selectedAnnotation else { return }
        
        mapView.removeOverlay(circle)

        currentLocation.latitude = selectedAnnotation.coordinate.latitude
        currentLocation.longitude = selectedAnnotation.coordinate.longitude
        
        if let title = selectedAnnotation.title {
            currentLocation.address = title ?? ""
        } else {
            currentLocation.address = ""
        }
        
        circle = MKCircle(center: selectedAnnotation.coordinate, radius: currentRadius)
        mapView.addOverlay(circle)
        setVisibleMapRegionForCircle()
        
        mapView.removeAnnotation(selectedAnnotation)
    }
    
    private func setVisibleMapRegionForCircle() {
        let padding = currentRadius * configuration.circlePadding
        let paddedRect = circle.boundingMapRect.insetBy(dx: -padding, dy: -padding)
        mapView.setVisibleMapRect(paddedRect, edgePadding: .zero, animated: false)
        
        showGrabberView()
    }
    
    private func getCurrentMetersPerPixel() -> Double {
        let mapWidthInPixels = mapView.frame.size.width
        let centerLatitude = mapView.region.center.latitude
        let centerLongitude = mapView.region.center.longitude
        let leftLongitude = centerLongitude - mapView.region.span.longitudeDelta / 2
        let rightLongitude = centerLongitude + mapView.region.span.longitudeDelta / 2
    
        let leftCoordinate = CLLocation(latitude: centerLatitude, longitude: leftLongitude)
        let rightCoordinate = CLLocation(latitude: centerLatitude, longitude: rightLongitude)
        
        let distanceInMeters = leftCoordinate.distance(from: rightCoordinate)
        return distanceInMeters / Double(mapWidthInPixels)
    }
    
    func selectLocationButton() -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 30))
        button.setTitle(configuration.calloutSelectButtonText, for: UIControl.State())
        button.setTitleColor(configuration.calloutSelectButtonTextColor, for: UIControl.State())
        
        if let titleLabel = button.titleLabel {
            let width = titleLabel.textRect(forBounds: CGRect(x: 0, y: 0, width: Int.max, height: 30), limitedToNumberOfLines: 1).width
            button.frame.size = CGSize(width: width, height: 30.0)
        }
        
        return button
    }
}

// MARK: - Circle & Grabber view

extension LocationRadiusPickerController {
    private func showCircleViewWhileResizing() {
        let locationInMap = mapView.convert(circle.coordinate, toPointTo: view)
        let diameter = mapView.convert(MKCoordinateRegion(circle.boundingMapRect), toRectTo: view).width
        
        circleView.center = locationInMap
        circleView.frame.size = CGSize(width: diameter, height: diameter)
        circleView.layer.cornerRadius = diameter / 2
        circleView.isHidden = false
        
        mapView.removeOverlay(circle)
    }
    
    private func showGrabberView() {
        let locationInMap = mapView.convert(circle.coordinate, toPointTo: view)
        let diameter = mapView.convert(MKCoordinateRegion(circle.boundingMapRect), toRectTo: view).width
        
        grabberView.center = locationInMap
        grabberView.center.x += diameter / 2
        UIView.transition(with: self.grabberView, duration: 0.3, options: .transitionCrossDissolve) {
            self.grabberView.isHidden = false
        }
                
        setRadiusLabelFrame()
        UIView.transition(with: radiusLabel, duration: 0.3, options: .transitionCrossDissolve) {
            self.radiusLabel.isHidden = false
        }
    }
    
    private func hideGrabberView() {
        grabberView.isHidden = true
        radiusLabel.isHidden = true
    }
    
    private func setRadiusLabelFrame() {
        let width = radiusLabel.textRect(forBounds: CGRect(x: 0, y: 0, width: Int.max, height: 30), limitedToNumberOfLines: 1).width
        radiusLabel.frame.size = CGSize(width: width, height: 30.0)
        radiusLabel.center = CGPoint(x: grabberView.center.x - width, y: grabberView.center.y)
    }
}

// MARK: - Action

extension LocationRadiusPickerController {
    @objc private func onCancelButtonPressed() {
        popOrDismissPicker()
    }
    
    @objc private func onSaveButtonPressed() {
        let result = LocationRadiusPickerResult(
            location: currentLocation.toCoordinates(),
            radius: currentRadius,
            geolocation: currentLocation.address
        )
        
        completion(result)
        popOrDismissPicker()
    }
    
    @objc private func onMapLongPressed(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        if let selectedAnnotation {
            mapView.removeAnnotation(selectedAnnotation)
        }
        
        let coordinates = mapView.convert(gesture.location(in: mapView), toCoordinateFrom: mapView)

        fetchGeolocation(for: coordinates) { [weak self] geolocation in
            guard let self, let annotation = CustomMapPinAnnotationView.add(to: mapView, coordinate: coordinates, title: geolocation) else {
                return
            }
            
            mapView.selectAnnotation(annotation, animated: true)
            selectedAnnotation = annotation
        }
    }
    
    @objc private func handleGrabberViewPan(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            circleCenterBeforePan = mapView.convert(circle.coordinate, toPointTo: view)
            grabberCenterBeforePan = grabberView.center
            currentMetersPerPixel = getCurrentMetersPerPixel()
            radiusBeforePan = currentRadius
            showCircleViewWhileResizing()
        }

        let newGrabberPosition = min(view.frame.width - 10, max(circleCenterBeforePan.x + 10, gesture.location(in: view).x)) - 3
        let increaseInMeters = (newGrabberPosition - grabberCenterBeforePan.x) * currentMetersPerPixel
        let newRadius = radiusBeforePan + increaseInMeters
        
        if newRadius < configuration.minimumRadius {
            // keep it at the minimum radius
            grabberView.center.x = circleCenterBeforePan.x + configuration.minimumRadius / currentMetersPerPixel
            currentRadius = configuration.minimumRadius
        } else if newRadius > configuration.maximumRadius {
            // keep it at the maximum radius
            grabberView.center.x = circleCenterBeforePan.x + configuration.maximumRadius / currentMetersPerPixel
            currentRadius = configuration.maximumRadius
        } else {
            // allow resize
            grabberView.center.x = newGrabberPosition
            currentRadius = newRadius
            
            if configuration.vibrateOnResize, newRadius.truncatingRemainder(dividingBy: 3).rounded() == 0 {
                // vibrate on pan
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
        
        setRadiusLabelFrame()
        
        let diameter = (grabberView.center.x + 2 - circleCenterBeforePan.x) * 2
        circleView.frame.size = CGSize(width: diameter, height: diameter)
        circleView.center = circleCenterBeforePan
        circleView.layer.cornerRadius = diameter / 2
                
        if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            grabberView.isHidden = true
            radiusLabel.isHidden = true
            circle = MKCircle(center: currentLocation.toCoordinates(), radius: currentRadius)
            mapView.addOverlay(circle)
            circleView.isHidden = true
            setVisibleMapRegionForCircle()
        }
    }
}

// MARK: - Geolocation

extension LocationRadiusPickerController {
    private func fetchGeolocation(for coordinates: CLLocationCoordinate2D, completion: @escaping (String) -> Void) {
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        
        geocoder.cancelGeocode()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error as NSError?, error.code != CLError.Code.geocodeCanceled.rawValue {
                // only ignore geocode cancelled errors, but stop on other errors
                return
            }
            
            guard let placemark = placemarks?.first else { return }
            
            let address = {
                guard let postalAddress = placemark.postalAddress else {
                    return "\(coordinates.latitudeToString()), \(coordinates.longitudeToString())"
                }
                
                return CNPostalAddressFormatter().string(from: postalAddress)
                    .split(separator: "\n")
                    .joined(separator: ", ")
            }()
                        
            DispatchQueue.main.async {
                completion(address)
            }
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension LocationRadiusPickerController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        false
    }
}

// MARK: - Searching

extension LocationRadiusPickerController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        guard let term = searchController.searchBar.text else { return }
        
        searchTimer?.invalidate()

        let searchTerm = term.trimmingCharacters(in: CharacterSet.whitespaces)
        
        if searchTerm.isEmpty {
            searchResultsController.locations = configuration.showSearchHistory ? historyManager.history() : []
            searchResultsController.isShowingHistory = true
            searchResultsController.tableView.reloadData()
            return
        }
        
        showItemsForSearchResult(nil)
        
        searchTimer = Timer.scheduledTimer(
            timeInterval: 0.2,
            target: self, selector: #selector(searchFromTimer(_:)),
            userInfo: ["SearchTermKey": searchTerm],
            repeats: false
        )
    }
    
    @objc func searchFromTimer(_ timer: Timer) {
        guard let userInfo = timer.userInfo as? [String: AnyObject], let term = userInfo["SearchTermKey"] as? String else { return }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = term
        
        localSearch?.cancel()
        localSearch = MKLocalSearch(request: request)
        localSearch!.start { response, _ in
            self.showItemsForSearchResult(response)
        }
    }
    
    func showItemsForSearchResult(_ searchResult: MKLocalSearch.Response?) {
        searchResultsController.locations = searchResult?.mapItems.map { resultItem in
            let latitude = resultItem.placemark.coordinate.latitude
            let longitude = resultItem.placemark.coordinate.longitude
            
            let description = {
                guard let postalAddress = resultItem.placemark.postalAddress else {
                    return "\(latitude), \(longitude)"
                }
                
                return CNPostalAddressFormatter().string(from: postalAddress)
                    .split(separator: "\n")
                    .joined(separator: ", ")
            }()
            
            return Location(
                name: resultItem.name ?? "",
                address: description,
                longitude: longitude,
                latitude: latitude
            )
        } ?? []
        
        searchResultsController.isShowingHistory = false
        searchResultsController.tableView.reloadData()
    }
}

// MARK: - Search bar delegate

extension LocationRadiusPickerController: UISearchBarDelegate {
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if let text = searchBar.text, text.isEmpty {
            // forces the history to be visible when user clicks on the search bar
            searchBar.text = " "
        }
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // forces the history to be visible as long as the focus is on the search bar
            searchBar.text = " "
        }
    }
}

// MARK: - Helper

extension LocationRadiusPickerController {
    private func popOrDismissPicker() {
        if let navigationController, navigationController.viewControllers.count > 1 {
            // view controller has been pushed onto the navigation stack
            navigationController.popViewController(animated: true)
            return
        }
            
        // view controller has been presented
        presentingViewController?.dismiss(animated: true)
    }
    
    private func updateRadiusLabel(with radius: Double) {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .medium
        formatter.unitOptions = .naturalScale
        
        if isMetricSystem {
            formatter.numberFormatter.maximumFractionDigits = radius >= 1000 ? 1 : 0
        } else {
            formatter.locale = Locale(identifier: "en_US")
            formatter.numberFormatter.maximumFractionDigits = radius >= 804 ? 1 : 0
        }
        
        let measurement = Measurement<UnitLength>(value: currentRadius, unit: .meters)
        radiusLabel.text = formatter.string(from: measurement)
    }
}

// MARK: - Preview

@available(iOS 17.0, *)
#Preview {
    let config = LocationRadiusPickerConfigurationBuilder(initialRadius: 300, minimumRadius: 30, maximumRadius: 4000)
        .unitSystem(.metric)
        .circlePadding(10)
        .build()
    
    let picker = LocationRadiusPickerController(configuration: config) { result in
        print(result)
    }
    
    return UINavigationController(rootViewController: picker)
}
