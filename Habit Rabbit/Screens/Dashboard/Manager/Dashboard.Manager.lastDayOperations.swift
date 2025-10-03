import SwiftUI

extension Habit.Dashboard.Manager {
    
    typealias Direction = Habit.Card.Manager.DayShiftDirection
    
    func shiftLastDay(to direction: Direction) {
        let offset = direction == .tomorrow ? 1 : -1
        lastDay = Calendar.current.date(byAdding: .day, value: offset, to: lastDay)!
        lastDayIndex = Calendar.current.weekdayIndex(for: lastDay)
        
        for cardManager in cardManagers {
            cardManager.shiftLastDay(to: direction)
        }
    }
    
    func setLastDay(to date: Date) {
        guard !date.isSameDay(as: lastDay) else { return }
        let date = date.startOfDay
        
        let dayDifference = Calendar.current.dateComponents([.day], from: lastDay, to: date).day!
        
        switch dayDifference {
            case  1: shiftLastDay(to: .tomorrow)
            case -1: shiftLastDay(to: .yesterday)
            default:
                lastDay = date
                lastDayIndex = Calendar.current.weekdayIndex(for: date)
                deleteCardManagers()
                refreshCardManagers()
        }
    }
    
}

extension Habit.Dashboard.Manager {
    
    func weekdaySymbol(for date: Date) -> String {
        let index = Calendar.current.weekdayIndex(for: date)
        guard weekdaySymbols.indices.contains(index) else { return "?" }
        return weekdaySymbols[index]
    }
    
}
