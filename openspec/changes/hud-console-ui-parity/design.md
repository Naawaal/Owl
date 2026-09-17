## Context

See `proposal.md` for motivation.

Today `GameSpaceConsoleScreen` owns the full Game Space layout (top bar, sidebar, cinematic hero, Play wing, GPU tab, Flutter toolbox). `TacticalBattlefieldHud` duplicates a partial top bar and a simplified hero card, plus a TURBO FPS pill handle positioned via `shortcutEdgePosition`. Opening tools is tap-based, not Xiaomi’s edge-slide pattern.

## Goals / Non-Goals

**Goals:**
- Single shared top status bar widget consumed by Console and HUD.
- HUD body layout composition matches Console 1:1 (Flutter only).
- Replace pill edge handle with a thin vertical rail + inward horizontal drag to open the toolbox.
- Keep HUD-only navigation (back to Console) and existing `autoOpenToolbox` / `matchElapsedSeconds` wiring.

**Non-Goals:**
- Native Kotlin `GameTurboOverlayService` edge-slide or layout changes.
- Telemetry / FPS measurement changes (covered by `hud-real-fps-parity`).
- Redesigning `GameturboFloatingToolbox` internals.

## Decisions

### 1. Shared top bar widget over copy-paste
- **Decision**: Extract `GameSpaceTopStatusBar` under `lib/features/game_profiles/presentation/widgets/` with callbacks (`onTurboPillTap`, `onLeadingAction`, `onSettingsTap`) and a `leadingIcon` parameter (`Icons.add` vs `Icons.chevron_left`).
- **Rationale**: Prevents chrome drift; Console and HUD stay visually locked.
- **Alternatives considered**: Duplicate builders in both screens — rejected (already caused divergence).

### 2. Port Console body into HUD (parity-first)
- **Decision**: Rewrite `TacticalBattlefieldHud` body to mirror Console’s `Scaffold` / `SafeArea` / `Column` / `Stack` structure and reuse or lightly extract sidebar / center stage / Play wing / GPU tab builders. Prefer shared widgets when extraction stays clean; otherwise port methods for parity first.
- **Rationale**: User required same UI/UX; structural match matters more than micro-refactor purity on first pass.
- **Alternatives considered**: Navigate HUD to Console itself — rejected (HUD needs session elapsed time and back navigation semantics).

### 3. Xiaomi vertical rail + slide threshold
- **Decision**: Replace `_buildEdgeHandle` with a ~3–4dp × ~48–56dp vertical capsule rail. `onHorizontalDragUpdate`/`End` with ~40–60dp inward displacement opens the toolbox. Rail side follows `shortcutEdgePosition` (`Left Edge` / `Top-Left` → left; `Top-Right` → right). Fade/hide rail while toolbox is open. Center pill still toggles toolbox.
- **Rationale**: Matches Xiaomi Game Turbo affordance without a bulky FPS pill competing with Console chrome.
- **Alternatives considered**: Keep FPS pill handle — rejected by product direction; edge-only swipe with no visible rail — rejected (hard to discover).

### 4. Toolbox anchor near active edge
- **Decision**: Left rail → `top: 48, left: 28` (Console parity); right rail → mirrored `top/right`. Animation timings match Console (`240ms`, slide offset `-0.06`).
- **Rationale**: Toolbox appears from the gesture origin like OEM Game Turbo.

## Risks / Trade-offs

- **[Risk] Drag conflicts with hero horizontal swipe** → **Mitigation**: Limit rail hit target to a narrow edge strip (~24dp) so center-stage game swipes remain unaffected.
- **[Risk] Layout duplication if Console widgets are not extracted** → **Mitigation**: Extract top bar first (highest drift risk); extract body sections in a follow-up if file size grows.
- **[Risk] Native overlay still uses old pill handle** → **Mitigation**: Explicitly out of scope; document as follow-up change.

## Migration Plan

- No data migration. Settings keys `inGameShortcuts` and `shortcutEdgePosition` reused as-is.
- Rollback: revert Flutter HUD/Console widget changes; no native or persistence impact.
