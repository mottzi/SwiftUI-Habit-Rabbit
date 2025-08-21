import SwiftUI

extension Habit.Dashboard {

    struct AddHabitSheet: View {

        @Environment(\.colorScheme) var colorScheme
        @Environment(\.dismiss) var dismiss

        var body: some View {
            NavigationView {
                VStack {
                    Text("Content")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Spacer()
                }
                .navigationTitle("Add Habit")
                .navigationBarTitleDisplayMode(.inline)
                .padding()
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) { closeButton }
                    ToolbarItem(placement: .topBarTrailing) { addButton }
                }
            }
            .presentationBackground(.regularMaterial)
        }

        private var closeButton: some View {
            Button(role: .destructive) {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .fontWeight(.semibold)
                    .frame(width: 44, height: 44)
                    .background { Habit.Card.Background(in: .circle, material: .ultraThinMaterial) }
            }
            .padding(.top, 4)
            .tint(.red)
        }

        private var addButton: some View {
            Button() {
                dismiss()
            } label: {
                Image(systemName: "plus")
                    .fontWeight(.semibold)
                    .frame(width: 44, height: 44)
                    .background { Habit.Card.Background(in: .circle, material: .ultraThinMaterial) }
            }
            .padding(.top, 4)
            .tint(.green)
        }

    }
    
}
