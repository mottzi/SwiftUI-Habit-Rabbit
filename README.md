<div align="center">

# Habit Rabbit

Habit Rabbit is a SwiftUI demo project showcasing modern iOS development patterns. I open-sourced this repository to highlight my approach to SwiftUI architecture, SwiftData integration, and custom UI design.

<img width="800" src="https://github.com/user-attachments/assets/f4e174b5-c641-4bcd-9348-ffe12f2b8088" />

</div>

## Architecture & State Management

The app avoids massive views by keeping domain logic decoupled and utilizing the `@Observable` macro alongside Swift's Environment. 

* **Explicit Dependency Injection:**

  Rather than relying solely on SwiftUI's implicit data flow, the `ModelContainer` is explicitly initialized at the app root (`HabitRabbit.swift`). Its `mainContext` is safely passed into a central `Dashboard.Manager`, which is then injected into the view hierarchy via `.environment()`.

* **Manager Lifecycle & View Model Caching:**

  To prevent performance degradation and state resets in dynamic grids, the app does not blindly recreate view models. The `Dashboard.Manager` acts as a factory, maintaining a `[PersistentIdentifier: Habit.Card.Manager]` cache. This maps SwiftData models to stable, long-living `@Observable` card managers, ensuring fluid redraws and strict separation of concerns.

* **Reusable Forms & Focus Management:**

  Data entry is handled by a highly reusable `Dashboard.Sheet` component that drives both the "Add" and "Edit" workflows via an `InitialValues` struct. The form includes production-level UX details, such as programmatic keyboard focus management (`FocusState`) to smoothly advance users through the input fields.

## Data Persistence with SwiftData

SwiftData is used to handle data persistence efficiently and maintain a smooth scrolling experience, even as historical data grows:

* **Relational Models:**

  The schema separates the `Habit` definition from its historical `Habit.Value` entries, utilizing cascade delete rules to maintain data integrity.

* **Caching & Prefetching (Card Level):**

  The `Card.Manager` implements a local dictionary cache to prefetch active rolling windows (e.g., a 30-day core with 14-day buffers). This allows for smooth pagination through dates without constantly hitting the persistent store.
  
* **Cursor-Based Pagination (Detail Level):**

  To ensure memory safety for habits with years of history, the `DetailView.Manager` implements cursor-based pagination. Using `fetchOffset` and `fetchLimit`, it loads historical records in discrete chunks (100 at a time) only when requested by the user.

## UI Styling & Animations

The interface features custom components and uses modern SwiftUI transition APIs to create a responsive, fluid feel:

* **Modern View Transitions:**

  Layout morphing—such as switching a card between daily, weekly, and monthly views—is handled seamlessly using `.geometryGroup()` and `.matchedGeometryEffect()`. Furthermore, navigating to the Detail View utilizes the modern `.navigationTransition(.zoom(sourceID:))` API for continuous, fluid hero animations.

## UI Styling & Animations

The interface has custom components and uses modern SwiftUI transition APIs to create a responsive feel:

* **View Transitions:**

  Layout morphing like switching a card between daily, weekly, and monthly views is handled seamlessly using `.geometryGroup()`, `.matchedGeometryEffect()`, and `.transition(.blurReplace)`.
  
<video src="https://github.com/user-attachments/assets/02f49f3b-1ba2-48b6-b16c-1cc8aef65f12" width="400px" controls></video>

* **Custom Components:**

  The custom `ProgressBar` includes a math function that applies a power curve to adjust mid-range values, visually offsetting the shortening caused by SwiftUI's rounded capsule caps. Additionally, the monthly view dynamically calculates column indexes to align data to the correct weekdays on the fly.
  
* **Context-Aware Theming:**

  Visual elements adjust based on both the environment (light/dark mode) and the data state. For example, completing a target modifies the brightness and border width depending on whether the app is in dark mode or if the habit is considered a "good" or "bad" habit.
  
* **Micro-Interactions:**

  Numeric labels use `.monospacedDigit()` and `.contentTransition(.numericText())` for clean tick-ups when logging data. Relevant data triggers are also tied to haptic feedback via `.sensoryFeedback`.

## Navigating the Codebase

To review how these concepts are implemented, here are a few recommended starting points:

* **`/App/Models/Habit.swift` & `Value.swift**`**: SwiftData models and fetch descriptors.
* **`/Views/Card/Manager/Card.Manager.valueOperations.swift`**: Data caching, prefetching, and fetching logic.
* **`/Views/Other/ProgressBar/ProgressBar.geometry.swift`**: The math logic used for the progress bar curvature correction.
* **`/Views/Dashboard/Dashboard.swift`**: The root view demonstrating dependency injection and the main grid layout.
