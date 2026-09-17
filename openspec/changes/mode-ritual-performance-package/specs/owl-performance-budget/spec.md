## Purpose

Gates Owl’s own background coaching and capture load by Balanced vs Performance so the game gains thermal and CPU headroom on every Android device without OEM privileges.

## ADDED Requirements

### Requirement: Balanced reduces Owl background load
While Balanced mode is active and a game session overlay is running, the system MUST pause or substantially slow autonomous coach ticks and topic refresh, MUST NOT keep a MediaProjection session warm solely for sampling, and MUST disable or rarefy guardian auto-refresh.

#### Scenario: Balanced mid-match with AI previously on
- **WHEN** the user switches to Balanced during an active overlay session
- **THEN** autonomous coaching cadence stops or slows to at most one-third of the Performance cadence and MediaProjection is not held open without an explicit capture request

### Requirement: Performance allows coaching without fighting the rail
While Performance mode is active, coaching and on-demand vision MAY run when the user has AI enabled, but while only the collapsed edge rail is visible the system MUST keep overlay Choreographer and Flutter stats emission off or throttled as already required for anti-jank.

#### Scenario: Performance with rail collapsed
- **WHEN** Performance is active and the toolbox is collapsed to the edge rail
- **THEN** the system does not run per-frame overlay Choreographer sampling and does not emit Flutter toolbox stats

### Requirement: Budget follows mode toggle
The Owl performance budget MUST update whenever mode changes through the shared toggle path, including cold start restore from persisted settings.

#### Scenario: Cold start Balanced
- **WHEN** the app or overlay service starts with persisted Balanced mode
- **THEN** the Balanced Owl budget is applied without requiring another user tap
