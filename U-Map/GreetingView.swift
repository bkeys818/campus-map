//
//  GreetingView.swift
//  U-Map
//
//  Created by Benjamin Keys on 3/12/21.
//

import SwiftUI

struct GreetingView: View {
    private let schools: [School] = [
        School(title: "Ball State University"),
        School(title: "Loyola University Chicago"),
        School(title: "Purdue University"),
        School(title: "Indiana University Bloomington")
    ]
    
    @State private var searchingText = ""
    @State private var selectedSchool: School?
    
    var body: some View {
        VStack(alignment: .center) {
            SearchView(placeholder: "School", data: schools, onSelection: fetchMapData)
        }
    }
    
    private func fetchMapData(school: School) -> Void {
        
    }
}

struct GreetingView_Previews: PreviewProvider {
    static var previews: some View {
        GreetingView()
    }
}

struct School: Searchable {
    let title: String
    let querys: [String]
    var url: String {
        get {
            return title.lowercased().replacingOccurrences(of: " ", with: "-")
        }
    }
    
    init(title: String, querys: [String]) {
        self.title = title
        self.querys = querys + [title]
    }
    init(title: String) {
        self.title = title
        self.querys = [title]
    }
}
