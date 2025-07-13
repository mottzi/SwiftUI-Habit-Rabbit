import SwiftUI

extension View {
    func debug(_ color: Color? = nil, _ width: CGFloat? = nil) -> some View {
        self.border(color ?? .orange, width: width ?? 2)
    }
}

extension RandomAccessCollection {
    var enumerated: [(offset: Int, element: Element)] {
        Array(self.enumerated())
    }
}

//extension HashedColletion {
////    mutating func insert(_ newMember: Element) {
////        self.insert
////    }
//    
//    mutating func insert(_ newMember: Element) {
//    }
//
//}
