## Purpose

Defines the `setGameContext` MethodChannel contract that allows the Flutter layer to push live match context (role, game category, coaching level, match elapsed seconds) into the native Android `GameTurboOverlayService`, ensuring the autonomous overlay AI prompt stays grounded in the same context as the Flutter coaching layer.

## ADDED Requirements

### Requirement: setGameContext MethodChannel call exists
The system SHALL expose a `setGameContext` method on the overlay MethodChannel. The Flutter `OverlayChannel` class MUST implement a `setGameContext({required String gameCategory, required String preferredRole, required String coachingLevel, required int matchElapsedSeconds})` method that invokes this channel call.

#### Scenario: Flutter fires setGameContext and overlay receives it
- **WHEN** `OverlayChannel().setGameContext(gameCategory: "5v5 MOBA", preferredRole: "Jungler", coachingLevel: "intermediate", matchElapsedSeconds: 180)` is called
- **THEN** `GameTurboOverlayService` MUST store the received values in its instance state before the next AI inference call

#### Scenario: setGameContext is a no-op when overlay service is not bound
- **WHEN** `OverlayChannel().setGameContext(...)` is called but the overlay service has not started
- **THEN** the call MUST complete without throwing and without crashing the Flutter layer

### Requirement: Android overlay prompt uses received game context
The system SHALL incorporate `gameCategory`, `preferredRole`, `coachingLevel`, and `matchElapsedSeconds` received via `setGameContext` into the text-only AI prompt constructed in `GameTurboOverlayService`. The prompt MUST include at minimum: game name, category, role, coaching depth directive, and match elapsed time.

#### Scenario: Text-only prompt includes role and match time
- **WHEN** `setGameContext` has been called with `preferredRole = "Gold Laner"` and `matchElapsedSeconds = 240`
- **THEN** the next text-only AI prompt body MUST contain a string referencing the role "Gold Laner" and a time value of 240 seconds (formatted as MM:SS or raw seconds)

#### Scenario: Vision prompt also carries role and match time
- **WHEN** vision capture is available and `setGameContext` has populated `preferredRole` and `matchElapsedSeconds`
- **THEN** the vision prompt MUST also include those values alongside the screenshot analysis instruction

### Requirement: setGameContext is fired from the toolbox on open
The system SHALL fire `OverlayChannel().setGameContext(...)` in the same post-frame callback that fires the initial `requestAdvice()` when the `GameturboFloatingToolbox` initializes, so the overlay is synchronized before the first autonomous inference cycle.

#### Scenario: Context sync fires alongside initial advice request
- **WHEN** the floating toolbox renders for the first time in a session
- **THEN** both `requestAdvice()` and `setGameContext(...)` MUST be called within the same `WidgetsBinding.instance.addPostFrameCallback`

#### Scenario: Context re-synced on each topic refresh
- **WHEN** the 90-second topic refresh timer fires
- **THEN** the toolbox MUST call `OverlayChannel().setGameContext(...)` with the updated `matchElapsedSeconds` before or alongside `requestTopicRefresh()`
