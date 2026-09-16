import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owl_design/owl_design.dart';
import 'package:owl_storage/owl_storage.dart';

/// Interactive Design System & Tactical HUD Showcase for Owl.
/// Allows live testing and inspection of every design token, typography specimen,
/// button variant, timer state, glass card, input field, and floating HUD overlay.
class DesignSystemShowcaseView extends ConsumerStatefulWidget {
  const DesignSystemShowcaseView({super.key});

  @override
  ConsumerState<DesignSystemShowcaseView> createState() =>
      _DesignSystemShowcaseViewState();
}

class _DesignSystemShowcaseViewState
    extends ConsumerState<DesignSystemShowcaseView> {
  // Cooldown Ring Test State
  double _cooldownProgress = 0.68;

  // Countdown & Timer State
  int _timerSeconds = 42;
  bool _isTimerRunning = true;
  Timer? _ticker;

  // Button Loading Demo State
  bool _isButtonLoading = false;

  // Text Field Controllers
  late final TextEditingController _apiKeyController;
  late final TextEditingController _championController;

  // Tactical Pill Drag Position inside preview
  Offset _pillPosition = const Offset(20, 24);
  bool _pillExpanded = false;

  // Last Ping Selected
  String _lastPingStatus = 'NO PINGS SENT';

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(
      text: 'AIzaSyA4Q9x8Z1wLk_OwlTacticalCoachKey_DEMO',
    );
    _championController = TextEditingController(text: 'Lee Sin (Jungle)');

    _startTimer();
  }

  void _startTimer() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isTimerRunning) return;
      setState(() {
        if (_timerSeconds > 0) {
          _timerSeconds--;
        } else {
          _timerSeconds = 60; // loop back
        }
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _apiKeyController.dispose();
    _championController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top App Bar / Status Banner with Theme Selector
            SliverToBoxAdapter(
              child: _buildShowcaseHeader(context, currentThemeMode),
            ),

            // Main Content Sections
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.screenPadding,
                vertical: SpacingTokens.md,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 1. Live Tactical HUD Capsule Showcase
                  _buildSectionHeader(
                    'TACTICAL HUD PILL',
                    'Floating draggable overlay capsule with live urgency pulse & telemetry drawer.',
                    context,
                  ),
                  _buildTacticalPillInteractivePreview(context),
                  const SizedBox(height: SpacingTokens.xl),

                  // 2. Cooldown Rings & Timers Showcase
                  _buildSectionHeader(
                    'COOLDOWN GAUGE & TIMER BADGES',
                    'Monospaced tabular digits (<30s warning, <10s urgent heartbeat).',
                    context,
                  ),
                  _buildTimersAndCooldownPreview(context),
                  const SizedBox(height: SpacingTokens.xl),

                  // 3. Tactical Action Sheet & Fast Match Pings
                  _buildSectionHeader(
                    'TACTICAL ACTION SHEET',
                    'Full glass slide-up drawer for lightning-fast MOBA match pings.',
                    context,
                  ),
                  _buildActionSheetPreview(context),
                  const SizedBox(height: SpacingTokens.xl),

                  // 4. Bespoke Input Fields
                  _buildSectionHeader(
                    'INPUTS: OWL TEXT FIELD',
                    'OLED fill, glowing cyan focus bloom, API key obscurity mask & clear trigger.',
                    context,
                  ),
                  _buildInputsPreview(context),
                  const SizedBox(height: SpacingTokens.xl),

                  // 5. Button Matrix
                  _buildSectionHeader(
                    'BUTTON MATRIX',
                    'Emil Kowalski 160ms scale(0.97) micro-interactions, haptics & custom spinner.',
                    context,
                  ),
                  _buildButtonsPreview(context),
                  const SizedBox(height: SpacingTokens.xl),

                  // 6. Glassmorphic Cards & Telemetry
                  _buildSectionHeader(
                    'GLASS CARDS & METRIC CONTAINERS',
                    'Real-time backdrop blur (sigma 10) and subtle gradient border sheen.',
                    context,
                  ),
                  _buildGlassCardsPreview(context),
                  const SizedBox(height: SpacingTokens.xl),

                  // 7. Color Matrix (3-Tier Tokens)
                  _buildSectionHeader(
                    'COLOR MATRIX',
                    'OLED blacks, deep slates, neon cyber accents, and alert levels.',
                    context,
                  ),
                  _buildColorSwatchesPreview(context),
                  const SizedBox(height: SpacingTokens.xl),

                  // 8. Typography Hierarchy
                  _buildSectionHeader(
                    'TYPOGRAPHY SPECIMENS',
                    'Outfit-only hierarchy: interface, tactical, console & gauge roles.',
                    context,
                  ),
                  _buildTypographyPreview(context),
                  const SizedBox(height: SpacingTokens.xl),

                  // 9. Console & Cinematic Roles (Prototype Canonical)
                  _buildSectionHeader(
                    'CONSOLE & CINEMATIC ROLES',
                    'Game Space Console, settings, toolbox, gauge & telemetry roles.',
                    context,
                  ),
                  _buildConsoleRolesPreview(context),
                  const SizedBox(height: SpacingTokens.xxl),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SECTION BUILDERS
  // ===========================================================================

  Widget _buildShowcaseHeader(BuildContext context, ThemeMode activeThemeMode) {
    final colors = ColorTokens.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.screenPadding,
        vertical: SpacingTokens.md,
      ),
      decoration: BoxDecoration(
        color: isDark ? ColorPrimitives.glassDeepSlate85 : const Color(0xF8FFFFFF),
        border: Border(
          bottom: BorderSide(color: colors.borderGlass, width: 1.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Tactical Logo Hex
                  Container(
                    width: 36.0,
                    height: 36.0,
                    decoration: BoxDecoration(
                      color: isDark ? ColorPrimitives.glassCyan15 : const Color(0xFFE0F2FE),
                      borderRadius: RadiusTokens.borderSm,
                      border: Border.all(color: colors.accentCyan, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: colors.accentCyan.withValues(alpha: isDark ? 0.35 : 0.2),
                          blurRadius: 10.0,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      size: 20.0,
                      color: colors.accentCyan,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'OWL',
                            style: GoogleFonts.outfit(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          Text(
                            'HUD SYSTEM',
                            style: GoogleFonts.outfit(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: colors.accentCyan,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'DESIGN SYSTEM & INTERACTIVE SHOWCASE',
                        style: TypographyTokens.tacticalBadge.copyWith(
                          color: colors.textMuted,
                          fontSize: 9.0,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Live Status Dot
              Row(
                children: [
                  const OwlStatusDot(
                    role: OwlStatusDotRole.synced,
                    coreSize: 7.0,
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  Text(
                    'SYSTEM ONLINE',
                    style: GoogleFonts.outfit(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: colors.alertSuccess,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm + 2),
          // Theme Switcher Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            decoration: BoxDecoration(
              color: isDark ? ColorPrimitives.glassOled85 : const Color(0xFFF1F5F9),
              borderRadius: RadiusTokens.borderPill,
              border: Border.all(color: colors.borderGlass, width: 1.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.palette_outlined,
                      size: 15.0,
                      color: colors.accentCyan,
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      'THEME MODE',
                      style: GoogleFonts.outfit(
                        fontSize: 10.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                _buildThemeSelector(activeThemeMode, colors, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector(
    ThemeMode currentMode,
    OwlColors colors,
    bool isDark,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _themeTabItem(
          mode: ThemeMode.system,
          label: 'SYSTEM',
          icon: Icons.brightness_auto_rounded,
          isActive: currentMode == ThemeMode.system,
          colors: colors,
          isDark: isDark,
        ),
        const SizedBox(width: 4.0),
        _themeTabItem(
          mode: ThemeMode.light,
          label: 'LIGHT',
          icon: Icons.light_mode_rounded,
          isActive: currentMode == ThemeMode.light,
          colors: colors,
          isDark: isDark,
        ),
        const SizedBox(width: 4.0),
        _themeTabItem(
          mode: ThemeMode.dark,
          label: 'DARK',
          icon: Icons.dark_mode_rounded,
          isActive: currentMode == ThemeMode.dark,
          colors: colors,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _themeTabItem({
    required ThemeMode mode,
    required String label,
    required IconData icon,
    required bool isActive,
    required OwlColors colors,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(themeModeProvider.notifier).setThemeMode(mode);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.5),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? ColorPrimitives.glassCyan25 : const Color(0xFFE0F2FE))
              : Colors.transparent,
          borderRadius: RadiusTokens.borderPill,
          border: Border.all(
            color: isActive ? colors.accentCyan : Colors.transparent,
            width: 1.0,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: colors.accentCyan.withValues(alpha: isDark ? 0.25 : 0.15),
                    blurRadius: 6.0,
                    spreadRadius: 0.0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12.0,
              color: isActive ? colors.accentCyan : colors.textMuted,
            ),
            const SizedBox(width: 3.5),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 9.0,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: 0.5,
                color: isActive ? colors.accentCyan : colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, BuildContext context) {
    final colors = ColorTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3.0,
                height: 14.0,
                decoration: BoxDecoration(
                  color: colors.accentCyan,
                  borderRadius: RadiusTokens.borderXs,
                ),
              ),
              const SizedBox(width: SpacingTokens.xs),
              Text(
                title,
                style: TypographyTokens.tacticalLabel.copyWith(
                  fontSize: 13.0,
                  color: colors.textPrimary,
                  letterSpacing: 1.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3.0),
          Padding(
            padding: const EdgeInsets.only(left: SpacingTokens.sm - 1),
            child: Text(
              subtitle,
              style: TypographyTokens.bodySmall.copyWith(
                color: colors.textMuted,
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. TACTICAL PILL PREVIEW
  // ---------------------------------------------------------------------------
  Widget _buildTacticalPillInteractivePreview(BuildContext context) {
    final colors = ColorTokens.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return OwlGlassCard(
      variant: OwlGlassVariant.dense,
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SIMULATED GAME SCREEN OVERLAY',
                style: TypographyTokens.tacticalBadge.copyWith(
                  color: colors.textSecondary,
                  fontSize: 9.5,
                ),
              ),
              Row(
                children: [
                  OwlButton(
                    label: _pillExpanded ? 'COLLAPSE' : 'EXPAND',
                    size: OwlButtonSize.sm,
                    variant: OwlButtonVariant.ghost,
                    onPressed: () {
                      setState(() {
                        _pillExpanded = !_pillExpanded;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            'Drag the HUD pill inside this sandbox. Tap pill to trigger real-time tactical drawer.',
            style: TypographyTokens.bodySmall.copyWith(
              color: colors.textMuted,
              fontSize: 11.0,
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),

          // Draggable Sandbox Arena
          Container(
            height: 180.0,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: isDark ? ColorPrimitives.oledBlack : const Color(0xFF0F172A),
              borderRadius: RadiusTokens.card,
              border: Border.all(
                color: colors.borderGlass,
                width: 1.0,
              ),
              gradient: RadialGradient(
                center: const Alignment(0.0, -0.2),
                radius: 1.2,
                colors: isDark
                    ? const [
                        Color(0xFF141A24),
                        ColorPrimitives.oledBlack,
                      ]
                    : const [
                        Color(0xFF1E293B),
                        Color(0xFF0F172A),
                      ],
              ),
            ),
            child: Stack(
              children: [
                // Crosshairs / Grid overlay in background
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GridCrosshairPainter(),
                  ),
                ),

                // Floating Tactical Pill
                Positioned(
                  left: _pillPosition.dx,
                  top: _pillPosition.dy,
                  child: OwlTacticalPill(
                    objectiveName: 'DRAGON',
                    countdownSeconds: _timerSeconds,
                    objectiveIcon: Icons.local_fire_department_rounded,
                    aiStatus: _timerSeconds <= 10
                        ? OwlAiStatus.warning
                        : OwlAiStatus.online,
                    isExpanded: _pillExpanded,
                    onExpandToggle: (val) {
                      setState(() => _pillExpanded = val);
                    },
                    onPositionChanged: (newPos) {
                      setState(() => _pillPosition = newPos);
                    },
                    onQuickAction: (action) {
                      setState(() {
                        _lastPingStatus = 'QUICK ACTION: $action';
                      });
                      HapticFeedback.heavyImpact();
                    },
                    isDraggable: true,
                  ),
                ),

                // Corner tag
                Positioned(
                  bottom: 8,
                  right: 12,
                  child: Text(
                    'FPS: 60 • PING: 18ms',
                    style: GoogleFonts.outfit(
                      fontSize: 9.0,
                      fontWeight: FontWeight.w600,
                      color: colors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. COOLDOWNS & TIMERS PREVIEW
  // ---------------------------------------------------------------------------
  Widget _buildTimersAndCooldownPreview(BuildContext context) {
    final colors = ColorTokens.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return OwlGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row of Timer Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LIVE TICKING OBJECTIVES',
                style: TypographyTokens.tacticalBadge.copyWith(
                  color: colors.textSecondary,
                  fontSize: 10.0,
                ),
              ),
              Row(
                children: [
                  OwlButton(
                    label: _isTimerRunning ? 'PAUSE' : 'PLAY',
                    size: OwlButtonSize.sm,
                    variant: _isTimerRunning
                        ? OwlButtonVariant.secondary
                        : OwlButtonVariant.primary,
                    leadingIcon: Icon(
                      _isTimerRunning
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 14.0,
                    ),
                    onPressed: () {
                      setState(() => _isTimerRunning = !_isTimerRunning);
                    },
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  OwlButton(
                    label: 'RESET',
                    size: OwlButtonSize.sm,
                    variant: OwlButtonVariant.ghost,
                    onPressed: () {
                      setState(() => _timerSeconds = 45);
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),

          // Dynamic Timer Badges Row
          Wrap(
            spacing: SpacingTokens.sm,
            runSpacing: SpacingTokens.sm,
            children: [
              OwlTimerBadge(
                label: 'DRAGON',
                remainingSeconds: _timerSeconds,
                size: OwlTimerBadgeSize.md,
                icon: const Icon(Icons.local_fire_department_rounded, size: 14),
              ),
              OwlTimerBadge(
                label: 'BARON',
                remainingSeconds: (_timerSeconds - 20).clamp(0, 300),
                size: OwlTimerBadgeSize.md,
                icon: const Icon(Icons.shield_rounded, size: 14),
              ),
              OwlTimerBadge(
                label: 'FLASH',
                remainingSeconds: (_timerSeconds - 35).clamp(0, 300),
                size: OwlTimerBadgeSize.md,
                icon: const Icon(Icons.flash_on_rounded, size: 14),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.lg),

          Divider(color: colors.borderGlass, height: 1.0),
          const SizedBox(height: SpacingTokens.md),

          // Cooldown Ring Interactive Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'COOLDOWN GAUGE ARC',
                style: TypographyTokens.tacticalBadge.copyWith(
                  color: colors.textSecondary,
                  fontSize: 10.0,
                ),
              ),
              Text(
                '${(_cooldownProgress * 100).toInt()}% READY',
                style: GoogleFonts.outfit(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w700,
                  color: colors.accentCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),

          Row(
            children: [
              // Cooldown Ring Preview 1 (Cyan)
              OwlCooldownRing(
                progress: _cooldownProgress,
                size: 54.0,
                strokeWidth: 4.0,
                centerText: '${(_cooldownProgress * 10).toInt()}s',
              ),
              const SizedBox(width: SpacingTokens.md),

              // Cooldown Ring Preview 2 (Purple)
              OwlCooldownRing(
                progress: 1.0 - _cooldownProgress,
                size: 54.0,
                strokeWidth: 4.0,
                activeColor: colors.accentPurple,
                centerText: '${((1.0 - _cooldownProgress) * 10).toInt()}s',
              ),
              const SizedBox(width: SpacingTokens.md),

              // Cooldown Ring Preview 3 (Danger)
              OwlCooldownRing(
                progress: _cooldownProgress * 0.5,
                size: 54.0,
                strokeWidth: 4.0,
                activeColor: colors.alertDanger,
                child: Icon(
                  Icons.local_fire_department_rounded,
                  size: 18.0,
                  color: colors.alertDanger,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.xs),

          // Slider to adjust gauge
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: colors.accentCyan,
              inactiveTrackColor: isDark
                  ? ColorPrimitives.glassElevated85
                  : const Color(0xFFE2E8F0),
              thumbColor: colors.accentCyan,
              overlayColor: colors.accentCyan.withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
              trackHeight: 3.0,
            ),
            child: Slider(
              value: _cooldownProgress,
              onChanged: (val) {
                setState(() => _cooldownProgress = val);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. ACTION SHEET PREVIEW
  // ---------------------------------------------------------------------------
  Widget _buildActionSheetPreview(BuildContext context) {
    final colors = ColorTokens.of(context);

    return OwlGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STATUS: $_lastPingStatus',
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: colors.accentCyan,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      'Tap button below to launch full tactical match ping drawer.',
                      style: TypographyTokens.bodySmall.copyWith(
                        color: colors.textMuted,
                        fontSize: 11.0,
                      ),
                    ),
                  ],
                ),
              ),
              OwlButton(
                label: 'OPEN ACTION SHEET',
                size: OwlButtonSize.sm,
                variant: OwlButtonVariant.primary,
                leadingIcon: const Icon(Icons.flash_on_rounded, size: 14.0),
                onPressed: () async {
                  final result = await OwlActionSheet.show(context);
                  if (result != null) {
                    setState(() {
                      _lastPingStatus = 'SENT: ${result.title}';
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. INPUTS PREVIEW
  // ---------------------------------------------------------------------------
  Widget _buildInputsPreview(BuildContext context) {
    return OwlGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Monospaced API Key Field
          OwlTextField(
            controller: _apiKeyController,
            labelText: 'BYOK: AI COACH API KEY',
            hintText: 'Enter Google Gemini or OpenAI API Key...',
            prefixIcon: const Icon(Icons.key_rounded),
            isPassword: true,
            isMonospace: true,
            helperText: 'Hardware-backed encryption via Android Keystore.',
          ),
          const SizedBox(height: SpacingTokens.md),

          // Standard Text Field
          OwlTextField(
            controller: _championController,
            labelText: 'ACTIVE CHAMPION / ROLE',
            hintText: 'e.g. Aatrox (Solo Lane)',
            prefixIcon: const Icon(Icons.person_outline_rounded),
            helperText: 'Used to provide champion-tailored lane rotations.',
          ),
          const SizedBox(height: SpacingTokens.md),

          // Error State Field Preview
          const OwlTextField(
            initialValue: 'sk-invalid_expired_token_hash_0918',
            labelText: 'VALIDATION ERROR STATE',
            prefixIcon: Icon(Icons.warning_amber_rounded),
            isMonospace: true,
            errorText: 'API authentication failed: 401 Unauthorized.',
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. BUTTONS PREVIEW
  // ---------------------------------------------------------------------------
  Widget _buildButtonsPreview(BuildContext context) {
    final colors = ColorTokens.of(context);

    return OwlGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'VARIANTS (SM / MD / LG)',
                style: TypographyTokens.tacticalBadge.copyWith(
                  color: colors.textSecondary,
                  fontSize: 10.0,
                ),
              ),
              OwlButton(
                label: _isButtonLoading ? 'STOP LOADING' : 'SIMULATE LOADING',
                size: OwlButtonSize.sm,
                variant: OwlButtonVariant.ghost,
                onPressed: () {
                  setState(() => _isButtonLoading = !_isButtonLoading);
                },
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),

          // Primary, Secondary, Danger, Ghost
          Wrap(
            spacing: SpacingTokens.sm,
            runSpacing: SpacingTokens.sm,
            children: [
              OwlButton(
                label: 'PRIMARY GLOW',
                variant: OwlButtonVariant.primary,
                size: OwlButtonSize.md,
                isLoading: _isButtonLoading,
                leadingIcon: const Icon(Icons.bolt_rounded),
                onPressed: () {},
              ),
              OwlButton(
                label: 'SECONDARY',
                variant: OwlButtonVariant.secondary,
                size: OwlButtonSize.md,
                leadingIcon: const Icon(Icons.settings_outlined),
                onPressed: () {},
              ),
              OwlButton(
                label: 'DANGER ALERT',
                variant: OwlButtonVariant.danger,
                size: OwlButtonSize.md,
                leadingIcon: const Icon(Icons.warning_rounded),
                onPressed: () {},
              ),
              OwlButton(
                label: 'GHOST SHEEN',
                variant: OwlButtonVariant.ghost,
                size: OwlButtonSize.md,
                onPressed: () {},
              ),
              const OwlButton(
                label: 'DISABLED',
                variant: OwlButtonVariant.primary,
                size: OwlButtonSize.md,
                onPressed: null,
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.lg),

          Divider(color: colors.borderGlass, height: 1.0),
          const SizedBox(height: SpacingTokens.md),

          // Icon Buttons Row
          Text(
            'TACTICAL ICON BUTTONS',
            style: TypographyTokens.tacticalBadge.copyWith(
              color: colors.textSecondary,
              fontSize: 10.0,
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),

          Row(
            children: [
              OwlIconButton(
                icon: const Icon(Icons.fullscreen_rounded),
                variant: OwlIconButtonVariant.primary,
                size: OwlIconButtonSize.md,
                isActive: true,
                onPressed: () {},
              ),
              const SizedBox(width: SpacingTokens.sm),
              OwlIconButton(
                icon: const Icon(Icons.mic_none_rounded),
                variant: OwlIconButtonVariant.secondary,
                size: OwlIconButtonSize.md,
                onPressed: () {},
              ),
              const SizedBox(width: SpacingTokens.sm),
              OwlIconButton(
                icon: const Icon(Icons.notifications_active_outlined),
                variant: OwlIconButtonVariant.ghost,
                size: OwlIconButtonSize.md,
                onPressed: () {},
              ),
              const SizedBox(width: SpacingTokens.sm),
              OwlIconButton(
                icon: const Icon(Icons.power_settings_new_rounded),
                variant: OwlIconButtonVariant.danger,
                size: OwlIconButtonSize.md,
                shape: OwlIconButtonShape.circle,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. GLASS CARDS & TELEMETRY
  // ---------------------------------------------------------------------------
  Widget _buildGlassCardsPreview(BuildContext context) {
    final colors = ColorTokens.of(context);

    return OwlGlassCard(
      isHighlighted: true,
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const OwlStatusDot(
                    role: OwlStatusDotRole.aiLive,
                    coreSize: 8.0,
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  Text(
                    'AI REAL-TIME COACH INSIGHT',
                    style: TypographyTokens.tacticalBadge.copyWith(
                      color: colors.accentPurple,
                      fontSize: 10.5,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const OwlBadge(
                label: 'LIVE REPLAY',
                variant: OwlBadgeVariant.purple,
                size: OwlBadgeSize.sm,
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),

          Text(
            '"Enemy Jungler spotted in Top river with blue buff. Solo laner is overextended. Ping retreat and contest Dragon pit now!"',
            style: TypographyTokens.bodyMedium.copyWith(
              color: colors.textPrimary,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          const SizedBox(height: SpacingTokens.md),

          // Tactical stats chips inside card
          Row(
            children: [
              _buildMetricPill('ROTATION ADVANTAGE', '+24%', colors.alertSuccess, context),
              const SizedBox(width: SpacingTokens.sm),
              _buildMetricPill('GOLD DEFICIT', '-1.2K', colors.alertWarning, context),
              const SizedBox(width: SpacingTokens.sm),
              _buildMetricPill('VISION SCORE', '86', colors.accentCyan, context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPill(
    String label,
    String value,
    Color accentColor,
    BuildContext context,
  ) {
    final colors = ColorTokens.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.xs,
          vertical: SpacingTokens.xs,
        ),
        decoration: BoxDecoration(
          color: isDark ? ColorPrimitives.glassElevated85 : const Color(0xFFF1F5F9),
          borderRadius: RadiusTokens.borderSm,
          border: Border.all(
            color: colors.borderGlass,
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TypographyTokens.tacticalBadge.copyWith(
                color: colors.textMuted,
                fontSize: 8.0,
                letterSpacing: 0.6,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2.0),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 13.0,
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 7. COLOR MATRIX PREVIEW
  // ---------------------------------------------------------------------------
  Widget _buildColorSwatchesPreview(BuildContext context) {
    final colors = ColorTokens.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return OwlGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: SpacingTokens.sm,
            runSpacing: SpacingTokens.sm,
            children: [
              _buildColorSwatch(
                isDark ? 'OLED Black' : 'Pure Slate 50',
                isDark ? '#08090C' : '#F8FAFC',
                colors.background,
                context,
              ),
              _buildColorSwatch(
                isDark ? 'Surface Card' : 'Surface Light',
                isDark ? '#11141A' : '#FFFFFF',
                colors.surfaceCard,
                context,
              ),
              _buildColorSwatch(
                isDark ? 'Elevated Dark' : 'Elevated Light',
                isDark ? '#181D26' : '#F1F5F9',
                colors.surfaceElevated,
                context,
              ),
              _buildColorSwatch(
                'Neon Cyan',
                isDark ? '#00F5D4' : '#0EA5E9',
                colors.accentCyan,
                context,
              ),
              _buildColorSwatch(
                'Electric Purple',
                isDark ? '#7928CA' : '#7C3AED',
                colors.accentPurple,
                context,
              ),
              _buildColorSwatch(
                'Amber Warning',
                isDark ? '#FFB703' : '#D97706',
                colors.alertWarning,
                context,
              ),
              _buildColorSwatch(
                'Crimson Danger',
                isDark ? '#FF453A' : '#E11D48',
                colors.alertDanger,
                context,
              ),
              _buildColorSwatch(
                'Emerald Success',
                isDark ? '#30D158' : '#059669',
                colors.alertSuccess,
                context,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorSwatch(
    String name,
    String hex,
    Color color,
    BuildContext context,
  ) {
    final colors = ColorTokens.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 155.0,
      padding: const EdgeInsets.all(SpacingTokens.xs + 2),
      decoration: BoxDecoration(
        color: isDark ? ColorPrimitives.glassElevated85 : const Color(0xFFF1F5F9),
        borderRadius: RadiusTokens.card,
        border: Border.all(color: colors.borderGlass, width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            width: 28.0,
            height: 28.0,
            decoration: BoxDecoration(
              color: color,
              borderRadius: RadiusTokens.borderXs,
              border: Border.all(
                color: isDark ? const Color(0x33F8FAFC) : const Color(0x330F172A),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: isDark ? 0.3 : 0.2),
                  blurRadius: 6.0,
                ),
              ],
            ),
          ),
          const SizedBox(width: SpacingTokens.xs + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.outfit(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  hex,
                  style: GoogleFonts.outfit(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w400,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 9. CONSOLE & CINEMATIC ROLES PREVIEW
  // ---------------------------------------------------------------------------
  Widget _buildConsoleRolesPreview(BuildContext context) {
    final colors = ColorTokens.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return OwlGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: SpacingTokens.sm,
            runSpacing: SpacingTokens.sm,
            children: [
              _buildColorSwatch('Console Base',
                  isDark ? '#07090F' : '#FFFFFF', colors.consoleBase, context),
              _buildColorSwatch('Horizon Top',
                  isDark ? '#090B12' : '#F8FAFC', colors.horizonTop, context),
              _buildColorSwatch('Horizon Bottom',
                  isDark ? '#06070B' : '#F1F5F9', colors.horizonBottom, context),
              _buildColorSwatch('Settings Base',
                  isDark ? '#080B10' : '#FFFFFF', colors.settingsBase, context),
              _buildColorSwatch('Settings Panel',
                  isDark ? '#0E131E' : '#F8FAFC', colors.settingsPanel, context),
              _buildColorSwatch('Settings Card',
                  isDark ? '70% #151C2A' : '#FFFFFF', colors.settingsCard, context),
              _buildColorSwatch('Console Muted',
                  isDark ? '#8E9BAE' : '#64748B', colors.consoleMuted, context),
              _buildColorSwatch('Console Dim',
                  isDark ? '#546173' : '#CBD5E1', colors.consoleDim, context),
              _buildColorSwatch('Turbo Cyan',
                  isDark ? '#00E5FF' : '#0E7490', colors.turboCyan, context),
              _buildColorSwatch('HUD Crimson',
                  isDark ? '#FF3B30' : '#DC2626', colors.hudCrimson, context),
              _buildColorSwatch('Alert Crimson',
                  isDark ? '#FF453A' : '#E11D48', colors.alertCrimson, context),
              _buildColorSwatch('Emerald Live',
                  isDark ? '#30D158' : '#059669', colors.emeraldLive, context),
              _buildColorSwatch('Tactical Amber',
                  isDark ? '#FF9F0A' : '#D97706', colors.tacticalAmber, context),
              _buildColorSwatch('Telemetry Critical',
                  isDark ? '#E63946' : '#E11D48', colors.telemetryCritical, context),
              _buildColorSwatch('Telemetry Low',
                  isDark ? '#EAB308' : '#D97706', colors.telemetryLow, context),
              _buildColorSwatch('Play Wing Start', '80% #0062EB',
                  colors.playWingStart, context),
              _buildColorSwatch('Play Wing End', '96% #0088FF',
                  colors.playWingEnd, context),
              _buildColorSwatch('GPU Tab Fill', '88% #121620',
                  colors.gpuTabFill, context),
              _buildColorSwatch('Gold Deep',
                  isDark ? '#FB8500' : '#B45309', colors.goldDeep, context),
              _buildColorSwatch('Gold Solid',
                  isDark ? '#FFD700' : '#D97706', colors.goldSolid, context),
              _buildColorSwatch('Badge Yellow',
                  isDark ? '#EAB308' : '#A16207', colors.badgeYellow, context),
              _buildColorSwatch('Console Purple',
                  isDark ? '#7C3AED' : '#7C3AED', colors.consolePurple, context),
              _buildColorSwatch('Purple Vivid',
                  isDark ? '#933AEA' : '#6D28D9', colors.consolePurpleVivid, context),
              _buildColorSwatch('Gamebox Start', '#4338CA',
                  colors.gameboxStart, context),
              _buildColorSwatch('Gamebox End', '#6366F1',
                  colors.gameboxEnd, context),
              _buildColorSwatch('Toolbox BG', '94% #0E121B',
                  colors.toolboxBg, context),
              _buildColorSwatch('Gauge Laser',
                  isDark ? '#FF5A5F' : '#E11D48', colors.gaugeLaser, context),
              _buildColorSwatch('Radar Border', '55% #007AFF',
                  colors.radarBorder, context),
              _buildColorSwatch('Dialog Scrim', '95% #101420',
                  colors.dialogBg, context),
              _buildColorSwatch('Key Input Text',
                  isDark ? '#00E5FF' : '#0E7490', colors.keyInputText, context),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 8. TYPOGRAPHY PREVIEW
  // ---------------------------------------------------------------------------
  Widget _buildTypographyPreview(BuildContext context) {
    final colors = ColorTokens.of(context);

    return OwlGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTypoItem(
            'displayTimer (28sp, Bold Outfit)',
            Text(
              '00:${_timerSeconds.toString().padLeft(2, '0')}',
              style: TypographyTokens.displayTimer.copyWith(
                color: colors.accentCyan,
              ),
            ),
            context,
          ),
          Divider(color: colors.borderGlass, height: 16.0),
          _buildTypoItem(
            'headline (20sp, Semi-Bold, -0.5px tracking)',
            Text(
              'Wild Rift: Baron Nashor Phase',
              style: TypographyTokens.headline.copyWith(
                color: colors.textPrimary,
              ),
            ),
            context,
          ),
          Divider(color: colors.borderGlass, height: 16.0),
          _buildTypoItem(
            'titleMedium (16sp, Medium)',
            Text(
              'Dragon Soul Contest Imminent',
              style: TypographyTokens.titleMedium.copyWith(
                color: colors.textPrimary,
              ),
            ),
            context,
          ),
          Divider(color: colors.borderGlass, height: 16.0),
          _buildTypoItem(
            'tacticalLabel (11sp, Bold, +1.2px tracking)',
            Text(
              'OBJECTIVE VULNERABLE • FLANK FROM RIVER',
              style: TypographyTokens.tacticalLabel.copyWith(
                color: colors.alertWarning,
              ),
            ),
            context,
          ),
          Divider(color: colors.borderGlass, height: 16.0),
          _buildTypoItem(
            'bodyMedium (14sp, Regular)',
            Text(
              'External non-invasive visual coach operating strictly via passive display.',
              style: TypographyTokens.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
            context,
          ),
          Divider(color: colors.borderGlass, height: 16.0),
          _buildTypoItem(
            'heroHeadline (24sp, Black)',
            Text(
              '5V5 ACTION GAMEPLAY',
              style: TypographyTokens.heroHeadline.copyWith(
                color: colors.textPrimary,
              ),
            ),
            context,
          ),
          Divider(color: colors.borderGlass, height: 16.0),
          _buildTypoItem(
            'playWingTitle (19sp, Extra-Bold)',
            Text(
              'Play',
              style: TypographyTokens.playWingTitle.copyWith(
                color: colors.textPrimary,
              ),
            ),
            context,
          ),
          Divider(color: colors.borderGlass, height: 16.0),
          _buildTypoItem(
            'gaugeNumerals (22sp, Extra-Bold)',
            Text(
              '120',
              style: TypographyTokens.gaugeNumerals.copyWith(
                color: colors.textPrimary,
              ),
            ),
            context,
          ),
          Divider(color: colors.borderGlass, height: 16.0),
          _buildTypoItem(
            'settingsRowTitle (14sp, Semi-Bold)',
            Text(
              'Performance optimization',
              style: TypographyTokens.settingsRowTitle.copyWith(
                color: colors.textPrimary,
              ),
            ),
            context,
          ),
          Divider(color: colors.borderGlass, height: 16.0),
          _buildTypoItem(
            'statusMicro (11.5sp, Semi-Bold)',
            Text(
              '71%  •  CPU 30%',
              style: TypographyTokens.statusMicro.copyWith(
                color: colors.textSecondary,
              ),
            ),
            context,
          ),
          Divider(color: colors.borderGlass, height: 16.0),
          _buildTypoItem(
            'subpillLabel (9.5sp, Extra-Bold, +1.0px)',
            Text(
              'SKILL LEADS TO VICTORY',
              style: TypographyTokens.subpillLabel.copyWith(
                color: colors.textPrimary,
              ),
            ),
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildTypoItem(
    String title,
    Widget specimen,
    BuildContext context,
  ) {
    final colors = ColorTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TypographyTokens.tacticalBadge.copyWith(
            color: colors.textMuted,
            fontSize: 9.0,
          ),
        ),
        const SizedBox(height: 4.0),
        specimen,
      ],
    );
  }
}

/// Custom painter for tactical crosshairs in the draggable preview sandbox
class _GridCrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x1500F5D4)
      ..strokeWidth = 1.0;

    // Horizontal grid lines
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Vertical grid lines
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
