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
    private var currentGeolocation: String = ""
    private var isFirstMapRender = true
    private var circleCenterBeforePan: CGPoint = .zero
    private var grabberCenterBeforePan: CGPoint = .zero
    private var radiusBeforePan = 0.0
    private var currentMetersPerPixel = 0.0

    private var currentRadius: CLLocationDistance {
        didSet {
            updateRadiusLabel(with: currentRadius)
        }
    }
    
    // MARK: - Public properties
    
    public let configuration: LocationRadiusPickerConfiguration
    
    // MARK: - Init
    
    public init(configuration: LocationRadiusPickerConfiguration) {
        self.configuration = configuration
        currentLocation = configuration.location
        
        // make sure radius is within bounds
        let radius = min(max(configuration.minimumRadius, configuration.radius), configuration.maximumRadius)
        currentRadius = radius
        
        circle = MKCircle(center: configuration.location, radius: radius)
        
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
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.tintColor = .label
        
        let cancelButton = UIBarButtonItem(
            title: configuration.cancelButtonTitle,
            style: .plain,
            target: self,
            action: #selector(onCancelButtonPressed)
        )
        
        navigationItem.setLeftBarButton(cancelButton, animated: false)
    }
    
    private func setupSubviews() {
        view.addSubview(mapView)
        
        mapView.addOverlay(circle)
        setVisibleMapRegionForCircle()
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
    
    private func setVisibleMapRegionForCircle() {
        let padding = currentRadius * 17 // TODO: include padding in the configuration
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
        grabberView.isHidden = false
                
        setRadiusLabelFrame()
        radiusLabel.isHidden = false
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
        dismiss(animated: true)
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

// MARK: - Helper

extension LocationRadiusPickerController {
    private func updateRadiusLabel(with radius: Double) {
        let measurement = Measurement<UnitLength>(value: currentRadius, unit: .meters)

        let formatter = MeasurementFormatter()
        formatter.unitStyle = .medium
        formatter.unitOptions = .naturalScale
        
        if isMetricSystem {
            formatter.numberFormatter.maximumFractionDigits = radius >= 1000 ? 1 : 0
        } else {
            formatter.locale = Locale(identifier: "en_US")
            formatter.numberFormatter.maximumFractionDigits = radius >= 804 ? 1 : 0
        }
        
        radiusLabel.text = formatter.string(from: measurement)
    }
}

// MARK: - Preview

@available(iOS 17.0, *)
#Preview {
    let config = LocationRadiusPickerConfigurationBuilder(initialRadius: 300, minimumRadius: 30, maximumRadius: 4000)
        .unitSystem(.metric)
        .build()
    
    return UINavigationController(rootViewController: LocationRadiusPickerController(configuration: config))
}
