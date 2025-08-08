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
