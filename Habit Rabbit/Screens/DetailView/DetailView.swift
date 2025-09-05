
import SwiftUI
import SwiftData

extension Habit.Card {
    
    struct DetailView: View {
        
        @Environment(Habit.Card.Manager.self) private var cardManager
        @Environment(Habit.Dashboard.Manager.self) private var dashboardManager
        @State private var detailManager: Habit.Card.DetailView.Manager?
        
        var body: some View {
            Group {
                if let detailManager {
                    List(detailManager.values) { value in
                        HStack {
                            Text("\(value.date.formatted2)")
                            Spacer()
                            Text("\(value.currentValue)")                                    
                        }
                    }
                    .environment(detailManager)
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        if detailManager.canLoadMore {
                            loadMoreButton
                        }
                    }
                    .contentMargins(.top, 16)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle(cardManager.habit.name)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if detailManager == nil {
                    detailManager = Habit.Card.DetailView.Manager(
                        for: cardManager.habit,
                        using: dashboardManager.modelContext
                    )
                }
            }
        }
        
        private var loadMoreButton: some View {
            Button {
                detailManager?.loadMoreValues()
            } label: {
                HStack {
                    if detailManager?.isLoading == true {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Text("Load More Values")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
            .disabled(detailManager?.isLoading == true)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        
    }
    
}

