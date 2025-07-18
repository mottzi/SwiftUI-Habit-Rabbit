import SwiftUI

extension CaseIterable where Self: Equatable {
    var next: Self {
        let all = Array(Self.allCases)
        let currentIndex = all.firstIndex(of: self)!
        let nextIndex = (currentIndex + 1) % all.count
        return all[nextIndex]
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

extension RandomAccessCollection {
    var enumerated: [(offset: Int, element: Element)] {
        Array(self.enumerated())
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
