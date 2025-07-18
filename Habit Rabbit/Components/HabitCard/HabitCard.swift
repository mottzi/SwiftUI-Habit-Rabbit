import SwiftUI
import SwiftData

extension Habit {
    struct Card: View {
        @Environment(\.modelContext) var modelContext
        @Environment(\.colorScheme) var colorScheme
        @Namespace var heroAnimation
        
        @Query var todayValues: [Habit.Value]
        @Query var weeklyValues: [Habit.Value]
        @Query var monthlyValues: [Habit.Value]
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
            ZStack {
                switch mode {
                    case .daily: dayView
                    case .weekly: weekView
                    case .monthly: monthView.geometryGroup()
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 232)
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
            self._weeklyValues = Query(Habit.Value.filterByDays(7, for: habit, endingOn: lastDay))
            self._monthlyValues = Query(Habit.Value.filterByDays(30, for: habit, endingOn: lastDay))
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
        let offset = (config.index % 2 == 0) ? -250 : 250
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
            case .monthly: monthlyValues.reduce(0) { $0 + $1.currentValue }
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
    }
}

extension Habit.Card {
    struct Config {
        let habit: Habit
        let lastDay: Date
        let mode: Habit.Card.Mode
        let index: Int
        
        let dailyBarChartWidth: CGFloat = 50
        let dailyBarChartHeight: CGFloat = 155

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

#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 16) {
            Habit.Card(habit: Habit.examples[0], day: .now, mode: .daily, index: 0)
            Habit.Card(habit: Habit.examples[1], day: .now, mode: .daily, index: 1)
        }
        
        HStack(spacing: 16) {
            Habit.Card(habit: Habit.examples[0], day: .now, mode: .weekly, index: 0)
            Habit.Card(habit: Habit.examples[1], day: .now, mode: .weekly, index: 1)
        }
        
        Spacer()
    }
    .padding(16)
}
