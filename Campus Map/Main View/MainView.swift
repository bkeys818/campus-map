//
//  MainView.swift
//  Campus Map
//
//  Created by Benjamin Keys on 3/22/21.
//

import SwiftUI

struct MainView: View {
    @State private var campus: Campus
    
    init(_ school: School) {
        if let campusName = UserDefaults.standard.string(forKey: "campus-name") {
            self._campus = State(
                initialValue:
                    school.campuses.first(where: { campus in
                        campus.name == campusName
                    }) ?? school.campuses.first!
            )
        } else  {
            self._campus = State(initialValue: school.campuses.first!)
        }
    }
    
    var body: some View {
        ZStack {
            MapView(region: campus.region, places: campus.places)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
//}
