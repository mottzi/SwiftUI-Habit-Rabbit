import SwiftUI

extension View {
    func debug(_ color: Color? = nil, _ width: CGFloat? = nil) -> some View {
        self.border(color ?? .orange, width: width ?? 2)
    }
}

extension Array {
    func chunks(of size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
    
    var pairs: [[Element]] {
        self.chunks(of: 2)
    }
    
    func randomElements(count n: Int) -> [Element] {
        guard n > 0 else { return [] }
        return Array(shuffled().prefix(n))
    }
}

//extension Array where Element: Identifiable {
//    struct IdentifiableChunk<Item: Identifiable>: Identifiable, RandomAccessCollection {
//        let id: Item.ID
//        private let elements: [Item]
//
//        init(_ elements: [Item]) {
//            self.elements = elements
//            self.id = elements.first?.id ?? UUID() as! Item.ID
//        }
//
//        var count: Int { elements.count }
//        var startIndex: Int { elements.startIndex }
//        var endIndex: Int { elements.endIndex }
//
//        func index(after i: Int) -> Int { elements.index(after: i) }
//        subscript(index: Int) -> Item { elements[index] }
//    }
//
//    func chunks(of size: Int) -> [IdentifiableChunk<Element>] {
//        return stride(from: 0, to: count, by: size).map { start in
//            let end = Swift.min(start + size, count)
//            let chunk = Array(self[start..<end])
//            return IdentifiableChunk(chunk)
//        }
//    }
//
//    var pairs: [IdentifiableChunk<Element>] {
//        self.chunks(of: 2)
//    }
//}
