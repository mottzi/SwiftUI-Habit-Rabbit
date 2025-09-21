//
//  ProgressBar.style.swift
//  Habit Rabbit
//
//  Created by Berken Sayilir on 21.09.2025.
//


extension Habit.ProgressBar {
    
    private var isDark: Bool { colorScheme == .dark }
    private var isDaily: Bool { mode == .daily }
    private var exceedsTarget: Bool { value > target }
    
    var colorBrightness: Double {
        switch (kind, isDark, exceedsTarget) {
            case (.bad, _, _)          :  0     // bad habit: no adjustment
            case (.good, true, true)   :  0.1   // exceeding good habit in dark mode: brighter color
            case (.good, true, false)  : -0.1   // non-exceeding good habit in dark mode: darker color
            case (.good, false, true)  : -0.1   // exceeding good habit in light mode: darker color
            case (.good, false, false) :  0.1   // non-exceeding good habit in light mode: brighter color
        }
    }
    
    var trackBrightness: Double {
        switch (kind, isDark, exceedsTarget) {
            case (.good, _, _)       :  0.2   // good habits: no adjustment
            case (.bad, _, false)    :  0.2   // non-exceeding bad habit in dark mode: no adjustment
            case (.bad, true, true)  : -0.6   // exceeding bad habit in dark mode: much darker
            case (.bad, false, true) : -0.5   // exceeding bad habit in light mode: darker
        }
    }
    
    var trackBorderWidth: Double {
        switch (kind, isDark, exceedsTarget, isDaily) {
            case (.good, _, _, _)          :  0     // good habits: no stroke
            case (.bad, _, false, _)       :  0     // non-exceeding bad habit: no stroke
            case (.bad, false, true, _)    :  0     // exceeding bad habit in light mode: no stroke
            case (.bad, true, true, true)  :  1.5   // exceeding bad habit in daily dark mode: thick stroke
            case (.bad, true, true, false) :  0.75  // exceeding bad habit in other dark mode: medium stroke
        }
    }
    
}