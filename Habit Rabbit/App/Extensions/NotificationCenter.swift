import SwiftUI
import Combine

extension View {
    
    func onCalendarDayChanged(action: @escaping () -> Void) -> some View {
        self.task {
            for await _ in NotificationCenter.default.notifications(named: .NSCalendarDayChanged) {
                action()
            }
        }
    }
    
}
