import SwiftUI

extension Date {
    
    var tomorrow: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }
    
    var yesterday: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
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
