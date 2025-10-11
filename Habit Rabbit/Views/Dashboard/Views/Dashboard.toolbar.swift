import SwiftUI

extension Habit.Dashboard {
    
    var toolbarControls: some View {
        HStack {
            GlassEffectContainer {
                HStack {
                    Button("Back", systemImage: "chevron.left") {
                        dashboardManager.shiftLastDay(to: .yesterday)
                    }
                    Button("Forward", systemImage: "chevron.right") {
                        dashboardManager.shiftLastDay(to: .tomorrow)
                    }
                }
                .labelStyle(.iconOnly)
                .controlSize(.large)
                .buttonStyle(.glass)
                .glassEffectUnion(id: "group", namespace: unionNamespace)
            }
            
            @Bindable var manager = dashboardManager
            Picker("View Mode", selection: $manager.mode) {
                ForEach(Habit.Card.Mode.allCases) { item in
                    Text(item.localizedTitle)
                }
            }
            .glassEffect()
            .pickerStyle(.segmented)
            .controlSize(.large)
        }
        .fontDesign(.rounded)
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 4)
    }
    
}

extension Habit.Dashboard {
    
    var toolbarTitle: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack(alignment: .leading, spacing: 0) {
                Text(verbatim: "Habit Rabbit")
                    .font(.largeTitle)
                Text(verbatim: dashboardManager.lastDay.formatted)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fontDesign(.monospaced)
            }
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 12)
        }
    }
    
}

extension Habit.Dashboard {
    
    var addHabitButton: some View {
        Button {
            showAddSheet = true
        } label: {
            Image(systemName: "plus")
                .font(.title)
                .fontWeight(.medium)
                .padding()
        }
        .buttonStyle(.glass)
        .clipShape(.circle)
        .buttonBorderShape(.circle)
        .sensoryFeedback(.selection, trigger: showAddSheet)
    }
    
}
