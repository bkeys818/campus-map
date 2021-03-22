//
//  Campus_Map.swift
//  Campus Map
//
//  Created by Benjamin Keys on 3/12/21.
//

import SwiftUI

@main
struct Campus_Map: App {
    @AppStorage("school-name") private var schoolName: SchoolName = .none
    @State private var school: School?
    
    var body: some Scene {
        WindowGroup {
            if schoolName == .none {
//                SelectSchoolView($schoolName)
                SelectSchoolView(schoolName: $schoolName, school: $school)
            } else {
                MainView(schoolName)
            }
        }
    }
}

enum SchoolName: String, CaseIterable {
    case none = "",
         bsu = "Ball State University",
         luc = "Loyola University Chicago",
         pu = "Purdue University",
         iu = "Indiana University Bloomington"
    
    func pathName() -> String { return self.rawValue.lowercased().replacingOccurrences(of: " ", with: "-") }
}
