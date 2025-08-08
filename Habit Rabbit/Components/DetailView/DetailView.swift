
import SwiftUI

extension Habit.Card {
    
    struct DetailView: View {
        
        @Environment(Habit.Card.Manager.self) var cardManager
        
        var body: some View {
            NavigationStack {
                ScrollView {
                    Habit.AverageView()
                        .environment(cardManager)
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .padding(.top, 16)
                }
                .navigationTitle(cardManager.habit.name)
                .toolbarTitleDisplayMode(.inline)
            }
        }
        
    }
    
}
