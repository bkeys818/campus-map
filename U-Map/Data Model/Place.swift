//
//  SchoolData.swift
//  U-Map
//
//  Created by Benjamin Keys on 3/13/21.
//

import Foundation
import MapKit

struct SchoolData: Decodable {
    let locations : [Location]
}

struct Location: Decodable {
    let region: MKCoordinateRegion
    let places: [Place]
}


struct Place: Decodable {
    let name: String
    let desc, url: String?
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let address: Address?
    let type: PlaceTypes
    let querys: [String]?
    let subplaces: [Subplace]?
    
    enum PlaceTypes: String, Decodable {
        case dining, housing, hall, athletics, parking, landmark, other
    }
    
    private enum CodingKeys: String, CodingKey {
        case name, desc, id, coordinate, address, type, querys, url, subplaces
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        desc = try container.decodeIfPresent(String.self, forKey: .desc)
        id = try container.decode(UUID.self, forKey: .id)
        coordinate = try container.decode(CLLocationCoordinate2D.self, forKey: .coordinate)
        address = try container.decodeIfPresent(Address.self, forKey: .address)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        
        if let type = try container.decodeIfPresent(PlaceTypes.self, forKey: .type) {
            self.type = type
        } else {
            self.type = .other
        }
        
        var querys = try container.decodeIfPresent([String].self, forKey: .querys) ?? []
        querys.append(name)
        if !(self.type == .other) { querys.append(type.rawValue) }
        self.querys = querys

        if let subplaceContainers = try container.decodeIfPresent([SubplaceContainer].self, forKey: .subplaces) {
            subplaces = subplaceContainers.map({ $0.get() })
        } else {
            subplaces = nil
        }
    }
}


struct Address: Decodable {
    let street: String
    let street2: String?
    let city: String
    let state: Int
    let zip: String
    let country: String
}
