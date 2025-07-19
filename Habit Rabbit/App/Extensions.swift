import SwiftUI

extension CaseIterable where Self: Equatable {
    // returns next case in an enum, or the first case if called on last case
    var next: Self {
        let all = Self.allCases
        let current = all.firstIndex(of: self)!
        let next = all.index(current, offsetBy: 1)
        return all[next == all.endIndex ? all.startIndex : next]
    }
}

extension RandomAccessCollection {
    // returns the collaction as enumerated array
    var enumerated: [(offset: Int, element: Element)] {
        Array(self.enumerated())
    }
}

extension Date {
    // abbreviated weekday
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

// adds view modifiers for debugging and applying conditional transformations.
extension View {
    // adds visible frame border for debugging layout
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
    // returns a pluralized string based on given count
    func pluralized(count: Int) -> String {
        return pluralize(name: self, count: count)
    }
}

func pluralize(name: String, count: Int) -> String {
    let count = count == 0 ? 2 : count
    let attributedString = AttributedString(localized: "^\(count) \(name)](inflect: true)")
    let localizedString = String(attributedString.characters)
    let countPrefix = "\(count) "
    guard localizedString.hasPrefix(countPrefix) else { return localizedString }
    return String(localizedString.dropFirst(countPrefix.count))
}
