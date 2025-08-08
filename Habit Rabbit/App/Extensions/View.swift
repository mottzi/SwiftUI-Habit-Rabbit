import SwiftUI

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
