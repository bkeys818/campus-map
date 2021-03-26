//
//  MapView.swift
//  Campus Map
//
//  Created by Benjamin Keys on 3/19/21.
//

import SwiftUI
import MapKit


struct MapView: View {
//    @StateObject private var manager: LocationManager
    @State private var region: MKCoordinateRegion
//    @State private var userTrackingMode: MapUserTrackingMode = .none
    private var places: [Place]
    
    init(region: MKCoordinateRegion, places: [Place]) {
        self.places = places
        self._region = State(initialValue: region)
//        self._manager = StateObject(wrappedValue: LocationManager(region: region))
    }
    
    var body: some View {
//        Map(coordinateRegion: $manager.region, interactionModes: .all, showsUserLocation: true, userTrackingMode: $userTrackingMode, annotationItems: places) { place in
        Map(coordinateRegion: $region, interactionModes: .all, annotationItems: places) { place in
            MapMarker(coordinate: place.coordinate)
        }
    }
    
    
//    private class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
//        @Published var region = MKCoordinateRegion()
//        private let manager = CLLocationManager()
//        private let regionBounds: MKCoordinateRegion
//        init(region: MKCoordinateRegion) {
//            self.regionBounds = region
//            super.init()
//            manager.delegate = self
//            manager.desiredAccuracy = kCLLocationAccuracyBest
//            manager.requestWhenInUseAuthorization()
//            manager.startUpdatingLocation()
//        }
//
//        // Triggered when users location updatess
//        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//            locations.last.map {
//                let center = CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
//                let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
//                region = MKCoordinateRegion(center: center, span: span)
//            }
//        }
//
//    }
}

//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}
