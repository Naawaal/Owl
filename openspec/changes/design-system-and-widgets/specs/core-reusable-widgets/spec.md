## Purpose

Specifies the reusable Flutter UI components matching the locked Minimal Titanium & Slate prototype to enable modular screen construction.

## ADDED Requirements

### Requirement: Hero Deck Card Widget
The system SHALL provide a `HeroDeckCard` widget for horizontal snap carousels displaying game icons, titles, categories, active mod pills, and a launch trigger.

#### Scenario: Rendering Hero Deck Card
- **WHEN** rendered with a game model and active mod list
- **THEN** it displays a stylized elevated card with micro-borders, category caption, active mod badges, and an actionable primary launch button.

### Requirement: Tactile Controls Suite
The system SHALL provide reusable `OwlButton`, `OwlSwitch`, and `OwlSlider` controls matching the titanium design aesthetic.

#### Scenario: Toggling a Mod Switch
- **WHEN** user interacts with an `OwlSwitch`
- **THEN** it transitions smoothly between active electric indigo and inactive slate states with haptic feedback.

#### Scenario: Adjusting Guideline Distance
- **WHEN** user drags an `OwlSlider`
- **THEN** it continuously updates the numerical multiplier label and emits the updated double value.

### Requirement: Floating Bottom Navigation Dock
The system SHALL provide a `FloatingBottomNav` widget with an animated sliding indicator pill behind the selected destination.

#### Scenario: Switching Active Tab
- **WHEN** user taps an inactive tab in `FloatingBottomNav`
- **THEN** the indicator pill smoothly slides to the tapped tab's offset and updates active color state.

### Requirement: Non-Blocking Floating Toast
The system SHALL provide an `OwlToast` notification utility that renders a floating pill badge above the UI without blocking user interactions.

#### Scenario: Displaying Status Feedback
- **WHEN** an action completes (e.g. game added or asset staged)
- **THEN** an `OwlToast` animates in near the bottom of the viewport, displays the message with an icon, and auto-dismisses after a configurable duration.
