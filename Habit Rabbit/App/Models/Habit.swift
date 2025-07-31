import SwiftUI
import SwiftData

@Model
class Habit: Identifiable {
    
    var name: String
    var unit: String
    var icon: String
    private var colorData: Data
    var target: Int
    var date: Date
    var kind: Habit.Kind
    
    @Relationship(deleteRule: .cascade, inverse: \Habit.Value.habit)
    var values: [Habit.Value]?
    
    private static var colorCache: [Data: Color] = [:]
    
    init(
        name: String,
        unit: String,
        icon: String,
        color: Color,
        target: Int,
        kind: Habit.Kind
    ) {
        self.name = name
        self.unit = unit
        self.icon = icon
        self.target = target
        self.date = .now
        self.kind = kind
        let encode: (UIColor, Bool) throws -> Data = NSKeyedArchiver.archivedData
        self.colorData = (try? encode(UIColor(color), false)) ?? Data()
    }
    
    enum Kind: String, Codable {
        case good
        case bad
    }
    
    var color: Color {
        if let cached = Habit.colorCache[colorData] {
            return cached
        }
        
        if let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            let color = Color(uiColor)
            Self.colorCache[colorData] = color
            return color
        }
        
        Habit.colorCache[colorData] = Color.black
        return Color.black
    }
    
}

extension ModelContext {
    
    func insert(habit: Habit) {
        let value = Habit.Value(habit: habit, date: habit.date)
        insert(habit)
        insert(value)
    }
    
}

extension Habit {
    
    static var examples: [Habit] {[
        Habit(name: "Hydration",
              unit: "bottle",
              icon: "drop.fill",
              color: .blue,
              target: 3,
              kind: .good,
        ),
        Habit(name: "Smoking",
              unit: "cigarette",
              icon: "figure.strengthtraining.functional",
              color: .orange,
              target: 3,
              kind: .bad,
        ),
        Habit(name: "Meditation",
              unit: "session",
              icon: "figure.mind.and.body",
              color: .green,
              target: 3,
              kind: .good,
        ),
        Habit(name: "Reading",
              unit: "page",
              icon: "books.vertical.fill",
              color: .pink,
              target: 4,
              kind: .good,
        ),
        Habit(name: "Stretching",
              unit: "session",
              icon: "figure.strengthtraining.functional",
              color: .teal,
              target: 10,
              kind: .good,
        ),
        Habit(name: "Chores",
              unit: "task",
              icon: "house.fill",
              color: .red,
              target: 6,
              kind: .good,
        ),
        Habit(name: "Vocabulary",
              unit: "word",
              icon: "book.fill",
              color: .indigo,
              target: 5,
              kind: .good,
        ),
        Habit(name: "Stretching",
              unit: "minute",
              icon: "figure.cooldown",
              color: .brown,
              target: 10,
              kind: .good,
        ),
        Habit(name: "Journaling",
              unit: "entry",
              icon: "pencil.and.ellipsis.rectangle",
              color: .cyan,
              target: 1,
              kind: .good,
        ),
    ]}
}
