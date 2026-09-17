## Context

See `proposal.md` for motivation and background.

Currently, the Android system runs on MediaTek/Qualcomm hardware (e.g. MediaTek Dimensity 7200-Ultra on Redmi Note 13 Pro+ / Android 16 / HyperOS). Kernel sysfs nodes for FPS are restricted by SELinux, and third-party apps lack root or `DUMP` permission to invoke `dumpsys SurfaceFlinger`. However, the app possesses `SYSTEM_ALERT_WINDOW` and an active `MediaProjection` foreground session.

In the UI layer, `GameSpaceConsoleScreen` features an established HyperOS 2026 gaming design with a top status bar (battery shell, CPU badge, FPS badge, central interactive `● TURBO <fps> FPS 🎛️` pill). In contrast, `TacticalBattlefieldHud` uses a divergent layout, while the native floating handle displays mismatched typography and icons.

## Goals / Non-Goals

**Goals:**
- Provide genuine, low-overhead frame rate measurement using `ImageReader` arrival timestamps when MediaProjection is active, combined with `Choreographer` on the overlay window.
- Physically enforce display refresh rates (60Hz vs 120Hz) via modern Android WindowManager APIs (`preferredDisplayModeId`, `preferredMinDisplayRefreshRate`, `preferredMaxDisplayRefreshRate`).
- Achieve 1:1 visual and behavioral UI/UX parity between the Console Screen, In-Game HUD, and native overlay handles.
- Decouple screen capture encoding from image arrival to eliminate frame processing lag.
- Keep Guardian AI isolated as an autonomous battlefield floating bubble without redundant in-toolbox callouts.

**Non-Goals:**
- Kernel driver modifications or root-level sysfs hacking.
- Altering the multimodal AI inference pipeline itself.
- Forcing game engines to bypass internal frame rate caps (e.g., if Pokémon UNITE caps at 60 FPS, the telemetry must truthfully display ~58–60 FPS rather than synthesizing 120 FPS).

## Decisions

### 1. Slotted Circular Frame Sampler vs Continuous Frame Compression
- **Decision**: In `ImageReader.setOnImageAvailableListener`, record arrival timestamp in a lightweight circular buffer (`LongArray(128)`) and close the image immediately in under 0.1ms. Only extract and compress Bitmap to JPEG/PNG when an explicit screen capture is flagged as pending.
- **Rationale**: Compressing 60–120 frames per second into JPEG and PNG caused severe CPU spikes, garbage collection pauses, and false frame drops.
- **Alternatives Considered**:
  - Continuous compression: Rejected due to prohibitive thermal and CPU load.
  - Relying solely on `Choreographer`: Rejected because `Choreographer` on an overlay window measures display composition vsync, not the underlying game engine's frame output rate.

### 2. Multi-Tier Display Refresh Rate Switching
- **Decision**: Look up matching `Display.Mode` from `display.supportedModes` and assign `lp.preferredDisplayModeId` along with Android 12+ (API 31+) `lp.preferredMinDisplayRefreshRate` and `lp.preferredMaxDisplayRefreshRate` on overlay and activity windows.
- **Rationale**: Setting only `lp.preferredRefreshRate` is deprecated and ignored on Android 11+. Setting the mode ID and min/max limits informs Android's `DisplayModeDirector` to switch physical panel refresh rates.
- **Alternatives Considered**:
  - Modifying `Settings.System.putInt("peak_refresh_rate")`: Rejected because it requires `WRITE_SETTINGS` or `WRITE_SECURE_SETTINGS` permissions that are not granted at runtime.

### 3. Unified Top Bar Architecture across Console and In-Game HUD
- **Decision**: Port the battle-tested `_buildTopStatusBar` structure from `GameSpaceConsoleScreen` into `TacticalBattlefieldHud` and mirror its pill geometry in `GameTurboOverlayService.kt`.
- **Rationale**: Users expect identical visual hierarchy and control mechanisms whether managing game profiles or reviewing in-game telemetry.
- **Alternatives Considered**:
  - Keeping separate HUD and Console designs: Rejected because user explicitly required "same to same UI/UX".

### 4. Separate Floating Guardian AI Bubble
- **Decision**: Keep Guardian AI displayed solely as its dedicated floating tactical pill on the battlefield; remove duplicate inline coaching callouts from `GameturboFloatingToolbox`.
- **Rationale**: Redundant advice in the toolbox consumes vertical space and contradicts user preference for clean in-game separation.

## Risks / Trade-offs

- **[Risk] Game renders at lower rate than display mode** → **Mitigation**: Truth in telemetry. In Performance Mode with 120Hz display, if a game is internally capped at 60 FPS, the counter shows ~60 FPS. Tachometer gauge dial scales to mode ceiling (60 in Balanced, 120 in Performance) to make performance headroom clear.
- **[Risk] MediaProjection session not started** → **Mitigation**: Gracefully fall back to `Choreographer` composition frame rate on the overlay window, which reflects the physical screen refresh rate.
