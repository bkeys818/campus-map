//
//  Extensions.swift
//  U-Map
//
//  Created by Benjamin Keys on 3/15/21.
//

import Foundation

// MARK: - Item from array with index safely
// Returns the element at the specified index if it is within bounds, otherwise nil.
extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


// MARK: - Handel decoding errors
// A closure that will catch any errors thrown when decoding
extension JSONDecoder {
    func handelError<T>(in throwingCode: @escaping () throws -> T) -> T {
        do {
            return try throwingCode()
        } catch DecodingError.dataCorrupted(let context) {
            fatalError("""
Failed to decode data.
Decoding Error: Data corrupeted.
\(context.debugDescription)
\(context.codingPath)
""")
        } catch DecodingError.keyNotFound(let key, let context) {
            fatalError("""
Failed to decode data.
Decoding Error: Key \(key.stringValue) not found.
\(context.debugDescription)
\(context.codingPath)
""")
        } catch DecodingError.typeMismatch(let type, let context) {
            fatalError("""
Failed to decode data.
Decoding Error: Type \(type) was expected.")
\(context.debugDescription)
\(context.codingPath)
""")
        } catch DecodingError.valueNotFound(let type, let context) {
            fatalError("""
Failed to decode data.
Decoding Error: No value was found for \(type).
\(context.debugDescription)
\(context.codingPath)
""")
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
