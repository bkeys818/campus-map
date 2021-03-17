//
//  Subplace.swift
//  U-Map
//
//  Created by Benjamin Keys on 3/14/21.
//

import Foundation

class Subplace: Decodable {
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

enum SubplaceContainer: Decodable {
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
}


struct Schedule: Decodable {
    private let components: [ScheduleComponent]
    private struct ScheduleComponent: Decodable {
        let days: [ClosedRange<Int>]?
        let timeRanges: [(DateComponents, DateComponents)]?
        let notes: String?
        
        private enum CodingKeys: String, CodingKey {
            case days,
                 timeRanges = "time-ranges",
                 notes
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            if let days = try container.decodeIfPresent([String].self, forKey: .days) {
                
                var weekdays = Calendar.init(identifier: .gregorian).shortWeekdaySymbols
                for i in 0..<weekdays.count {
                    weekdays[i] = weekdays[i].lowercased()
                }
                
                var results = [ClosedRange<Int>]()
                var range = 0...0
                
                for day in days {
                    if range.lowerBound == 0 {
                        if let nWeekday = weekdays.firstIndex(of: day) {
                            range = nWeekday...nWeekday
                        } else {
                            fatalError("Error! ScheduleComponent contained an invalud value (\(day)).")
                        }
                    }
                    if day == days.last // not last item in array
                        && weekdays.indices.contains(range.upperBound+1) // not Saturday
                        && days.contains(weekdays[range.upperBound+1]) // next day of week is in array
                    {
                        range = range.lowerBound...(range.upperBound+1)
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
    }
}
