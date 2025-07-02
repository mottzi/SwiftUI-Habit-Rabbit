import Foundation

extension Array {
    func chunks(of size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
    
    func randomElements(count n: Int) -> [Element] {
        guard n > 0 else { return [] }
        return Array(shuffled().prefix(n))
    }
}
