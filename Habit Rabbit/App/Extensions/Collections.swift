import SwiftUI

extension CaseIterable where Self: Equatable, AllCases: BidirectionalCollection {
    
    var next: Self {
        let all = Self.allCases
        let current = all.firstIndex(of: self)!
        let next = all.index(after: current)
        return all[next == all.endIndex ? all.startIndex : next]
    }
    
    var previous: Self {
        let all = Self.allCases
        let current = all.firstIndex(of: self)!
        let previous = current == all.startIndex ? all.index(before: all.endIndex) : all.index(before: current)
        return all[previous]
    }
    
    var isFirst: Bool {
        Self.allCases.first == self
    }
    
    var isLast: Bool {
        Self.allCases.last == self
    }
    
}

extension RandomAccessCollection {

    var enumerated: [(offset: Int, element: Element)] {
        Array(self.enumerated())
    }
    
}
