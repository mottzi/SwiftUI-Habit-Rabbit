import SwiftUI

extension String {

    func pluralized(count: Int) -> String {
        return String.pluralize(string: self, count: count)
    }
    
    static func pluralize(string: String, count: Int) -> String {
        let count = count == 0 ? 2 : count
        let attributedString = AttributedString(localized: "^[\(count) \(string)](inflect: true)")
        let localizedString = String(attributedString.characters)
        let countPrefix = "\(count) "
        guard localizedString.hasPrefix(countPrefix) else { return localizedString }
        return String(localizedString.dropFirst(countPrefix.count))
    }
}


