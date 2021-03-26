//
//  MainView.swift
//  Campus Map
//
//  Created by Benjamin Keys on 3/22/21.
//

import SwiftUI

struct MainView: View {
    @State private var campus: Campus
    
    @State private var annoations: [CustomAnnoation]
    @State private var selectedPlace: CustomAnnoation?
    @State private var showingPlaceDetailsView = false
    @State private var showingSearchView = false
    
    init(_ school: School) {
        let campus: Campus
        if let campusName = UserDefaults.standard.string(forKey: "campus-name") {
            campus = school.campuses.first(where: { campus in
                campus.name == campusName
            }) ?? school.campuses.first!
        } else  {
            campus = school.campuses.first!
        }
        self._campus = State(initialValue: campus)
        
        self._annoations = State(initialValue: campus.places.map { return CustomAnnoation(place: $0) })
    }
    
    var body: some View {
        ZStack {
            MapView(bounds: campus.region, annotations: $annoations, selectedPlace: $selectedPlace, showingPlaceDetailsView: $showingPlaceDetailsView, showingSearchView: $showingSearchView, identifier: { return $0.place.type.rawValue })
                .edgesIgnoringSafeArea(.all)
        }
    }
}

//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
//}
