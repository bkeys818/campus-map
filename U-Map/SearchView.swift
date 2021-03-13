//
//  SearchView.swift
//  U-Map
//
//  Created by Benjamin Keys on 3/12/21.
//

import SwiftUI

protocol Searchable: Hashable {
    var title: String { get }
    var querys: [String] { get }
}

struct SearchView<DataType: Searchable>: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var showingCancelButton = false
    @State private var text = ""
    private let placeholder: String
    
    private let data: [DataType]
    private var onSelection: (_: DataType) -> Void
    
    init(placeholder: String, data: [DataType], onSelection: @escaping (_: DataType) -> Void) {
        self.placeholder = placeholder
        self.data = data
        self.onSelection = onSelection
    }
    init(data: [DataType], onSelection: @escaping (_: DataType) -> Void) {
        self.placeholder = "Search"
        self.data = data
        self.onSelection = onSelection
    }
    
    var body: some View {
        VStack {
            SearchBar(presentationMode: presentationMode, showingCancelButton: $showingCancelButton, text: $text, placeholder: placeholder)
            List {
                ForEach(filterSearch(), id: \.self) { item in
                    HStack(alignment: .center, spacing: 15) {
                        Text(item.title)
                            .lineLimit(1)
                        Spacer()
                    }
                    .onTapGesture(perform: { onSelection(item) } )
                }
            }
            .padding(.top, -10)
            .listStyle(PlainListStyle())
            .onTapGesture(perform: {
                UIApplication.shared.endEditing(true)
            })
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        UIApplication.shared.endEditing(true)
                    })
            )
        }
    }
    
    private func filterSearch() -> [DataType] {
        return data.filter {
            if text.isEmpty == true { return true }
            for query in $0.querys {
                if query.lowercased().contains(text.lowercased()) { return true }
            }
            return false
        }
    }
    
    private struct SearchBar: UIViewRepresentable {
        @Binding var presentationMode: PresentationMode
        @Binding var showingCancelButton: Bool
        @Binding var text: String
        let placeholder: String
        
        func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
            let searchBar = UISearchBar(frame: .zero)
            searchBar.delegate = context.coordinator
            searchBar.placeholder = placeholder
            
            searchBar.searchBarStyle = .minimal
            searchBar.returnKeyType = .done
            
            return searchBar
        }
        
        func updateUIView(_ uiView: UISearchBar , context: UIViewRepresentableContext<SearchBar>) {
            uiView.text = text
            uiView.setShowsCancelButton(showingCancelButton, animated: true)
        }
        
        
        func makeCoordinator() -> Coordinator {
            return Coordinator(parent: self)
        }
        
        class Coordinator: NSObject, UISearchBarDelegate {
            var parent: SearchBar
            
            init(parent: SearchBar) {
                self.parent = parent
            }
            
            func searchBar(_ searchBar: UISearchBar, textDidChange text: String) {
                parent.text = text
            }
            
            func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
                parent.presentationMode.dismiss()
                parent.showingCancelButton = false
                parent.text = ""
            }
            
            func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
                UIApplication.shared.endEditing(true)
            }
            
            func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
                parent.showingCancelButton = true
            }
            func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
                parent.showingCancelButton = false
                UIApplication.shared.endEditing(true)
            }
        }
    }
}



// MARK: - Dismiss Keyboard
// When user clicks off the keyboard, it will dismiss
extension UIApplication {
    func endEditing(_ force: Bool) {
        self.windows
            .filter{$0.isKeyWindow}
            .first?
            .endEditing(force)
    }
}
