//
//  GreetingView.swift
//  Campus Map
//
//  Created by Benjamin Keys on 3/12/21.
//

import SwiftUI

struct SelectSchoolView: View {
    @Binding var schoolName: SchoolName
    @Binding var school: School?
    
    @State private var text = ""
    @State private var isSearching = false
    
    var body: some View {
        VStack(alignment: .center) {
                SearchBar("Find your college", text: $text, isEditing: $isSearching)
                    List {
                        ForEach(filterSearch(), id: \.self) { school in
                            HStack(alignment: .center, spacing: 15) {
                                Text(school.rawValue)
                                    .lineLimit(1)
                                Spacer()
                            }
                            .onTapGesture(perform: { onSelect(school) })
                        }
                    }
                    .listStyle(PlainListStyle())
            }
    }
    
    private func filterSearch() -> [SchoolName] {
        return SchoolName.allCases.filter {
            return (text.isEmpty == true)
                || $0.rawValue.lowercased().contains(text.lowercased())
        }
    }
    
    private func onSelect(_ school: SchoolName) {
        let urlStr = "https://raw.githubusercontent.com/bkeys818/campus-map-data/"
            + UIApplication.appVersion
            + "/data/"
            + school.pathName() + "/data.json"
        
        guard let url = URL(string: urlStr) else {
            fatalError("Error! \"\(urlStr)\" is an invalid URL")
        }

        URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            if error != nil {
                fatalError(error?.localizedDescription ?? "Unknown Error")
            }
            guard let data = data else {
                fatalError("URL session retrieved no data")
            }
            DispatchQueue.main.async {
                do {
                    try JSONDecoder().decode(School.self, from: data)
                    try data.write(to: UIApplication.documentDirectory.appendingPathComponent(school.pathName()+".json"))
                    print("Saved")
                    schoolName = school
                } catch {
                    // TODO: - Handle Error
                    print(error)
                    fatalError()
                }
            }
        }.resume()
    }
}



//
//struct GreetingView_Previews: PreviewProvider {
//    static var previews: some View {
//        SelectSchoolView(.constant(SchoolName.none))
//    }
//}
