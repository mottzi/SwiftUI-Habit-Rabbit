import SwiftUI
import SwiftData

@Model
// primary data model containing metadata about a habit
class Habit: Identifiable {
    @Relationship(deleteRule: .cascade, inverse: \Habit.Value.habit)
    var values: [Habit.Value]?
    
    var name: String
    var unit: String
    var icon: String
    var colorData: Data
    var target: Int
    var date: Date
    
    // creates a new habit instance, encoding its color
    init(name: String, unit: String, icon: String, color: Color, target: Int) {
        self.name = name
        self.unit = unit
        self.icon = icon
        self.target = target
        self.date = .now
        let encode: (UIColor, Bool) throws -> Data = NSKeyedArchiver.archivedData
        self.colorData = (try? encode(UIColor(color), false)) ?? Data()
    }
    
    // property that decodes color data into SwiftUI.Color
    var color: Color {
        let decode: (UIColor.Type, Data) throws -> UIColor? = NSKeyedUnarchiver.unarchivedObject
        guard let uiColor = try? decode(UIColor.self, colorData) else { return Color.black }
        return Color(uiColor)
    }
}

extension Habit {
    @Model
    // stores progress value for a specific habit on a specific day.
    class Value {
        @Relationship
        var habit: Habit?
        
        var date: Date
        var currentValue: Int
        
        // creates progress value for a habit, normalizing the date
        init(habit: Habit, date: Date, currentValue: Int = 0) {
            self.habit = habit
            self.date = Calendar.current.startOfDay(for: date)
            self.currentValue = currentValue
        }
    }
}

extension ModelContext {
    // inserts habit and automatically creates its initial progress value for the same day
    func insert(habit: Habit) {
        let value = Habit.Value(habit: habit, date: habit.date)
        insert(habit)
        insert(value)
    }
}

extension Habit.Value {
    // creates a fetch descriptor for a habit's value on a single specific date
    static func filterByDay(for habit: Habit, on date: Date) -> FetchDescriptor<Habit.Value> {
        filterByDays(1, for: habit, endingOn: date)
    }
    
    // creates a fetch descriptor for a habit's values over a number of days, ending on a specific date
    static func filterByDays(_ days: Int, for habit: Habit, endingOn date: Date) -> FetchDescriptor<Habit.Value> {
        let habitID = habit.id
        
        let today = Calendar.current.startOfDay(for: date)
        let rangeStart = Calendar.current.date(byAdding: .day, value: -(days-1), to: today)!
        let rangeEnd = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        let predicate = #Predicate<Habit.Value> { value in
            value.habit?.id == habitID
            && value.date >= rangeStart && value.date < rangeEnd
        }
        
        let sortByDate = SortDescriptor(\Habit.Value.date)
        var descriptor = FetchDescriptor(predicate: predicate, sortBy: [sortByDate])
        descriptor.fetchLimit = days
        descriptor.relationshipKeyPathsForPrefetching = [\Habit.Value.habit]
        
        return descriptor
    }
}

extension Habit {
    static var examples: [Habit] {[
        Habit(name: "Hydration",
              unit: "bottle",
              icon: "drop.fill",
              color: .blue,
              target: 1
             ),
        Habit(name: "Stretching",
              unit: "session",
              icon: "figure.strengthtraining.functional",
              color: .orange,
              target: 2
             ),
        Habit(name: "Meditation",
              unit: "session",
              icon: "figure.mind.and.body",
              color: .green,
              target: 3
             ),
        Habit(name: "Reading",
              unit: "page",
              icon: "books.vertical.fill",
              color: .pink,
              target: 4
             ),
        Habit(name: "Chores",
              unit: "task",
              icon: "house.fill",
              color: .red,
              target: 6
             ),
        Habit(name: "Vocabulary",
              unit: "word",
              icon: "book.fill",
              color: .indigo,
              target: 5
             ),
        Habit(name: "Stretching",
              unit: "minute",
              icon: "figure.cooldown",
              color: .brown,
              target: 10
             ),
        Habit(name: "Journaling",
              unit: "entry",
              icon: "pencil.and.ellipsis.rectangle",
              color: .cyan,
              target: 1
             ),
    ]}
}
