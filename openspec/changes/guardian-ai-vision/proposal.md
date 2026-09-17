## Why

Guardian AI currently relies on static game title strings, foreground package heuristics, and text-only prompts to provide tactical guidance. Because the AI cannot see the user's live screen, it frequently generates misaligned directives (e.g. recommending "Hold Retribution for Turtle smite" when the player is an EXP laner carrying Flicker, or misjudging power spikes and lane states). Giving Guardian AI visual perception enables zero-hallucination, context-aware tactical coaching: the multimodal vision model inspects the real-time screen, instantly identifies the active hero/champion, battle spell, game clock, minimap threats, and objective status, and delivers precise in-game coaching.

## What Changes

- **Android Screen Capture Engine**: Integrate on-demand hardware frame capture using Android `MediaProjection` API and downscaled JPEG buffer compression for tactical analysis.
- **Multimodal Gemini Vision Pipeline**: Upgrade Guardian AI inference in `GameTurboOverlayService.kt` and Flutter `AICoachService` to send base64 JPEG screen frames via Gemini Multimodal Vision API (`gemini-3-flash-preview` / `gemini-2.5-flash` with `inlineData`).
- **Vision Tactical Prompt Engineering**: Construct multimodal visual prompts instructing Gemini to extract hero identity, battle spell cooldowns, minimap enemy positions, and match timeline before generating the tactical action, rationale, and radar alert.
- **Overlay Vision Trigger & Auto-Capture**: Add auto-capture interval (35s) and manual HUD tap-to-analyze trigger on the Guardian AI card that captures the live game surface and pushes instant visual directives.
- **Privacy & Permission Flow**: Provide standard Android MediaProjection consent handling and user settings toggle (`guardianVisionEnabled`).

## Capabilities

### New Capabilities
- `guardian-ai-vision`: Hardware frame capture and multimodal vision inference delivering live visual game context awareness (hero, spell, minimap, timeline) to Guardian AI.

### Modified Capabilities
- `overlay-ai-tactical-engine`: Upgrade directive generation from text-only heuristics to multimodal screen-aware analysis when vision is active.

## Impact

- **Android Native**: `GameTurboOverlayService.kt` gains `MediaProjection` capture / `ImageReader` virtual display pipeline, base64 frame encoding, and multimodal Gemini JSON request builder.
- **Flutter UI & Settings**: Adds "Guardian Vision" permission consent dialog and toggle in `AppSettingsTwoPaneScreen` under AI Assistant settings.
- **API Payload**: Transmits compressed (~640x360 80% JPEG, ~30KB) image frames to Gemini API, keeping latency under 1200ms and avoiding quota saturation.
