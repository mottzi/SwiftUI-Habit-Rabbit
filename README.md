<div align="center">

# Habit Rabbit

Habit Rabbit is a SwiftUI demo project showcasing modern iOS development patterns. I open-sourced this repository to highlight my approach to SwiftUI architecture, SwiftData integration, and custom UI design.

<img width="800" src="https://github.com/user-attachments/assets/f4e174b5-c641-4bcd-9348-ffe12f2b8088" />

</div>

## Architecture & State Management

The app avoids massive views by keeping domain logic decoupled and utilizing the `@Observable` macro alongside Swift's Environment:

* **Global vs. Local State:** A central `Dashboard.Manager` handles global events (like date shifts and view modes) and is injected at the app root via `.environment(dashboardManager)`. Individual cards use their own `Card.Manager` instances, which localizes state updates and minimizes unnecessary redraws across the dashboard.
* **Namespaced Organization:** Domain logic is organized using nested types and extensions (e.g., `Habit.Dashboard.Manager`, `Habit.Card.DetailView`). Manager responsibilities are split across targeted files (like `.valueOperations`, `.lastDayOperations`, and `.viewData`) to keep the codebase maintainable.

## Data Persistence with SwiftData

SwiftData is used to handle data efficiently and maintain a smooth scrolling experience:

* **Relational Models:** The schema separates the `Habit` definition from its historical `Habit.Value` entries, utilizing cascade delete rules to maintain data integrity.
* **Caching & Prefetching:** The `Card.Manager` implements a local dictionary cache to prefetch active rolling windows (e.g., a 30-day core with 14-day buffers). This allows for smooth pagination through dates without constantly querying the persistent store.
* **Targeted Fetching:** Custom `FetchDescriptor` extensions calculate date boundaries dynamically, ensuring the database only fetches the data the view currently requires.

## UI Styling & Animations

The interface leverages custom rendering and modern SwiftUI transition APIs to create a responsive feel:

* **View Transitions:** Layout morphing—such as switching a card between Daily, Weekly, and Monthly views—is handled seamlessly using `.geometryGroup()`, `.matchedGeometryEffect()`, and `.transition(.blurReplace)`.
  
<video src="https://github.com/user-attachments/assets/02f49f3b-1ba2-48b6-b16c-1cc8aef65f12" width="400px" controls></video>

* **Custom Layouts & Drawing:** The custom `ProgressBar` includes a math function that applies a power curve to adjust mid-range values, visually offsetting the shortening caused by SwiftUI's rounded capsule caps. Additionally, the monthly view dynamically calculates column indexes to align data to the correct weekdays on the fly.
* **Context-Aware Theming:** Visual elements adjust based on both the environment (Light/Dark mode) and the data state. For example, completing a target modifies the brightness and border width depending on whether the app is in dark mode or if the habit is considered a "good" or "bad" habit.
* **Micro-Interactions:** Numeric labels use `.monospacedDigit()` and `.contentTransition(.numericText())` for clean tick-ups when logging data. Relevant data triggers are also tied to haptic feedback via `.sensoryFeedback`.

## Navigating the Codebase

To review how these concepts are implemented, here are a few recommended starting points:

* **`Habit Rabbit/App/Models/Habit.swift` & `Value.swift**`: SwiftData models and fetch descriptors.
* **`Habit Rabbit/Views/Card/Manager/Card.Manager.valueOperations.swift`**: Data caching, prefetching, and fetching logic.
* **`Habit Rabbit/Views/Other/ProgressBar/ProgressBar.geometry.swift`**: The math logic used for the progress bar curvature correction.
* **`Habit Rabbit/Views/Dashboard/Dashboard.swift`**: The root view demonstrating dependency injection and the main grid layout.
