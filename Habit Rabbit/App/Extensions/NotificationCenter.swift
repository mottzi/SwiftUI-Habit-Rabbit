import SwiftUI
import Combine


extension NotificationCenter {
    
    static var calendarDayChanged: AnyPublisher<Void, Never> {
        NotificationCenter.default
            .publisher(for: .NSCalendarDayChanged)
            .map { _ in () }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
}

extension View {
    
    func onCalendarDayChanged(perform action: @escaping () -> Void) -> some View {
        self.onReceive(NotificationCenter.calendarDayChanged) { _ in
            action()
        }
    }
    
}
