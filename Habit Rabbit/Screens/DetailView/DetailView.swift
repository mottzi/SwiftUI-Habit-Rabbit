
import SwiftUI
import SwiftData

extension Habit.Card {
    
    struct DetailView: View {
        
        @Environment(Habit.Card.Manager.self) var cardManager
        @Environment(Habit.Dashboard.Manager.self) var dashboardManager
        @State private var detailManager: Habit.Card.DetailView.Manager?
        
        var body: some View {
            Group {
                if let detailManager {
                    if detailManager.values.isEmpty && !detailManager.isLoading {
                        VStack {
                            Image(systemName: detailManager.icon)
                                .font(.system(size: 48))
                                .foregroundStyle(detailManager.color)
                                .padding(.bottom, 16)
                            
                            Text("No Values Yet")
                                .font(.title2.weight(.semibold))
                                .padding(.bottom, 8)
                            
                            Text("Start tracking this habit to see your progress here.")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    } else {
                        List(detailManager.values, id: \.date) { value in
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
                    }
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

