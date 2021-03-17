//
//  MapTypeExtensions.swift
//  U-Map
//
//  Created by Benjamin Keys on 3/13/21.
//

import Foundation
import MapKit

extension CLLocationCoordinate2D: Decodable {
    private enum CodingKeys: CodingKey {
        case lat, lng
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            latitude: try container.decode(Double.self, forKey: .lat),
            longitude: try container.decode(Double.self, forKey: .lng)
        )
    }
}
extension MKCoordinateRegion: Decodable {
    private enum CodingKeys: String, CodingKey {
        case center,
             latMeters = "lat-meters",
             lngMeters = "lng-meters"
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            center: try container.decode(CLLocationCoordinate2D.self, forKey: .center),
            latitudinalMeters: try container.decode(Double.self, forKey: .latMeters),
            longitudinalMeters: try container.decode(Double.self, forKey: .lngMeters)
        )
    }
}
