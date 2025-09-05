import SwiftUI
import SwiftData

extension Habit.Card.DetailView {
    
    @Observable
    class Manager {

        private let habit: Habit
        private let modelContext: ModelContext
        
        private(set) var values: [Habit.Value] = []
        private(set) var isLoading = false
        private(set) var canLoadMore = false
        
        private let pageSize = 100
        private var currentOffset = 0
        
        init(for habit: Habit, using modelContext: ModelContext) {
            self.habit = habit
            self.modelContext = modelContext
            loadInitialValues()
        }
        
        var name: String { habit.name }
        var unit: String { habit.unit }
        var icon: String { habit.icon }
        var color: Color { habit.color }
        var target: Int { habit.target }
        var kind: Habit.Kind { habit.kind }
        
    }
    
}

extension Habit.Card.DetailView.Manager {
    
    func loadInitialValues() {
        loadValues(reset: true)
    }
    
    func loadMoreValues() {
        guard !isLoading && canLoadMore else { return }
        loadValues(reset: false)
    }
    
    private func loadValues(reset: Bool) {
        isLoading = true
        
        if reset {
            currentOffset = 0
            values = []
        }
        
        let habitID = habit.id
        let predicate = #Predicate<Habit.Value> { value in
            value.habit?.id == habitID
        }
        
        let sortByDate = SortDescriptor(\Habit.Value.date, order: .reverse) // Latest first
        var descriptor = FetchDescriptor(predicate: predicate, sortBy: [sortByDate])
        descriptor.fetchLimit = pageSize
        descriptor.fetchOffset = currentOffset
        descriptor.relationshipKeyPathsForPrefetching = [\Habit.Value.habit]
        
        do {
            let fetchedValues = try modelContext.fetch(descriptor)
            
            if reset {
                values = fetchedValues
            } else {
                values.append(contentsOf: fetchedValues)
            }
            
            currentOffset += fetchedValues.count
            canLoadMore = fetchedValues.count == pageSize
            
        } catch {
            canLoadMore = false
        }
        
        isLoading = false
    }
    
    func resetValue(_ value: Habit.Value) {
        value.currentValue = 0
        try? modelContext.save()
    }
    
    func updateValue(_ value: Habit.Value, to newValue: Int) {
        value.currentValue = newValue
        try? modelContext.save()
    }
    
}
