import SwiftUI

extension String {

    func pluralized(count: Int) -> String {
        return String.pluralize(string: self, count: count)
    }
    
    static func pluralize(string: String, count: Int) -> String {
        let count = count == 0 ? 2 : count
        let query = LocalizationValue("^[\(count) \(string)](inflect: true)")
        let attributed = AttributedString(localized: query)
        let localized = String(attributed.characters)
        let prefix = "\(count) "
        guard localized.hasPrefix(prefix) else { return localized }
        return String(localized.dropFirst(prefix.count))
    }
}


