import SwiftUI

extension Date {
    
    var weekday: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.preferred
        dateFormatter.dateFormat = "EEEEE"
        return dateFormatter.string(from: self)
    }
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
}

extension Calendar {
    
    var shortWeekdaySymbols: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.preferred
        guard let symbols = formatter.veryShortWeekdaySymbols, !symbols.isEmpty else { return [] }
        let first = (firstWeekday - 1) % symbols.count
        let rotated = Array(symbols[first...] + symbols[..<first])
        return rotated
    }
    
}

extension Locale {
    
    static var preferred: Locale {
        if let preferredIdentifier = Locale.preferredLanguages.first {
            return Locale(identifier: preferredIdentifier)
        } else {
            return Locale.current
        }
    }
    
}
