//
//  GreetingView.swift
//  U-Map
//
//  Created by Benjamin Keys on 3/12/21.
//

import SwiftUI

struct GreetingView: View {
    private enum School: String, CaseIterable, Identifiable {
        case bsu = "Ball State University"
        case luc = "Loyola University Chicago"
        case pu =  "Purdue University"
        case iu = "Indiana University Bloomington"
        
        var id: String { self.rawValue }
    }
    
    @State private var searchingText = ""
    @State private var selectedSchool: School?
    
    var body: some View {
        VStack(alignment: .center) {
            TextField("School", text: $searchingText)
        }
    }
}

struct GreetingView_Previews: PreviewProvider {
    static var previews: some View {
        GreetingView()
    }
}
