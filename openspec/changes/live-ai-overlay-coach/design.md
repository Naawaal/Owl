# Design: Live AI Overlay Coach

## Context

See [proposal.md](proposal.md) for background. When a user launches a game from Owl, the Flutter Activity transitions to `onPause`/`onStop` while `GameTurboOverlayService` remains active in the foreground via Android's `WindowManager`. The service manages both the gaming toolbox and the standalone Guardian AI HUD card.

## Goals / Non-Goals

**Goals:**
- Enable the standalone Guardian AI HUD overlay to fetch live tactical advice from Google Gemini (`gemini-2.0-flash` or user-selected model) while floating over active games.
- Execute network requests entirely off the main thread using an asynchronous worker pool to guarantee 0% frame stutter in running games.
- Maintain instant fallback to local heuristic directives when offline or without an API key.
- Provide a clear in-overlay visual cue when an inference request is in-flight.

**Non-Goals:**
- Spawning a secondary headless Flutter Engine in the background (prohibitive memory overhead for mobile gaming).
- Real-time video frame streaming to multimodal vision models (text situational prompts only).

## Decisions

### Decision 1: Lightweight Native `HttpURLConnection` vs Background Flutter Engine
- **Choice**: Implement a native Kotlin Gemini REST client in `GameTurboOverlayService.kt` using standard `java.net.HttpURLConnection` and `org.json.JSONObject`.
- **Rationale**: An in-memory Flutter background engine consumes 40-70 MB of RAM, competing directly with high-performance games. Native `HttpURLConnection` requires 0 MB extra dependencies and < 1 MB memory.
- **Alternatives Considered**: Headless Flutter Engine (too heavy), OkHttp dependency (unnecessary binary footprint for one REST endpoint).

### Decision 2: Credential Passing via Launch Intent and MethodChannel
- **Choice**: Forward `aiApiKey`, `aiProvider`, and `aiModel` as extras in `GameTurboOverlayService.start()` when `launchGame` is invoked, and expose `setAiCredentials` on the `com.example.owl/system_controls` MethodChannel for live changes.
- **Rationale**: Keeps credentials safely in process memory without creating duplicate plaintext preference stores.

### Decision 3: Fallback-First Cache Strategy
- **Choice**: Initialize the floating card with the game-specific heuristic directive immediately so the HUD is never blank. When the user taps the card or refresh button, initiate the async cloud request. If it succeeds, replace the card content; if it fails, cycle to the next heuristic directive without disrupting the user.

## Risks / Trade-offs

- **[Network latency over mobile data during online gaming]** → 8-second timeout limit; immediately falls back to local heuristics if response is delayed, keeping ping intact.
- **[Zero-credential first run]** → Detects empty/missing API key instantly and runs heuristic mode without attempting network requests.
