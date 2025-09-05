import SwiftUI
import SwiftData

extension Habit.Card {

    struct DetailView: View {

        @Environment(Habit.Card.Manager.self) private var cardManager
        @Environment(Habit.Dashboard.Manager.self) private var dashboardManager
        
        @State private var detailManager: Habit.Card.DetailView.Manager?
        @State private var editingValue: Habit.Value?
        @State private var editValueText: String = ""

        var body: some View {
            Group {
                if let detailManager {
                    valuesList
                        .environment(detailManager)
                        .safeAreaInset(edge: .bottom, spacing: 0) {
                            if detailManager.canLoadMore {
                                loadMoreButton
                            }
                        }
                        .contentMargins(.top, 16)
                } else {
                    loadingView
                }
            }
            .navigationTitle(cardManager.habit.name)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { setupDetailManager() }
            .alert("Edit Value", isPresented: .constant(editingValue != nil)) {
                editValueAlert
            } message: {
                editValueMessage
            }
        }

    }

}

extension Habit.Card.DetailView {

    private var valuesList: some View {
        List(detailManager?.values ?? []) { value in
            valueRow(for: value)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    swipeActions(for: value)
                }
        }
    }
    
    private func valueRow(for value: Habit.Value) -> some View {
        HStack {
            Text(verbatim: "\(value.date.formatted2)")
            Spacer()
            Text(verbatim: "\(value.currentValue)")
        }
    }

}

extension Habit.Card.DetailView {
    
    @ViewBuilder
    private func swipeActions(for value: Habit.Value) -> some View {
        Button {
            editingValue = value
            editValueText = "\(value.currentValue)"
        } label: {
            Label("Edit", systemImage: "pencil")
        }
        .tint(.blue)
        
        Button {
            detailManager?.resetValue(value)
        } label: {
            Label("Reset", systemImage: "trash")
        }
        .tint(.red)
    }
    
    @ViewBuilder
    private var editValueAlert: some View {
        TextField("Value", text: $editValueText)
            .keyboardType(.numberPad)
        Button("Cancel", action: cancelEdit)
        Button("Save", action: saveEdit)
    }
    
    @ViewBuilder
    private var editValueMessage: some View {
        if let value = editingValue {
            Text("Enter new value for \(value.date.formatted2)")
        }
    }
    
}

extension Habit.Card.DetailView {

    private var loadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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

extension Habit.Card.DetailView {

    private func setupDetailManager() {
        if detailManager == nil {
            detailManager = Habit.Card.DetailView.Manager(
                for: cardManager.habit,
                using: dashboardManager.modelContext
            )
        }
    }

    private func cancelEdit() {
        editingValue = nil
        editValueText = ""
    }

    private func saveEdit() {
        if let value = editingValue,
           let newValue = Int(editValueText) {
            detailManager?.updateValue(value, to: newValue)
        }
        editingValue = nil
        editValueText = ""
    }

}
