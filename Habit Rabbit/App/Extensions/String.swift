import SwiftUI

extension String {
    
    func pluralized(count: Int) -> String {
        Self.pluralize(string: self, count: count)
    }
    
    static func pluralize(string: String, count: Int) -> String {
        let query = LocalizedStringResource("^[\(count) \(string)](inflect: true)")
        let attributed = AttributedString(localized: query)
        let localized = String(attributed.characters)
        let prefix = String(localized: "\(count) ")
        guard localized.hasPrefix(prefix) else { return localized }
        return String(localized.dropFirst(prefix.count))
    }
    
}
