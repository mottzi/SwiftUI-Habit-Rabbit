import SwiftUI

extension Habit.Dashboard {
    
    var controls: some View {
        HStack(spacing: 12) {
            GlassEffectContainer {
                HStack(spacing: -10) {
                    Button("Back", systemImage: "chevron.left") {
                        dashboardManager.shiftLastDay(to: .yesterday)
                    }
                    Button("Forward", systemImage: "chevron.right") {
                        dashboardManager.shiftLastDay(to: .tomorrow)
                    }
                }
                .fontWeight(.semibold)
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
        .padding(.top, 20)
        .padding(.bottom, 8)
    }
    
}
