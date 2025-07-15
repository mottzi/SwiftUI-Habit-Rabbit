import SwiftUI
import SwiftData

extension Habit {
    struct Card: View {
        @Environment(\.modelContext) var modelContext
        @Environment(\.colorScheme) var colorScheme
        
        @State var isDeleting = false
        @State var deletionOffset: CGSize = .zero
        
        @Query var todayValues: [Habit.Value]
        @Query var weeklyValues: [Habit.Value]
        
        let habit: Habit
        let lastDay: Date
        let mode: Habit.Card.Mode
        let index: Int
        
        var body: some View {
            VStack(spacing: 0) {
                dailyView
                    .frame(height: barChartHeight)
                habitLabel
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background { backgroundView }
            .geometryGroup()
            .animation(.bouncy, value: todayValues.first?.currentValue)
            .scaleEffect(isDeleting ? 0 : 1)
            .contentShape(.contextMenuPreview, .rect(cornerRadius: 24))
            .contextMenu { contextMenuButtons }
            .offset(isDeleting ? deletionOffset : .zero)
            .frame(height: mode == .monthly ? 350 : 232)
        }
        
        var dailyView: some View {
            HStack(spacing: 12) {
                progressChart
                    .frame(width: barChartWidth)
                VStack(spacing: 0) {
                    progressLabel
                        .frame(maxHeight: .infinity)
                    progressButton
                        .frame(width: 70, height: 70)
                }
            }
            .geometryGroup() // prevents progressLabel jumping
        }
        
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
            
            self._todayValues = Query(Habit.Value.filterByDay(for: habit, on: lastDay))
            self._weeklyValues = Query(Habit.Value.filterByWeek(for: habit, endingOn: lastDay))
        }
    }
}

extension Habit.Card {
    func deleteWithAnimation() {
        Task {
            try? await Task.sleep(nanoseconds: 10_000_000)
            withAnimation(.spring(duration: 0.8)) {
                isDeleting = true
                deletionOffset = calculateDeletionOffset()
            } completion: {
                isDeleting = false
            }
            
            try? await Task.sleep(nanoseconds: 10_000_000)
            modelContext.delete(habit)
        }
    }
    
    func calculateDeletionOffset() -> CGSize {
        let amount = mode == .daily ? 250 : 500
        let adjustedSide = (index % 2 == 0) ? -amount : amount
        return CGSize(width: CGFloat(adjustedSide), height: 100)
    }
}

extension Habit.Card {
    @ViewBuilder
    var contextMenuButtons: some View {
        Button("Randomize", systemImage: "sparkles") {
            todayValue?.currentValue = Int.random(in: 0...habit.target * 2)
        }
        Button("Reset", systemImage: "arrow.counterclockwise") {
            todayValue?.currentValue = 0
        }
        Button("Delete", systemImage: "trash", role: .destructive) {
            deleteWithAnimation()
        }
    }
}

extension Habit.Card {
    var todayValue: Habit.Value? { todayValues.first }
    
    var name: String { habit.name }
    var unit: String { habit.unit }
    var icon: String { habit.icon }
    var color: Color { habit.color }
    
    var currentValue: Int {
        switch mode {
            case .daily: todayValue?.currentValue ?? 0
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
    }
}
