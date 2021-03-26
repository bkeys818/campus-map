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
                SelectSchoolView(schoolName: $schoolName, school: $school)
            } else {
                if school == nil {
                    Text("Loading")
                        .onAppear(perform: loadData)
                } else {
                    MainView(school!)
                }
            }
        }
    }
    private func loadData() {
        do {
            let data = try Data(contentsOf: UIApplication.documentDirectory.appendingPathComponent(schoolName.pathName()+".json"))
            self.school = try JSONDecoder().decode(School.self, from: data)
        } catch {
            // TODO: - Handle Error
            print("Failed to load data.")
            print(error)
            fatalError()
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
