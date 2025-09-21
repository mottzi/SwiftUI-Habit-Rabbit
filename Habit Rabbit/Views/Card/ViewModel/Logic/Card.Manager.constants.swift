import SwiftUI

extension Habit.Card.Manager {
    
    static let cardHeight: CGFloat = 232
    static let cornerRadius: CGFloat = 24
    static let contentHeight: CGFloat = 155
    static let cubesGridHeight: CGFloat = 126 // 6 rows: 6 * 16 (cube) + 5 * 6 (spacing) = 126
    
    var labelBottomPadding: CGFloat {
        switch mode {
            case .daily: 20
            case .weekly: 10
            case .monthly: 14
        }
    }
    
}
