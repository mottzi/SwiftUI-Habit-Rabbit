# Habit Rabbit Codebase Architecture Insights

## Overview

This document captures critical architectural insights and data flow patterns within the Habit Rabbit iOS application that are essential for understanding and debugging state management issues, particularly those related to habit data navigation and persistence.

## Core Architecture Components

### Data Model Hierarchy

```
Habit (SwiftData @Model)
├── id: UUID
├── name: String
├── target: Int
├── unit: String
├── kind: Habit.Kind (.good | .bad)
└── values: [Habit.Value] (@Relationship)

Habit.Value (SwiftData @Model)
├── habit: Habit? (@Relationship)
├── date: Date (normalized to startOfDay)
└── currentValue: Int
```

### View Architecture

```
Dashboard
└── Habit.Card (per habit)
    ├── Card.Manager (@Observable)
    └── Mode-specific views:
        ├── dailyView
        ├── weeklyView
        └── monthlyView
```

## Critical Data Flow Patterns

### 1. Values Array Management

**Location**: `Habit.Card.Manager`

The `values` array is the central data structure with these invariants:

- **Size**: Maximum 30 elements (sliding window)
- **Ordering**: Chronologically sorted by date (ascending)
- **Constraint**: `values.last` must always correspond to `lastDay`
- **Population**: Via `fetchValues()` using `Habit.Value.filterByDays(30, for:, endingOn:)`

```swift
private var values: [Habit.Value] = []
private(set) var lastDay: Date
```

### 2. Mode-Specific Data Dependencies

#### Daily Mode (`dailyView`)
```swift
var dailyValue: Habit.Value? { values.last }
```
- **Dependency**: Direct reliance on `values.last`
- **Failure Mode**: If `values.last.date != lastDay`, displays incorrect data
- **Critical Path**: `shiftLastDay()` must maintain `values.last` invariant

#### Weekly Mode (`weeklyView`)
```swift
var weeklyValues: [Habit.Value] {
    // Creates 7-day range based on lastDay
    // Uses values.suffix(7) as lookup source
    // Resilient: Creates transient objects for missing days
}
```
- **Dependency**: Uses `values` as lookup dictionary
- **Resilience**: High - gracefully handles missing data
- **Critical Path**: Less sensitive to `values` array corruption

#### Monthly Mode (`monthlyView`)
```swift
var monthlyValues: [[DayCell]] {
    // Creates 35-cell grid based on lastDay
    // Uses entire values array as lookup source
    // Resilient: Creates transient objects for missing days
}
```
- **Dependency**: Uses `values` as lookup dictionary
- **Resilience**: High - gracefully handles missing data
- **Critical Path**: Less sensitive to `values` array corruption

### 3. Navigation Optimization Strategy

**Goal**: Avoid expensive 30-day database refetches during navigation

**Implementation**: `shiftLastDay(to direction: RelativeDay)`

**Critical Insight**: Both forward and backward navigation require the same operation - fetching the `Habit.Value` for the new current day (`newLastDay`).

## Bug Pattern Analysis

### The Daily Mode Navigation Bug

**Symptom**: Backward navigation in daily mode displays incorrect habit values

**Root Cause**: Violation of the `values.last == lastDay` invariant

**Failure Sequence**:
1. User navigates backward (`.yesterday`)
2. `shiftLastDay()` incorrectly fetches wrong day
3. `values.last` no longer corresponds to `lastDay`
4. `dailyValue` returns stale data
5. UI displays incorrect values

### Why Weekly/Monthly Modes Were Unaffected

**Architectural Resilience**: Weekly and monthly modes use `values` array as a lookup dictionary rather than relying on positional access (`values.last`). Their data computation is based on explicit date ranges calculated from `lastDay`, making them immune to array ordering issues.

## Critical Code Patterns

### Correct Navigation Implementation

```swift
func shiftLastDay(to direction: RelativeDay) {
    // Update current day
    let newLastDay = Calendar.current.date(byAdding: .day, value: offset, to: lastDay)!
    lastDay = newLastDay
    
    // CRITICAL: Always fetch the new current day
    let dayToFetch = newLastDay
    
    // Maintain values.last == lastDay invariant
    switch direction {
        case .yesterday:
            values.removeAll { $0.date > newLastDay }
            if values.last?.date != newLastDay {
                values.append(newValue)
            }
        case .tomorrow:
            values.append(newValue)
            while values.count > 30 { values.removeFirst() }
    }
}
```

### Data Fetching Patterns

```swift
// 30-day window query
static func filterByDays(_ days: Int, for habit: Habit, endingOn date: Date) -> FetchDescriptor<Habit.Value> {
    // Returns chronologically sorted results
    // Includes proper date range filtering
    // Optimized with relationship prefetching
}
```

## Debugging Insights

### Key Diagnostic Questions

1. **Does `values.last.date == lastDay`?** 
   - If false, daily mode will show incorrect data
   
2. **Is the `values` array chronologically ordered?**
   - If false, all computed properties may be affected
   
3. **Does navigation maintain the 30-day sliding window?**
   - If false, memory usage may grow unbounded

### Debug Verification Points

```swift
// Critical assertion for daily mode
assert(dailyValue?.date.isSameDay(as: lastDay) == true, "Daily value date mismatch")

// Array integrity check
assert(values.isEmpty || values.last!.date <= lastDay, "Values array contains future dates")

// Window size verification
assert(values.count <= 30, "Values array exceeds 30-day limit")
```

## Performance Considerations

### Optimization Principles

1. **Single Database Fetch**: Navigation should fetch only the required day's data
2. **Array Efficiency**: Use append/removeFirst for O(1) operations when possible
3. **Memory Management**: Maintain fixed 30-day window to prevent unbounded growth
4. **SwiftData Optimization**: Leverage relationship prefetching and proper fetch descriptors

### Anti-Patterns

- **Full refetch on navigation**: Defeats optimization purpose
- **Linear search in values array**: Use dictionary lookups for date-based access
- **Unbounded array growth**: Always maintain size limits
- **Positional assumptions**: Only daily mode should rely on `values.last`

## Testing Strategies

### Navigation Testing

```swift
// Test sequence: Forward → Backward → Backward → Forward
// Verify at each step:
// 1. lastDay updates correctly
// 2. values.last.date == lastDay
// 3. Habit values persist across navigation
// 4. Array size remains bounded
```

### Mode-Specific Testing

- **Daily**: Focus on `values.last` invariant
- **Weekly**: Test 7-day window calculation
- **Monthly**: Test grid layout and date alignment

## SwiftData Integration Notes

### Model Relationships

```swift
@Relationship var values: [Habit.Value] // One-to-many
```

### Fetch Optimization

```swift
descriptor.relationshipKeyPathsForPrefetching = [\Habit.Value.habit]
```

### Date Normalization

```swift
self.date = date.startOfDay // Critical for date-based queries
```

This architectural understanding is essential for maintaining data consistency and debugging state management issues in the Habit Rabbit application.
