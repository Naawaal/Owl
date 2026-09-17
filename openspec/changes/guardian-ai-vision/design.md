## Context

Guardian AI in Owl provides floating HUD tactical advice over running games (Mobile Legends, Pokémon UNITE, etc.). See `proposal.md` for motivation. Currently, the Android overlay service (`GameTurboOverlayService.kt`) only detects the foreground package name and system telemetry (FPS, CPU/GPU load, RAM), lacking visual perception of the game screen. This causes frequent tactical discrepancies (e.g. assuming the player is a jungler with Retribution when they are an EXP laner with Flicker).

This design introduces a hardware-accelerated screen capture pipeline and multimodal vision processing loop using Gemini API (`gemini-3-flash-preview` / `gemini-2.5-flash`) to allow Guardian AI to visually see and analyze live gameplay.

## Goals / Non-Goals

**Goals:**
- **On-Demand Frame Capture**: Capture the active gameplay display buffer within 100ms on manual HUD card tap or 35-second tactical intervals.
- **Multimodal Visual Inference**: Pass downscaled JPEG frames (640x360, ~30-40KB) as `inlineData` to Gemini Multimodal Vision API to extract hero, active battle spell, lane status, game clock, and minimap threats.
- **Zero Hallucination Directives**: Produce actionable tactical directives strictly aligned with the visual reality of the match.
- **Battery & Memory Optimization**: Maintain memory footprint under 15MB overhead and battery impact under 3% by capturing only single transient frames on demand, recycling Bitmaps immediately.
- **Privacy & User Control**: Require explicit Android `MediaProjection` consent and provide a dedicated "Guardian Vision" toggle in Owl settings.

**Non-Goals:**
- Continuous video streaming or 60fps real-time screen recording.
- Local on-device vision model weights (e.g. MediaPipe or TensorFlow Lite model bundling) due to memory constraints on mobile gaming devices.
- Game memory scraping, memory injection, or unauthorized game client modifications.

## Decisions

### 1. Ephemeral MediaProjection with ImageReader vs. Continuous VirtualDisplay
- **Choice**: Ephemeral/On-demand capture via a single-buffer `ImageReader` initialized with `MediaProjection`.
- **Rationale**: Games demand 100% of GPU and memory bandwidth. Continuously maintaining an active 60fps `VirtualDisplay` causes frame drops in competitive games. Releasing or pausing the projection buffer between inferences avoids thermal throttling.
- **Alternative Considered**: Continuous screen streaming via SurfaceTexture. Rejected due to high battery drain (>15%) and thermal heating.

### 2. Downscaled 640x360 JPEG Inline Payload vs. High-Res PNG Upload
- **Choice**: Downscale the captured frame to 640x360 landscape JPEG at 75% quality (~30KB), encoded as base64 `inlineData` directly in the Gemini request JSON.
- **Rationale**: 640x360 is more than sufficient for Gemini 3 Flash to read hero health bars, skill icons, battle spells (Flicker vs Retribution), and minimap dots, while keeping network upload latency under 200ms on 4G/5G connections.
- **Alternative Considered**: Uploading full-resolution 1080p images via File API. Rejected due to multi-step network overhead (upload then inference) adding 2-4s latency.

### 3. Gemini 3 Flash / 2.5 Flash Multimodal Pipeline with Structured JSON
- **Choice**: Target `gemini-3-flash-preview` with automatic fallback to `gemini-2.5-flash`, specifying `"responseMimeType": "application/json"`.
- **Rationale**: `gemini-3-flash-preview` has verified availability, rapid multimodal response times (<1.2s), and strict adherence to JSON schema output (`action`, `rationale`, `radar`).
- **Alternative Considered**: Text-only LLM prompted with OCR strings. Rejected because game HUDs have visual icons, health bars, and minimaps that OCR cannot interpret.

### 4. Privacy Consent Flow via Flutter-to-Native MethodChannel
- **Choice**: Launch the system `MediaProjectionManager.createScreenCaptureIntent()` from Flutter or Native Overlay, pass the resulting `Intent` data token to `GameTurboOverlayService`, and persist authorization state in `SharedPreferences`.
- **Rationale**: Android 14 (API 34) enforces strict foreground service types (`FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION`) and requires explicit user consent before any frame capture.
- **Alternative Considered**: AccessibilityService screenshot API (`takeScreenshot`). Rejected because it requires full accessibility permissions, exhibits high latency (>800ms), and is restricted on some Android skins (HyperOS/MIUI).

## Risks / Trade-offs

- **[Risk] HyperOS / Android 14 MediaProjection Termination**: Android 14 terminates `MediaProjection` if the foreground service is not properly typed or if the screen is captured outside the authorized session.
  - *Mitigation*: Declare `android:foregroundServiceType="mediaProjection"` in `AndroidManifest.xml` and re-request projection token if invalidated.
- **[Risk] Gemini Daily Quota Exhaustion (429 Rate Limit)**: Free tier keys may hit quota limits during extended gaming sessions.
  - *Mitigation*: Implement exponential backoff, auto-switch to `gemini-3-flash-preview`, and gracefully fall back to context-aware static heuristics without throwing errors or breaking overlay HUD.
- **[Risk] High Network Latency in Matches**: If mobile latency is poor, LLM response might lag behind the fast-paced game.
  - *Mitigation*: Cap HTTP client timeout to 3500ms; if timed out, immediately display previous directive or fallback lane tip so player HUD never hangs.
- **[Risk] Memory Leaks from Unclosed Images**: `ImageReader.acquireLatestImage()` can leak native graphic buffers if not explicitly closed.
  - *Mitigation*: Wrap all `Image` access in `use { image -> ... }` blocks and immediately call `bitmap.recycle()` after JPEG compression.

## Migration Plan

1. Add `FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION` to `AndroidManifest.xml`.
2. Add MethodChannel handlers `startVisionCapture` and `stopVisionCapture` in `MainActivity.kt` and `GameTurboOverlayService.kt`.
3. Add `guardianVisionEnabled` boolean in Flutter `SettingsService` and tactical toggle in UI.
4. Update `AICoachService` and native inference client to construct multimodal JSON payloads when image bytes are present.
5. All changes are backward compatible: if permission is not granted or vision is toggled off, Guardian AI operates in classic telemetry mode.
