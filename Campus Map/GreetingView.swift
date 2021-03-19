//
//  GreetingView.swift
//  Campus Map
//
//  Created by Benjamin Keys on 3/12/21.
//

import SwiftUI

struct GreetingView: View {
    private let schools = [
        "Ball State University",
        "Loyola University Chicago",
        "Purdue University",
        "Indiana University Bloomington"
    ]
    
    @State private var text = ""
    @State private var isSearching = false
    
    var body: some View {
        if isSearching {
            VStack(alignment: .center) {
                SearchBar("Find your college", text: $text, isEditing: $isSearching)
                    .padding(.horizontal, isSearching ? 0 : 36)
                    .animation(.easeInOut)
                if text != "" {
                    List {
                        ForEach(filterSearch(), id: \.self) { school in
                            HStack(alignment: .center, spacing: 15) {
                                Text(school)
                                    .lineLimit(1)
                                Spacer()
                            }
                            .onTapGesture(perform: { fetchData(school) } )
                        }
                    }
                    .listStyle(PlainListStyle())
                    .transition(AnyTransition.move(edge: .top).combined(with: .opacity).animation(Animation.easeIn.delay(1.0)))
                }
            }
        } else {
            Button(action: {}) {
                Text("Search Colleges")
                    .font(.title)
                    .foregroundColor(.primary)
                    .padding(.vertical, 24)
                    .padding(.horizontal, 38)
                    .background(Color.red.opacity(0.4))
                    .clipShape(Capsule())
            }
            .transition(AnyTransition.scale(scale: 0.2).combined(with: .opacity))
        }
    }
    
    private func filterSearch() -> [String] {
        return schools.filter {
            return (text.isEmpty == true)
                || $0.lowercased().contains(text.lowercased())
        }
    }
    
    // TODO: Handle errors w/out "fatalError()"
    private func fetchData(_ school: String) -> Void {
        let urlStr = "https://raw.githubusercontent.com/bkeys818/campus-map-data/\(UIApplication.appVersion)/data/"
            + school.lowercased().replacingOccurrences(of: " ", with: "-") + ".json"
        print(urlStr)
        guard let url = URL(string: urlStr) else {
            fatalError("Error! \"\(urlStr)\" is an invalid URL")
        }
//
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
                    fatalError()
                }
            }
        }.resume()
    }
}




struct GreetingView_Previews: PreviewProvider {
    static var previews: some View {
        GreetingView()
    }
}
