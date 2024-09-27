//
//  LocationRadiusPickerController.swift
//
//
//  Created by Eman Basic on 08.09.24.
//

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
    
    // MARK: - Private properties
        
    private let isMetricSystem: Bool
    
    private var circle: MKCircle
    private var currentLocation: CLLocationCoordinate2D
    private var completion: (_ result: LocationRadiusPickerResult) -> (Void)

    private var currentGeolocation: String = ""
    private var isFirstMapRender = true
    private var circleCenterBeforePan: CGPoint = .zero
    private var grabberCenterBeforePan: CGPoint = .zero
    private var radiusBeforePan = 0.0
    private var currentMetersPerPixel = 0.0
    private var selectedAnnotation: (any MKAnnotation)?

    private var currentRadius: CLLocationDistance {
        didSet {
            updateRadiusLabel(with: currentRadius)
        }
    }
    
    // MARK: - Public properties
    
    public let configuration: LocationRadiusPickerConfiguration
    
    // MARK: - Init
    
    public init(configuration: LocationRadiusPickerConfiguration, completion: @escaping (_ result: LocationRadiusPickerResult) -> (Void)) {
        self.configuration = configuration
        self.completion = completion
        
        currentLocation = configuration.location
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
            title: configuration.cancelButtonTitle,
            style: .plain,
            target: self,
            action: #selector(onCancelButtonPressed)
        )
        
        navigationItem.setLeftBarButton(cancelButton, animated: false)
        
        let saveButton = UIBarButtonItem(
            title: configuration.saveButtonTitle,
            style: .plain,
            target: self,
            action: #selector(onSaveButtonPressed)
        )
        
        navigationItem.setRightBarButton(saveButton, animated: false)
    }
    
    private func setupSubviews() {
        view.addSubview(mapView)
        
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
        pin.image = UIImage(resource: .defaultMapPin) // TODO: add to configuration
        pin.canShowCallout = true
        pin.rightCalloutAccessoryView = selectLocationButton()
        return pin
    }
    
    public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let selectedAnnotation else { return }
        
        mapView.removeOverlay(circle)

        currentLocation = selectedAnnotation.coordinate
        if let title = selectedAnnotation.title {
            currentGeolocation = title ?? ""
        }
        
        circle = MKCircle(center: currentLocation, radius: currentRadius)
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
        
        // TODO: add title and text color to configuration
        button.setTitle("Select", for: UIControl.State())
        button.setTitleColor(configuration.radiusBorderColor, for: UIControl.State())
        
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
        let result = LocationRadiusPickerResult(location: currentLocation, radius: currentRadius, geolocation: currentGeolocation)
        completion(result)
        popOrDismissPicker()
    }
    
    @objc private func onMapLongPressed(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        if let selectedAnnotation {
            mapView.removeAnnotation(selectedAnnotation)
        }
        
        let coordinates = mapView.convert(gesture.location(in: mapView), toCoordinateFrom: mapView)

        if let annotation = CustomMapPinAnnotationView.add(
            to: mapView,
            coordinate: coordinates,
            title: "Street 123b" // TODO: fetch & store geolocation here
        ) {
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
            circle = MKCircle(center: currentLocation, radius: currentRadius)
            mapView.addOverlay(circle)
            circleView.isHidden = true
            setVisibleMapRegionForCircle()
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
