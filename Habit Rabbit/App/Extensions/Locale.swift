import SwiftUI

extension Locale {
    
    static var preferred: Locale {
        if let preferredIdentifier = Locale.preferredLanguages.first {
            return Locale(identifier: preferredIdentifier)
        } else {
            return Locale.current
        }
    }
    
}
