import SwiftUI

extension View {
    func debug(_ color: Color? = nil, _ width: CGFloat? = nil) -> some View {
        self.border(color ?? .orange, width: width ?? 2)
    }
    
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        switch condition {
            case true: transform(self)
            case false: self
        }
    }
}

extension RandomAccessCollection {
    var enumerated: [(offset: Int, element: Element)] {
        Array(self.enumerated())
    }
}

//extension Array {
//    func chunked(into size: Int) -> [[Element]] {
//        return stride(from: 0, to: count, by: size).map {
//            Array(self[$0..<Swift.min($0 + size, count)])
//        }
//    }
//}

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
