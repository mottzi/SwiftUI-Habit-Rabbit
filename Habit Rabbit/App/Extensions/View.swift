import SwiftUI

extension View {

    func debug(_ color: Color? = nil, _ width: CGFloat? = nil) -> some View {
        self.border(color ?? .orange, width: width ?? 2)
    }
    
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        @ViewBuilder then: (Self) -> TrueContent,
        @ViewBuilder `else`: (Self) -> FalseContent
    ) -> some View {
        if condition {
            then(self)
        } else {
            `else`(self)
        }
    }
    
    @ViewBuilder
    func `if`<TrueContent: View>(
        _ condition: Bool,
        @ViewBuilder then: (Self) -> TrueContent
    ) -> some View {
        if condition {
            then(self)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func safeAreaBarIfAvailable<Content: View>(
        edge: VerticalEdge,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        if #available(iOS 26.0, *) {
            self.safeAreaBar(edge: edge) {
                content()
            }
        } else {
            self
        }
    }
    
}
