import SwiftUI
import SwiftData

extension Habit {
    public struct Card: View {
        @Environment(\.modelContext) var modelContext
        @Environment(\.colorScheme) var colorScheme
        
        @State var feedbackTrigger = false
        let habit: Habit
        let endDay: Date
        let viewType: HabitCardType
        let onDelete: () -> Void
        let isDeleting: Bool
        let deletionOffset: CGSize
        
        @Query private var todayValue: [Habit.Value]
        @Query private var weeklyValues: [Habit.Value]
        
        let barChartWidth: CGFloat = 50
        let barChartHeight: CGFloat = 155
        
        public init(habit: Habit, endDay: Date, viewType: HabitCardType, onDelete: @escaping () -> Void, isDeleting: Bool, deletionOffset: CGSize) {
            self.habit = habit
            self.endDay = endDay
            self.viewType = viewType
            self.onDelete = onDelete
            self.isDeleting = isDeleting
            self.deletionOffset = deletionOffset
            
            let habitID = habit.id
            let todayStart = Calendar.current.startOfDay(for: endDay)
            let todayEnd = Calendar.current.date(byAdding: .day, value: 1, to: todayStart)!
            
            var todayDescriptor = FetchDescriptor<Habit.Value>(
                predicate: #Predicate<Habit.Value> { value in
                    value.habit?.id == habitID && value.date >= todayStart && value.date < todayEnd
                }
            )
            todayDescriptor.relationshipKeyPathsForPrefetching = [\.habit]
            self._todayValue = Query(todayDescriptor)
            
            let startOfWeek = Calendar.current.date(byAdding: .day, value: -6, to: todayStart)!
            var weeklyDescriptor = FetchDescriptor<Habit.Value>(
                predicate: #Predicate<Habit.Value> { value in
                    value.habit?.id == habitID && value.date >= startOfWeek && value.date <= todayEnd
                },
                sortBy: [SortDescriptor(\Habit.Value.date)]
            )
            weeklyDescriptor.relationshipKeyPathsForPrefetching = [\.habit]
            self._weeklyValues = Query(weeklyDescriptor)
        }

        public var body: some View {
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
            .animation(.bouncy, value: todayValue.first?.currentValue)
            .scaleEffect(isDeleting ? 0 : 1)
            .contentShape(.contextMenuPreview, .rect(cornerRadius: 24))
            .contextMenu { contextMenuButtons }
            .offset(deletionOffset)
            .frame(height: viewType == .monthly ? 350 : 230)
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
            // prevents progressLabel jumping
            .geometryGroup()
        }
        
    }
}

extension Habit.Card {
    var name: String { habit.name }
    var unit: String { habit.unit }
    var icon: String { habit.icon }
    var color: Color { habit.color }
    
    public var currentValue: Int {
        switch viewType {
            case .daily: todayValue.first?.currentValue ?? 0
            case .weekly: weeklyValues.reduce(0) { $0 + $1.currentValue }
            case .monthly: weeklyValues.reduce(0) { $0 + $1.currentValue } // TODO
        }
    }
    
    var target: Int {
        switch viewType {
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
    
    func increment() {
        if let value = todayValue.first {
            value.currentValue += 1
        } else {
            let newValue = Habit.Value(habit: habit, date: endDay, currentValue: 1)
            modelContext.insert(newValue)
        }
    }
    
    func randomize() {
        let randomValue = Int.random(in: 0...habit.target * 2)
        if let value = todayValue.first {
            value.currentValue = randomValue
        } else {
            let newValue = Habit.Value(habit: habit, date: endDay, currentValue: randomValue)
            modelContext.insert(newValue)
        }
    }
    
    func reset() {
        if let value = todayValue.first {
            value.currentValue = 0
        } else {
            let newValue = Habit.Value(habit: habit, date: endDay, currentValue: 0)
            modelContext.insert(newValue)
        }
    }

    @ViewBuilder
    var contextMenuButtons: some View {
        Button("Randomize", systemImage: "sparkles") {
            randomize()
        }
        Button("Reset", systemImage: "arrow.counterclockwise") {
            reset()
        }
        Button("Delete", systemImage: "trash", role: .destructive) {
            onDelete()
        }
    }
}
