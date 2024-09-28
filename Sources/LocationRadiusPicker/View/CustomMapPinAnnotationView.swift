//
//  CustomMapPinAnnotationView.swift
//
//
//  Created by Eman Basic on 26.09.24.
//

import MapKit

final class CustomMapPinAnnotationView: MKPointAnnotation {
    static let reuseIdentifier = "CustomMapPinAnnotationView"
    
    static func add(to mapView: MKMapView, coordinate: CLLocationCoordinate2D, title: String?) -> MKAnnotation? {
        let annotation = Self.init()
        annotation.coordinate = coordinate
        annotation.title = title
        
        let pinAnnotation = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        if let annotation = pinAnnotation.annotation {
            mapView.addAnnotation(annotation)
            return annotation
        }
        
        return nil
    }
    
    static func dequeue(with mapView: MKMapView) -> MKAnnotationView? {
        mapView.dequeueReusableAnnotationView(withIdentifier: Self.reuseIdentifier)
    }
    
    static func create(for annotation: MKAnnotation) -> MKAnnotationView {
        MKAnnotationView(annotation: annotation, reuseIdentifier: Self.reuseIdentifier)
    }
}
