//
//  SearchView.swift
//  Campus Map
//
//  Created by Benjamin Keys on 3/12/21.
//

import SwiftUI


struct SearchBar: View {
    private let placeholder: String
    @Binding private var text: String
    @Binding private var isEditing: Bool
    
    init(_ placeholder: String, text: Binding<String>, isEditing: Binding<Bool>) {
        self.placeholder = placeholder
        self._text = text
        self._isEditing = isEditing
    }
    
    var body: some View {
        HStack(spacing: 11.25) {
            ZStack {
                // TODO: - Make sfsymbols an overlay
                // That way clicking them still counts as clicking the searchbar
                HStack(spacing: 4.3) {
                    Image(systemName: "magnifyingglass")
                        .padding(.top, -0.5)
                        .padding(.leading, 0.5)
                    TextField(placeholder, text: $text, onEditingChanged: { isEditing in
                        withAnimation {
                            self.isEditing = isEditing
                        }
                    })
                        .foregroundColor(.primary)
                        .padding(.vertical, 7)
                    if (text != "") {
                        Button(action: { text = "" }) {
                            // TODO: - Add microphone when text is empty
                            Image(systemName: "xmark.circle.fill")
                        }
                    }
                }
                .foregroundColor(Color(.systemGray))
                .padding(.horizontal, 5.75)
                .background(Color(.systemGray6))
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            if (isEditing) {
                Button("Cancel") {
                    withAnimation {
                        isEditing = false
                        UIApplication.shared.endEditing(true)
                        text = ""
                    }
                }
                .padding(.bottom, 2)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
    }
}




// MARK: - Dismiss Keyboard
// When user clicks off the keyboard, it will dismiss
extension UIApplication {
    func addTapGestureRecognizer() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        tapGesture.name = "MyTapGesture"
        window.addGestureRecognizer(tapGesture)
    }
 }
extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false // set to `false` if you don't want to detect tap during other gestures
    }
}


// Function to dismiss keyboard
extension UIApplication {
    func endEditing(_ force: Bool) {
        self.windows
            .filter{$0.isKeyWindow}
            .first?
            .endEditing(force)
    }
}
