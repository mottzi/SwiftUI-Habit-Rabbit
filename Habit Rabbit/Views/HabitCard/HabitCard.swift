import SwiftUI

extension Habit {
    public struct Card: View {
        @Environment(\.modelContext) var modelContext
        @Environment(\.colorScheme) var colorScheme
        
        @State var feedbackTrigger = false
        let entry: Habit.Entry
        
        let barChartWidth: CGFloat = 50
        let barChartHeight: CGFloat = 155
        
        public init(entry: Habit.Entry) { self.entry = entry }

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
            .animation(.default, value: currentValue)
        }
        
    }
}

extension Habit.Card {
    var name: String { entry.habit.name }
    var unit: String { entry.habit.unit }
    var icon: String { entry.habit.icon }
    var color: Color { entry.habit.color }
    
    public var currentValue: Int {
        switch entry.mode {
            case .daily: entry.dailyValue
            case .weekly: entry.weeklyValues.reduce(0, +)
            case .monthly: entry.weeklyValues.reduce(0, +) // TODO
        }
    }
    
    var target: Int {
        switch entry.mode {
            case .daily: entry.habit.target
            case .weekly: entry.habit.target * 7
            case .monthly: entry.habit.target * 30
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
