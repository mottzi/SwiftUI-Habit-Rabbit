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
