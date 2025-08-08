import SwiftUI

extension CaseIterable where Self: Equatable {

    var next: Self {
        let all = Self.allCases
        let current = all.firstIndex(of: self)!
        let next = all.index(current, offsetBy: 1)
        return all[next == all.endIndex ? all.startIndex : next]
    }
    
}

extension RandomAccessCollection {

    var enumerated: [(offset: Int, element: Element)] {
        Array(self.enumerated())
    }
    
}

extension Date {
    
    var weekday: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "EEEEE"
        return dateFormatter.string(from: self)
    }
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
}

extension Calendar {
    
    var shortWeekdaySymbols: [String] {
        let locale = locale ?? .current
        let formatter = DateFormatter()
        formatter.locale = locale
        guard let symbols = formatter.veryShortWeekdaySymbols, !symbols.isEmpty else { return [] }
        let first = (firstWeekday - 1) % symbols.count
        let rotated = Array(symbols[first...] + symbols[..<first])
        return rotated
    }
    
}

extension View {

    func debug(_ color: Color? = nil, _ width: CGFloat? = nil) -> some View {
        self.border(color ?? .orange, width: width ?? 2)
    }
    
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        @ViewBuilder trueTransform: (Self) -> TrueContent,
        @ViewBuilder `else`: (Self) -> FalseContent
    ) -> some View {
        if condition {
            trueTransform(self)
        } else {
            `else`(self)
        }
    }
    
    @ViewBuilder
    func `if`<TrueContent: View>(
        _ condition: Bool,
        @ViewBuilder trueTransform: (Self) -> TrueContent
    ) -> some View {
        if condition {
            trueTransform(self)
        } else {
            self
        }
    }
    
}

extension String {

    func pluralized(count: Int) -> String {
        return pluralize(name: self, count: count)
    }
    
}

func pluralize(name: String, count: Int) -> String {
    let count = count == 0 ? 2 : count
    let attributedString = AttributedString(localized: "^[\(count) \(name)](inflect: true)")
    let localizedString = String(attributedString.characters)
    let countPrefix = "\(count) "
    guard localizedString.hasPrefix(countPrefix) else { return localizedString }
    return String(localizedString.dropFirst(countPrefix.count))
}
