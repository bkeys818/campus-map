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
    
    // TODO: Handle errors w/out "fatalError()"
    private func fetchMapData(school: School) -> Void {
        enum fetchError: Error {
            case invalidURL(url: String)
        }
        
        guard let url = URL(string: "https://raw.githubusercontent.com/bkeys818/u-map-data/master/data/"+school.url+".json") else {
            fatalError("Error! \"https://raw.githubusercontent.com/bkeys818/u-map-data/master/"+school.url+".json\" is an invalid URL")
        }
        
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                fatalError(error?.localizedDescription ?? "Unknown Error")
            }
            guard let data = data else {
                fatalError("URL session retrieved no data")
            }
            DispatchQueue.main.async {
                do {
                    let response = try JSONDecoder().decode(SchoolData.self, from: data)
                    print(response)
                } catch {
                    print(error)
                }
//                let decoder = JSONDecoder()
//                let result = decoder.handelError(in: {
//                    return try decoder.decode(SchoolData.self, from: data)
//                })
            }
        }.resume()
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
