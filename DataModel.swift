//
//  DataModel.swift
//  
//
//  Created by Benjamin Keys on 3/17/21.
//

import Foundation
import MapKit

struct School: Codable {
//    private let version = "v0.1-alpha"
    let campuses: [Campus]
}

struct Campus: Codable {
    let name: String?
    let region: MKCoordinateRegion
    let places: [Place]
}

struct Place: Codable, Identifiable {
    let name: String
    let desc, url: String?
    let id: UUID
    let type: Types
    let coordinate: CLLocationCoordinate2D
    let address: Address?
    let querys: [String]?
    let subplaces: [Subplace]?
    
    enum Types: String, Codable {
        case dining, housing, hall, athletics, parking, landmark, other
    }
    
    private enum CodingKeys: CodingKey {
        case name, desc, url, id, type, coordinate, address, querys, subplaces
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        desc = try container.decodeIfPresent(String.self, forKey: .desc)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decodeIfPresent(Types.self, forKey: .type) ?? .other
        coordinate = try container.decode(CLLocationCoordinate2D.self, forKey: .coordinate)
        address = try container.decodeIfPresent(Address.self, forKey: .address)
        querys = try container.decodeIfPresent([String].self, forKey: .querys)
        subplaces = try container.decodeIfPresent([Subplace].self, forKey: .subplaces)
    }
}




// MARK: - Subplaces

enum SubplaceContainer: Codable {
    case restaurant(Restaurant)
    case restroom(Restroom)
    case office(Office)
    case other(Subplace)
    
    func get() -> Subplace {
        switch self {
        case .restaurant(let subplace):
            return subplace
        case .restroom(let subplace):
            return subplace
        case .office(let subplace):
            return subplace
        case .other(let subplace):
            return subplace
        }
    }
    
    private enum Types: String, Decodable {
        case restaurant, restroom, office, other
    }
    
    private enum CodingKeys: CodingKey { case type }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decodeIfPresent(Types.self, forKey: .type)
        switch type {
        case .restaurant:
            try self = .restaurant(Restaurant(from: decoder))
        case .restroom:
            try self = .office(Office(from: decoder))
        case .office:
            try self = .restroom(Restroom(from: decoder))
        default:
            try self = .other(Subplace(from: decoder))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.get(), forKey: .type)
    }
}

class Subplace: Codable {
    let name,
        roomNumber: String?
    
    private enum CodingKeys: String, CodingKey {
        case name, roomNumber = "room-number"
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        roomNumber = try container.decodeIfPresent(String.self, forKey: .roomNumber)
    }
}

class Restaurant: Subplace {
    let description: String
    let schedule: Schedule
    
    private enum CodingKeys: CodingKey {
        case description, schedule
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        description = try container.decode(String.self, forKey: .description)
        schedule = try container.decode(Schedule.self, forKey: .schedule)
        try super.init(from: decoder)
    }
}

class Office: Restaurant {
    let phone, email, url: String
    
    private enum CodingKeys: CodingKey {
        case phone, email, url
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        phone = try container.decode(String.self, forKey: .phone)
        email = try container.decode(String.self, forKey: .email)
        url = try container.decode(String.self, forKey: .url)
        try super.init(from: decoder)
    }
}

class Restroom: Subplace {
    var sex: Sex
    enum Sex: String, Decodable {
        case male, female, unisex, family
    }
    
    private enum CodingKeys: CodingKey { case sex }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sex = try container.decode(Sex.self, forKey: .sex)
        try super.init(from: decoder)
    }
}




// MARK: - Other Types

struct Address: Codable {
    let street: String
    let street2: String?
    let city: String
    let state: Int
    let zip: String
    let country: String
}

struct Schedule: Codable {
    private let components: [ScheduleComponent]
    private struct ScheduleComponent: Codable {
        let days: [ClosedRange<Int>]?
        let timeRanges: [(DateComponents, DateComponents)]?
        let notes: String?
        
        private enum CodingKeys: String, CodingKey {
            case days
            case timeRanges = "time-ranges"
            case notes
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            if let days = try container.decodeIfPresent([String].self, forKey: .days) {
                
                let weekdays = Calendar.init(identifier: .gregorian).shortWeekdaySymbols.map({ return $0.lowercased() })
                
                var results = [ClosedRange<Int>]()
                var range = 0...0
                
                for day in days {
                    /* Start range */
                    if range.lowerBound == 0 {
                        if let nWeekday = weekdays.firstIndex(of: day) {
                            range = nWeekday...nWeekday
                        } else {
                            fatalError("Error! ScheduleComponent contained an invalud value (\(day)).")
                        }
                    }
                    /* End range */
                    if day == days.last // not last item in array
                        && weekdays.indices.contains(range.upperBound+1) // not Saturday
                        && days.contains(weekdays[range.upperBound+1]) // next day of week is in array
                    {
                        range = range.lowerBound...(range.upperBound+1)
                    /* Increment range (inrease) */
                    } else {
                        results.append(range)
                        range = 0...0
                    }
                }
                
                self.days = results
            } else {
                self.days = nil
            }
            
            if let timeRangeStrings = try container.decodeIfPresent([String].self, forKey: .timeRanges) {
                var results = [(DateComponents, DateComponents)]()
                for timeRangeString in timeRangeStrings {
                    let times = timeRangeString.split(separator: "-").map({ time -> DateComponents in
                        let numbers = time.split(separator: ":").map({ return Int($0) })
                        return DateComponents(hour: numbers[0], minute: numbers[1])
                    })
                    results.append((times[0], times[1]))
                }
                self.timeRanges = results
            } else {
                self.timeRanges = nil
            }
            
            self.notes = try container.decodeIfPresent(String.self, forKey: .notes)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            if (self.days != nil) {
                let weekdays = Calendar.init(identifier: .gregorian).shortWeekdaySymbols.map({ return $0.lowercased() })
                var days = [String]()
                for dayRange in self.days! {
                    for i in dayRange {
                        days.append(weekdays[i])
                    }
                }
                try container.encode(days, forKey: .days)
            }
            
            if (timeRanges != nil) {
                var timeStrs = [String]()
                for timeRange in self.timeRanges! {
                    timeStrs.append("\(timeRange.0.hour!):\(timeRange.0.minute!)-\(timeRange.1.hour!):\(timeRange.1.minute!)")
                }
                try container.encode(timeStrs, forKey: .timeRanges)
            }
            
            try container.encodeIfPresent(notes, forKey: .notes)
        }
    }
}




// MARK: - MapKit Extensions

extension MKCoordinateRegion: Codable {
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
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(center, forKey: .center)
        try container.encode(
            CLLocation(latitude: center.latitude - span.latitudeDelta * 0.5, longitude: center.longitude).distance(from: CLLocation(latitude: center.latitude + span.latitudeDelta * 0.5, longitude: center.longitude)).rounded(),
            forKey: .latMeters
        )
        try container.encode(
            CLLocation(latitude: center.latitude, longitude: center.longitude - span.longitudeDelta * 0.5).distance(from: CLLocation(latitude: center.latitude, longitude: center.longitude + span.longitudeDelta * 0.5)).rounded(),
            forKey: .lngMeters
        )
    }
}

extension CLLocationCoordinate2D: Codable {
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
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.latitude, forKey: .lat)
        try container.encode(self.longitude, forKey: .lng)
    }
}

