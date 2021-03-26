//
//  MapView.swift
//  Campus Map
//
//  Created by Benjamin Keys on 3/19/21.
//

import SwiftUI
import MapKit


// TODO: Move Map to sepretate view (to make data handeling easier) and then use as ZStack

struct MapView: View {
    private var places: [Place]
//    @State private var regions: MKCoordinateRegion
    @StateObject private var manager: LocationManager
    
    @State private var userTrackingMode: MapUserTrackingMode = .none
    
    let marker = UIImage(named: "Marker")!.withTintColor(.red)
    
    init(region: MKCoordinateRegion, places: [Place]) {
        self.places = places
        self._manager = StateObject(wrappedValue: LocationManager(region: region))
    }
    
    var body: some View {
        Map(coordinateRegion: $manager.region, interactionModes: .all, showsUserLocation: true, userTrackingMode: $userTrackingMode, annotationItems: places) { place in
            MapMarker(coordinate: place.coordinate)
        }
    }
    
    
    private class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
        @Published var region = MKCoordinateRegion()
        private let manager = CLLocationManager()
        private let regionBounds: MKCoordinateRegion
        init(region: MKCoordinateRegion) {
            self.regionBounds = region
            super.init()
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
        }
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            locations.last.map {_ in
                region = regionBounds
                print("_")
//                let center = CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
//                let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
//                region = MKCoordinateRegion(center: center, span: span)
            }
        }
        
    }
}

//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}
