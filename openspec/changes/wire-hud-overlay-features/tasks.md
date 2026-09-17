## 1. Native Android Platform Hooks & Permissions

- [x] 1.1 Declare notification policy, Wi-Fi lock, and microphone permissions in `android/app/src/main/AndroidManifest.xml`
- [x] 1.2 Implement `com.example.owl/system_controls` MethodChannel in `MainActivity.kt` for DND ZenMode and Wi-Fi low-latency lock management
- [x] 1.3 Implement `com.example.owl/voice_changer` MethodChannel in `MainActivity.kt` for real-time microphone capture and DSP pitch-shifting

## 2. Core Domain Services & Heuristic Engine

- [x] 2.1 Implement `DndService` and Riverpod provider with permission inspection and recovery flows
- [x] 2.2 Implement `WifiOptimizerService` and Riverpod provider with `WifiLock` integration and live ping monitoring
- [x] 2.3 Create `OfflineTacticalHeuristicsEngine` with game-specific rules for active titles (Mobile Legends, Free Fire, PUBG)
- [x] 2.4 Update `CoachService` to seamlessly fall back to offline heuristics when no cloud API key is configured
- [x] 2.5 Implement `VoiceChangerService` and Riverpod provider supporting Commander, Cybernetic, Tactical Radio, and Studio presets

## 3. Overlay HUD Interactive Wiring

- [x] 3.1 Wire DND action button in `GameturboFloatingToolbox` to `DndService` with haptic feedback and permission prompt
- [x] 3.2 Wire Wi-Fi action button in `GameturboFloatingToolbox` to `WifiOptimizerService` with active telemetry indicator
- [x] 3.3 Wire AI action button in `GameturboFloatingToolbox` to trigger instant advice refresh and show the tactical advice card
- [x] 3.4 Wire Voice action button in `GameturboFloatingToolbox` to toggle audio modulation on tap and open preset selector on long-press
- [x] 3.5 Synchronize action button states with `GameTurboSettings` and `TacticalBattlefieldHud`

## 4. Verification & Testing

- [x] 4.1 Create test suite `test/features/overlay_actions_wiring_test.dart` validating all 4 tools and fallback behavior
- [x] 4.2 Verify existing tests pass across the entire test suite
