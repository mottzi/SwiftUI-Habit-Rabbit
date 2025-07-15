import SwiftUI
import SwiftData

extension Habit {
    struct Card: View {
        @Environment(\.modelContext) var modelContext
        @Environment(\.colorScheme) var colorScheme

        @Query var todayValues: [Habit.Value]
        @Query var weeklyValues: [Habit.Value]
        @State var isDeleting = false

        let config: Habit.Card.Config
        
        var habit: Habit { config.habit }
        var name: String { habit.name }
        var unit: String { habit.unit }
        var icon: String { habit.icon }
        var color: Color { habit.color }
        var lastDay: Date { config.lastDay }
        var lastDayValue: Habit.Value? { todayValues.first }
        var mode: Habit.Card.Mode { config.mode }
        
        var body: some View {
            VStack(spacing: 0) {
                dayView
                habitLabel
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .frame(height: mode == .monthly ? 350 : 232)
            .background { backgroundView }
            .geometryGroup()
            .animation(.bouncy, value: lastDayValue?.currentValue)
            .scaleEffect(isDeleting ? 0 : 1)
            .contentShape(.contextMenuPreview, .rect(cornerRadius: 24))
            .contextMenu { contextMenuButtons }
            .offset(isDeleting ? deleteOffset : .zero)
        }
        
        init(config: Habit.Card.Config) {
            self.config = config
            self._todayValues = Query(Habit.Value.filterByDay(for: habit, on: lastDay))
            self._weeklyValues = Query(Habit.Value.filterByWeek(for: habit, endingOn: lastDay))
        }
        
        init(habit: Habit, day: Date, mode: Mode, index: Int) {
            self.init(config: .init(for: habit, day: day, mode: mode, index: index))
        }
    }
}

extension Habit.Card {
    func deleteWithAnimation() {
        Task {
            try? await Task.sleep(nanoseconds: 10_000_000)
            withAnimation(.spring(duration: 0.8)) {
                isDeleting = true
            } completion: {
                isDeleting = false
            }
            
            try? await Task.sleep(nanoseconds: 10_000_000)
            modelContext.delete(habit)
        }
    }
    
    var deleteOffset: CGSize {
        let amount = config.mode.deleteOffset
        let offset = (config.index % 2 == 0) ? -amount : amount
        return CGSize(width: CGFloat(offset), height: 100)
    }
}

extension Habit.Card {
    @ViewBuilder
    var contextMenuButtons: some View {
        Button("Randomize", systemImage: "sparkles") {
            lastDayValue?.currentValue = Int.random(in: 0...habit.target * 2)
        }
        Button("Reset", systemImage: "arrow.counterclockwise") {
            lastDayValue?.currentValue = 0
        }
        Button("Delete", systemImage: "trash", role: .destructive) {
            deleteWithAnimation()
        }
    }
}

extension Habit.Card {
    var currentValue: Int {
        switch mode {
            case .daily: lastDayValue?.currentValue ?? 0
            case .weekly: weeklyValues.reduce(0) { $0 + $1.currentValue }
            case .monthly: weeklyValues.reduce(0) { $0 + $1.currentValue } // TODO
        }
    }
    
    var target: Int {
        switch mode {
            case .daily: habit.target
            case .weekly: habit.target * 7
            case .monthly: habit.target * 30
        }
    }
    
    var progress: CGFloat {
        guard target > 0 else { return 0 }
        return CGFloat(currentValue) / CGFloat(target)
    }
    
    var isCompleted: Bool {
        currentValue >= target
    }
}

extension Habit.Card {
    enum Mode: String, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        
        var icon: String {
            switch self {
                case .daily: "1.square.fill"
                case .weekly: "7.square.fill"
                case .monthly: "30.square.fill"
            }
        }
        
        var deleteOffset: CGFloat {
            switch self {
                case .daily: 250
                case .weekly, .monthly: 500
            }
        }
    }
}

extension Habit.Card {
    struct Config {
        let habit: Habit
        let lastDay: Date
        let mode: Habit.Card.Mode
        let index: Int
        
        let barChartWidth: CGFloat = 50
        let barChartHeight: CGFloat = 155
        
        init(
            for habit: Habit,
            day lastDay: Date,
            mode: Habit.Card.Mode,
            index: Int
        ) {
            self.habit = habit
            self.lastDay = lastDay
            self.mode = mode
            self.index = index
        }
    }
}
