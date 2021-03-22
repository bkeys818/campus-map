//
//  MainView.swift
//  Campus Map
//
//  Created by Benjamin Keys on 3/22/21.
//

import SwiftUI

struct MainView: View {
    @AppStorage("campus-name") private var campusName: String = ""
    @State private var school: School
    private var campus: Campus {
        return school.campuses.first(where: {campus in
            campus.name == campusName
        }) ?? school.campuses.first!
    }
    
    init(_ schoolName: SchoolName) {
        do {
            let data = try Data(contentsOf: UIApplication.documentDirectory.appendingPathComponent(schoolName.pathName()+".json"))
            self._school = State(initialValue: try JSONDecoder().decode(School.self, from: data))
        } catch {
            // TODO: - Handle Error
            print(error)
            fatalError()
        }
    }
    
    var body: some View {
        ZStack {
            MapView(region: campus.region, places: campus.places)
        }
    }
}

//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
//}
