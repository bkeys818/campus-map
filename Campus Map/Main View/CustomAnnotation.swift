//
//  CustomAnnotation.swift
//  Campus Map
//
//  Created by Benjamin Keys on 3/26/21.
//

import Foundation
import MapKit.MKAnnotation

class CustomAnnoation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
//    let subtitle: String?
    
    let place: Place

    init(place: Place) {
        self.coordinate = place.coordinate
        self.title = place.name

        self.place = place
        
        super.init()
    }
}
