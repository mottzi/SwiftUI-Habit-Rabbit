import SwiftUI

extension Habit.Card.DetailView {

    var loadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    var emptyView: some View {
        if values.isEmpty {
            ContentUnavailableView(
                "No Values",
                systemImage: "text.page.slash",
                description: Text("Start tracking to see your progress history here.")
            )
            .frame(height: 200)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 16)
        }
    }
    
    @ViewBuilder
    var loadMoreButton: some View {
        if detailManager?.canLoadMore ?? false {
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
