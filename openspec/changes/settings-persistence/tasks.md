## 1. Theme unification

- [x] 1.1 Route the App Settings theme selector through `themeModeProvider` instead of the settings blob
- [x] 1.2 Remove the orphaned `themeMode` field from `GameTurboSettings` (model, `copyWith`, serialization, equality) and update affected test assertions
- [x] 1.3 Verify app boot, settings screen, and showcase all resolve one theme with one default

## 2. Boot re-apply without construction side effects

- [x] 2.1 Remove the native channel call from the settings notifier constructor
- [x] 2.2 Add an explicit async hardware re-apply step invoked once after widget binding initialization with platform guards
- [x] 2.3 Confirm the 3 failing persistence tests pass with no native-channel leakage

## 3. Visible errors and versioned schema

- [x] 3.1 Return typed persist results from the settings notifier and surface write failures in the settings UI
- [x] 3.2 Add a versioned settings envelope with forward migration for unknown and corrupt payloads
- [x] 3.3 Migrate the existing unversioned `v2` payload once, preserving current user settings

## 4. Round-trip verification

- [x] 4.1 Add restart round-trip tests for theme, provider/model selection, toggles, performance profile, GPU settings, game deck, and API keys
- [x] 4.2 Run `flutter analyze` and fix all reported issues
- [x] 4.3 Run the full `flutter test` suite green plus a manual cold-restart pass per settings category on Android
- [x] 4.4 Run `openspec validate --change settings-persistence` and resolve any findings
