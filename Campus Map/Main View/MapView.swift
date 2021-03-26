//
//  MapView.swift
//  BSU-Map
//
//  Created by Benjamin Keys on 8/24/20.
//  Copyright © 2020 Ben Keys. All rights reserved.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView<Annotation: MKAnnotation>: UIViewRepresentable {
    @Binding private var annotations: [Annotation]
    @Binding private var selectedPlace: Annotation?
    @Binding private var showingPlaceDetailsView: Bool
    @Binding private var showingSearchView: Bool
    private let identifier: ((Annotation) -> String)?
    
    @AppStorage("userTracking") private var showsUserLocation = true
    private let locationManager = CLLocationManager()
    private let locationManagerDelegate = LocationManagerDelagte()
    
    // Set Boundries & Defaults for Camera
    private let cameraBoundary: MKMapView.CameraBoundary
    private let zoom = MKMapView.CameraZoomRange(minCenterCoordinateDistance: 400, maxCenterCoordinateDistance: 10000)
    
    init(
        bounds: MKCoordinateRegion,
        annotations: Binding<[Annotation]>,
        selectedPlace: Binding<Annotation?>,
        showingPlaceDetailsView: Binding<Bool>,
        showingSearchView: Binding<Bool>,
        identifier: ((Annotation) -> String)?
    ) {
        guard let cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: bounds) else { fatalError() }
        self.cameraBoundary = cameraBoundary
        self._annotations = annotations
        self._selectedPlace = selectedPlace
        self._showingPlaceDetailsView = showingPlaceDetailsView
        self._showingSearchView = showingSearchView
        self.identifier = identifier
    }
    
    
    // Create MapView (required by UIViewRepresentable)
    func makeUIView(context: Context) -> MKMapView {    // Context = UIViewRepresentableContext<MapView>
        let mapView = MKMapView()
        mapView.delegate = context.coordinator // link coordinator to MapView
        // apply camera rules
        mapView.cameraZoomRange = zoom
        mapView.cameraBoundary = cameraBoundary
        // track user location
        let status = locationManager.authorizationStatus
        if status != .authorizedAlways || status != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
        var defaultViewCenter: CLLocationCoordinate2D
        if let coordinate: CLLocationCoordinate2D = locationManager.location?.coordinate {
            defaultViewCenter = coordinate
        } else {
            defaultViewCenter = cameraBoundary.region.center
        }
        let span = MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
        let region = MKCoordinateRegion(center: defaultViewCenter, span: span)
        mapView.setRegion(region, animated: true)
        
        return mapView
    }
    
    
    // Update MapView
    func updateUIView(_ view: MKMapView, context: Context) {
        // track user location
        view.showsUserLocation = showsUserLocation
        locationManager.delegate = locationManagerDelegate
        let status = locationManager.authorizationStatus
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        // keep markers updated
        let viewAnnotationCount = view.annotations.count - (view.userTrackingMode.rawValue == 0 ? 0 : 1)
        if self.showingSearchView {
            guard let selectedPlace = self.selectedPlace else { return }
            view.removeAnnotation(selectedPlace)
            print("remove annotation")
            view.addAnnotation(selectedPlace)
            print("add annotation back")
            return
        } else if self.annotations.count != viewAnnotationCount && self.annotations.count != viewAnnotationCount - 1 {
            // this section will ignore if one self.annotations has one more item than view.annotation, so that the list off annotations isn't reset in the middle of showing a search result
            // PRINT COUNT --- print("\(self.annotations.count) != \(viewAnnotationCount - 1)")
            view.removeAnnotations(view.annotations)
            view.addAnnotations(self.annotations)
            print("reset annotations")
        }
    }
    
    // Create and attach Coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    
    // MARK: - MapView Coordinator
    // Coordinator acts as the delegate for map view, passing data to and from SwiftUI.
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView  // attach MapView
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        // Sends data back to MapView when the view is changed
//        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) { }
        
        // Customize the look of the the MapView's markers
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let annoation = annotation as? MKUserLocation {
                return MKUserLocationView(annotation: annoation, reuseIdentifier: nil)
            }
            
            guard let annotation = annotation as? Annotation else { fatalError("") }
        
            guard let getIdentifier = parent.identifier else {
                return MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
            }
            let identifier = getIdentifier(annotation)
            // attempt to find a marker we can recycle
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView != nil {
                // we have a view to reuse, so give it the new annotation
                annotationView?.annotation = annotation
            } else {
                // we didn't find one; make a new one
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)  // we didn't find one; make a new one
                annotationView?.canShowCallout = true   // allow annoation to show pop up information
                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)  // attach an information button to the view
            }
            return annotationView
        }
        
        
        // Called when button is tapped
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let placemark = view.annotation else { fatalError() }
            parent.selectedPlace = placemark as? Annotation
            parent.showingPlaceDetailsView = true
        }
        
        // Called when annoation is delselected
        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            parent.selectedPlace = nil
        }
        
        // Called when views are added?
        func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]){
            if parent.showingSearchView {
                guard let selectedPlace = parent.selectedPlace else { return }
                mapView.selectAnnotation(selectedPlace, animated: true)
                parent.showingSearchView = false
                print("animate to annotation")
            }
        }
    }
    
    // MARK: - Location Manager Delagte
    // Ask user about user permissions and sends user tracking data back and forth
    private class LocationManagerDelagte: NSObject, CLLocationManagerDelegate {
        
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            switch manager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                return
            //            print("location permission has been set to authorizedWhenInUse/authorizedAlways")
            case .denied:
                fatalError("user tap 'disallow' on the permission dialog, cant get location data")
            case .restricted:
                fatalError("parental control setting disallow location data")
            case .notDetermined:
                print("the location permission dialog haven't shown before, user haven't tap allow/disallow")
            @unknown default:
                fatalError("location manager authorization status changed to \"Unknown\"")
            }
        }
    }
}
