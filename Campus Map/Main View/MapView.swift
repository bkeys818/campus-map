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
    @State private var region: MKCoordinateRegion
    @State private var userTrackingMode: MapUserTrackingMode = .none
    
    init(region: MKCoordinateRegion, places: [Place]) {
        self.places = places
        self._region = State(initialValue: region)
    }
    
    var body: some View {
        Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, userTrackingMode: $userTrackingMode, annotationItems: places) { place in
            MapMarker(coordinate: place.coordinate)
        }
    }
}

//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}
