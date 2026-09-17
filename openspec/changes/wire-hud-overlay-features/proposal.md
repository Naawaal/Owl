## Why

The Game Turbo floating HUD toolbox displays four key action buttons: **DND**, **Wi-Fi**, **AI**, and **Voice**. Currently, several of these are UI stubs or disconnected local states (for example, the AI and Voice buttons merely toggle local boolean variables without triggering underlying native or domain services, and the AI coach remains completely silent without an external API key). 

This change replaces all dummy implementations with complete, production-grade logic: native Android DND notification filtering via `NotificationManager`, low-latency Wi-Fi locking via Android `WifiManager`, a dual-mode AI coach featuring live LLM inference with offline tactical heuristics fallback, and a real-time DSP microphone voice modulation engine.

## What Changes

- **Overlay DND Native Bridge**: Connect the DND button to native Android `NotificationManager` Zen Mode / Notification Policy and heads-up banner suppression with explicit permission handling (`ACCESS_NOTIFICATION_POLICY`).
- **Overlay Wi-Fi Low-Latency Lock**: Connect the Wi-Fi button to an Android native `WifiLock` (`WIFI_MODE_FULL_LOW_LATENCY`) and live latency tracking service to optimize packet prioritization during gaming.
- **Dual-Engine Tactical AI Coach**: Wire the AI button to trigger tactical coaching immediately. If an API key is present, query the configured LLM (Gemini, OpenAI, Claude, DeepSeek); if offline or unconfigured, dynamically generate game-specific heuristic tactical insights for the active title (Mobile Legends, Free Fire, PUBG, etc.) so the AI is always functional and never silent.
- **Tactical Voice Modulation Engine**: Implement a real microphone capture and DSP pitch/formant shifting pipeline via Android audio streams with four tactical voice presets (Commander, Cybernetic, Tactical Radio, Chipmunk) and mic permission flows.
- **Overlay State Synchronization**: Ensure all 4 tools reflect their true hardware/system activation state across `GameTurboSettingsNotifier`, `TacticalBattlefieldHud`, and `GameturboFloatingToolbox`.

## Capabilities

### New Capabilities
- `overlay-dnd-manager`: Native Android Do Not Disturb and notification banner suppression system with permission inspection and recovery flows.
- `overlay-wifi-optimizer`: Android `WifiLock` low-latency network optimization service with real-time ping telemetry.
- `overlay-ai-tactical-engine`: In-overlay tactical AI coach supporting live cloud LLM inference and offline heuristic game analysis.
- `overlay-voice-changer`: Real-time microphone audio processing pipeline with DSP pitch-shift filters and preset selection.

### Modified Capabilities

## Impact

- **Android Native Layer**: `MainActivity.kt` and Android channel handlers for notification policy, Wi-Fi low-latency lock, and microphone capture permissions.
- **Domain & State**: `GameTurboSettings`, `GameTurboSettingsNotifier`, `CoachService`, and new dedicated services `WifiOptimizerService` and `VoiceChangerService`.
- **UI & Presentation**: `GameturboFloatingToolbox`, `TacticalBattlefieldHud`, and permission prompt dialogs.
- **Dependencies & Permissions**: `android.permission.ACCESS_NOTIFICATION_POLICY`, `android.permission.CHANGE_WIFI_STATE`, `android.permission.RECORD_AUDIO`.
