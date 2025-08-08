import SwiftUI

extension Date {
    
    var weekdaySymbol: String {
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
    
    var weekdaySymbols: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.preferred
        guard let symbols = formatter.veryShortWeekdaySymbols, !symbols.isEmpty else { return [] }
        let first = (firstWeekday - 1) % symbols.count
        let rotated = Array(symbols[first...] + symbols[..<first])
        return rotated
    }
    
    // compute zero-based weekday column index aligned to calendar.firstWeekday
    func weekdayIndex(for date: Date) -> Int {
        // get 1-based weekday component for the given date
        let weekday = component(.weekday, from: date)
        // normalize to zero-based index relative to firstWeekday
        return (weekday - firstWeekday + 7) % 7
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
