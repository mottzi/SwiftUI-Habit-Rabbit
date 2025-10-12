//
//  Format.swift
//  Habit Rabbit
//
//  Created by Berken Sayilir on 12.10.2025.
//


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

    func shift(days dayOffset: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: dayOffset, to: self)!
    }
    
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }
    
}

extension Date {
    
    enum Format {
        case date
        case dateWeekday
        case weekdayDate
        case debug
    }
    
    func formatted(_ style: Format) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.preferred
        
        switch style {
            case .date:
                formatter.setLocalizedDateFormatFromTemplate("ddMMyyyy")
                return formatter.string(from: self)
                
            case .dateWeekday:
                formatter.setLocalizedDateFormatFromTemplate("ddMMyyyy")
                let datePart = formatter.string(from: self)
                formatter.setLocalizedDateFormatFromTemplate("EEEE")
                let weekdayPart = formatter.string(from: self)
                return "\(datePart), \(weekdayPart)"
                
            case .weekdayDate:
                formatter.setLocalizedDateFormatFromTemplate("ddMMyyyyEEEE")
                return formatter.string(from: self)
                
            case .debug:
                formatter.dateFormat = "EEEE, dd.MM.yyyy, HH:mm:ss"
                return formatter.string(from: self)
        }
    }
    
}