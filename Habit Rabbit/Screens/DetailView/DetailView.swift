import SwiftUI
import SwiftData

extension Habit.Card {

    struct DetailView: View {

        @Environment(\.colorScheme) var colorScheme
        @Environment(Habit.Card.Manager.self) var cardManager
        @Environment(Habit.Dashboard.Manager.self) var dashboardManager

        @State var detailManager: Habit.Card.DetailView.Manager?
        var values: [Habit.Value] { detailManager?.values ?? [] }
        
        @State var editingValue: Habit.Value?
        @State var editValueText: String = ""
        
        var body: some View {
            Group {
                if let detailManager {
                    valuesList
                        .safeAreaInset(edge: .bottom, spacing: 0) { loadMoreButton }
                        .contentMargins(.top, 16)
                        .environment(detailManager)
                } else {
                    loadingView
                }
            }
            .navigationTitle(cardManager.habit.name)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { setupDetailManager() }
            .alert("Edit Value",
                isPresented: .constant(editingValue != nil),
                actions: { editValueAlert },
                message: { editValueMessage }
            )
        }

    }

}

extension Habit.Card.DetailView {
    
    func setupDetailManager() {
        if detailManager == nil {
            detailManager = Habit.Card.DetailView.Manager(
                for: cardManager.habit,
                using: dashboardManager.modelContext
            )
        }
    }
    
}
