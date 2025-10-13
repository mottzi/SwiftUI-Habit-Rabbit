import SwiftUI

extension Habit {

    struct ProgressLabel: View {

        @Environment(\.colorScheme) var colorScheme

        let value: Int
        let target: Int
        let unit: String

        var body: some View {
            switch target {
                case   ...99: singleLineLabel
                case ...9999: multiLineLabel
                default: multiLineLabelSmall
            }
        }

    }
    
}

extension Habit.ProgressLabel {
    
    var singleLineLabel: some View {
        VStack(spacing: 2) {
            (
                Text(verbatim: "\(value)")
                    .foregroundStyle(.primary.opacity(colorScheme == .dark ? 1 : 0.8))
                +
                Text(verbatim: " / ")
                    .foregroundStyle(.primary.opacity(0.6))
                +
                Text(verbatim: "\(target)")
                    .foregroundStyle(.primary.opacity(0.6))
            )
            .font(.title2)
            .fontWeight(.semibold)
            .monospacedDigit()
            .contentTransition(.numericText())
            
            Text(verbatim: unit.pluralized(count: target))
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .minimumScaleFactor(0.7)
        .lineLimit(1)
        .padding(.horizontal, 2)
    }
    
    var multiLineLabel: some View {
        VStack(spacing: 0) {
            Text("\(value)")
                .foregroundStyle(.primary.opacity(colorScheme == .dark ? 1 : 0.8))
                .overlay(alignment: .trailing) {
                    Text(verbatim: "/")
                        .foregroundStyle(.primary.opacity(0.6))
                        .offset(x: 12)
                }
                
            Text("\(target)")
                .foregroundStyle(.primary.opacity(0.6))
            
            Text(verbatim: unit.pluralized(count: target))
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .padding(.top, 2)
                .offset(x: 2)
        }
        .font(.title3)
        .fontWeight(.semibold)
        .monospacedDigit()
        .contentTransition(.numericText())
        .minimumScaleFactor(0.7)
        .lineLimit(1)
        .offset(x: -2)
    }
    
    var multiLineLabelSmall: some View {
        VStack(spacing: 0) {
            Text("\(value)")
                .foregroundStyle(.primary.opacity(colorScheme == .dark ? 1 : 0.8))
                .overlay(alignment: .trailing) {
                    Text(verbatim: "/")
                        .foregroundStyle(.primary.opacity(0.6))
                        .offset(x: 10)
                }
                
            Text("\(target)")
                .foregroundStyle(.primary.opacity(0.6))
            
            Text(verbatim: unit.pluralized(count: target))
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .padding(.top, 2)
                .offset(x: 2)
        }
        .font(.headline)
        .fontWeight(.semibold)
        .monospacedDigit()
        .contentTransition(.numericText())
        .minimumScaleFactor(0.7)
        .lineLimit(1)
        .offset(x: -2)
    }
    
}
