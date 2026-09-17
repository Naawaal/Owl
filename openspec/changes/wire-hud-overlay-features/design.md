## Context

The Game Turbo overlay HUD in [`GameturboFloatingToolbox`](file:///d:/Celora/owl/lib/features/overlay/presentation/gameturbo_floating_toolbox.dart) and [`TacticalBattlefieldHud`](file:///d:/Celora/owl/lib/features/overlay/presentation/tactical_battlefield_hud.dart) presents four primary competitive gaming utilities: **DND**, **Wi-Fi**, **AI**, and **Voice**. Currently, DND and Wi-Fi toggle local settings without guaranteed platform hooks, the AI coach remains completely silent without an external BYOK key, and the Voice Changer is an un-wired boolean flag.

See `proposal.md` for motivation and background.

## Goals / Non-Goals

**Goals:**
- Connect DND directly to Android's `NotificationManager` interruption filter with explicit permission validation.
- Connect Wi-Fi boost to Android `WifiManager` low-latency lock (`WIFI_MODE_FULL_LOW_LATENCY`) with real-time ping telemetry.
- Upgrade the AI Coach with an offline heuristic engine that delivers game-specific tactical advice when no cloud API key is configured, while allowing instant online inference when a key exists.
- Implement real-time microphone DSP voice modulation via native Android audio pipelines with selectable tactical presets (Commander, Cybernetic, Tactical Radio, Studio).
- Ensure all 4 tools reflect their true platform and service activation states in the UI.

**Non-Goals:**
- Building cloud voice modulation servers (all audio DSP is processed entirely on-device).
- Implementing OS-level kernel hooks that require root permissions.

## Decisions

### Decision 1: Dedicated `SystemControlsPlugin` MethodChannel
- **Choice:** Consolidate DND, Wi-Fi Lock, and System Policy under `com.example.owl/system_controls` in `MainActivity.kt`.
- **Rationale:** Keeps native platform interactions centralized, reusable across HUD overlays and settings, and prevents fragmented channel declarations.
- **Alternatives Considered:** Using third-party plugins from pub.dev. Rejected because custom Game Turbo OEM behavior requires tight coordination with Android 14+ ZenMode and low-latency Wi-Fi lock APIs.

### Decision 2: Dual-Engine AI Architecture (Cloud BYOK + Offline Heuristics)
- **Choice:** Maintain the existing `CoachService` and `InferenceClient` architecture for online LLMs (Gemini, Claude, OpenAI, DeepSeek), while introducing an `OfflineTacticalHeuristicsEngine` fallback when `apiKey == null`.
- **Rationale:** The AI feature must never feel like a dummy or empty box. Players without API keys immediately receive tactical directives based on game genre, active title, match time, and thermal status.
- **Alternatives Considered:** Requiring an API key before showing anything. Rejected because it leaves the default experience looking broken or abandoned.

### Decision 3: Native On-Device Audio DSP for Voice Modulation
- **Choice:** Implement an Android audio capture and playback loop using `AudioRecord` and `AudioTrack` with real-time circular buffer pitch scaling and ring modulation in Kotlin.
- **Rationale:** Low latency (<20ms) is essential for in-game squad voice comms. Processing on the native thread avoids Dart VM garbage collection pauses.
- **Alternatives Considered:** Pure Dart audio processing. Rejected due to audio buffer latency and bridge transfer overhead.

### Decision 4: Interactive HUD Action Buttons with Feedback
- **Choice:** Tapping DND or Wi-Fi triggers haptic feedback and invokes the corresponding platform service. Tapping AI triggers tactical inference / heuristic generation. Tapping Voice toggles modulation, while long-pressing Voice opens the preset drawer.
- **Rationale:** Matches the interaction design of flagship gaming phone OEM toolboxes (Xiaomi Game Turbo / ASUS ROG Armoury Crate).

## Risks / Trade-offs

- **[Risk] Missing Notification Policy Permission** → Mitigation: Check `notificationManager.isNotificationPolicyAccessGranted` before invoking ZenMode; if false, launch `Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS` with an in-app explanatory snackbar.
- **[Risk] Wi-Fi Lock Battery Consumption** → Mitigation: Automatically release the `WifiLock` when the overlay service terminates or when gameplay ends.
- **[Risk] Audio Feedback / Echo during Voice Modulation** → Mitigation: Apply low-gain normalization and ensure microphone loopback is routed strictly to communication streams.
- **[Risk] Low Memory on Budget Devices** → Mitigation: Offline heuristics use lightweight lookup matrices (<50KB memory footprint) rather than local neural network weights.
