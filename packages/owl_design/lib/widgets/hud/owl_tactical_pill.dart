// language: Dart, file: owl_tactical_pill.dart, target: Flutter / Owl MOBA HUD
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owl_design/theme/tokens/tokens.dart';

/// Status of the live AI Tactical Assistant embedded in the HUD Pill.
enum OwlAiStatus {
  /// AI is actively listening and observing game state.
  online,

  /// AI is running tactical inference / processing.
  analyzing,

  /// Critical threat detected (e.g. ambush / rotation).
  warning,

  /// AI standby / offline.
  standby,
}

/// Floating tactical HUD capsule engineered for real-time MOBA overlays.
///
/// Features:
/// - Ultra-compact, draggable floating pill widget.
/// - Glassmorphic backdrop blur (sigma: 10.0) with deep OLED glass fill.
/// - Animated glowing neon border reflecting urgency and AI status.
/// - Next objective icon and label (e.g. "DRAGON", "BARON", "LORD", "TURTLE").
/// - High-precision monospaced tabular countdown (e.g. "00:42").
/// - Live breathing AI status dot.
/// - Expandable drawer on tap showing quick actions or objective details.
/// - Emil Kowalski 160ms `easeOutCubic` press-down micro-scale (`0.97`).
class OwlTacticalPill extends StatefulWidget {
  const OwlTacticalPill({
    super.key,
    required this.objectiveName,
    required this.countdownSeconds,
    this.objectiveIcon = Icons.shield_outlined,
    this.aiStatus = OwlAiStatus.online,
    this.initialPosition = const Offset(16, 60),
    this.isDraggable = true,
    this.isExpanded,
    this.onTap,
    this.onExpandToggle,
    this.onQuickAction,
    this.onPositionChanged,
    this.expandedChild,
  });

  /// Name of the imminent objective (e.g., "DRAGON", "BARON", "LORD").
  final String objectiveName;

  /// Remaining seconds until spawn or event.
  final int countdownSeconds;

  /// Icon representing the objective type.
  final IconData objectiveIcon;

  /// Current status of the tactical AI engine.
  final OwlAiStatus aiStatus;

  /// Starting screen coordinate offset when rendered floating.
  final Offset initialPosition;

  /// Whether the pill can be freely dragged around the screen.
  final bool isDraggable;

  /// Explicit expanded state override (if controlled externally).
  final bool? isExpanded;

  /// Primary tap callback.
  final VoidCallback? onTap;

  /// Fired when expansion state changes.
  final ValueChanged<bool>? onExpandToggle;

  /// Fired when quick action is tapped from the expanded tray.
  final ValueChanged<String>? onQuickAction;

  /// Optional callback when position changes during dragging.
  final ValueChanged<Offset>? onPositionChanged;

  /// Custom widget rendered when the pill expands.
  final Widget? expandedChild;

  @override
  State<OwlTacticalPill> createState() => _OwlTacticalPillState();
}

class _OwlTacticalPillState extends State<OwlTacticalPill>
    with SingleTickerProviderStateMixin {
  late Offset _position;
  bool _isPressed = false;
  bool _internalExpanded = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool get _effectiveExpanded => widget.isExpanded ?? _internalExpanded;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      final nextState = !_effectiveExpanded;
      setState(() {
        _internalExpanded = nextState;
      });
      widget.onExpandToggle?.call(nextState);
    }
  }

  String _formatTimer(int totalSeconds) {
    if (totalSeconds < 0) return "00:00";
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color _resolveUrgencyColor(BuildContext context) {
    final colors = ColorTokens.of(context);
    if (widget.countdownSeconds <= 10) {
      return colors.alertDanger;
    } else if (widget.countdownSeconds <= 30) {
      return colors.alertWarning;
    }
    return colors.accentCyan;
  }

  Color _resolveAiColor(BuildContext context) {
    final colors = ColorTokens.of(context);
    switch (widget.aiStatus) {
      case OwlAiStatus.online:
        return colors.alertSuccess;
      case OwlAiStatus.analyzing:
        return colors.accentCyan;
      case OwlAiStatus.warning:
        return colors.alertDanger;
      case OwlAiStatus.standby:
        return colors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorTokens.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final urgencyColor = _resolveUrgencyColor(context);
    final aiColor = _resolveAiColor(context);
    final isUrgent = widget.countdownSeconds <= 10;

    final pillWidget = GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: _handleTap,
      onPanUpdate: widget.isDraggable
          ? (details) {
              setState(() {
                _position += details.delta;
              });
              widget.onPositionChanged?.call(_position);
            }
          : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            final pulseVal = isUrgent ? _pulseAnimation.value : 0.8;
            final glowColor = urgencyColor.withValues(alpha: 0.25 * pulseVal);

            return ClipRRect(
              borderRadius: RadiusTokens.borderPill,
              child: BackdropFilter(
                filter: ElevationTokens.glassFilter,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 38.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.pillPaddingHorizontal,
                    vertical: SpacingTokens.pillPaddingVertical,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? ColorPrimitives.glassDeepSlate85
                        : const Color(0xF0FFFFFF),
                    borderRadius: RadiusTokens.borderPill,
                    border: Border.all(
                      color: urgencyColor.withValues(alpha: (isDark ? 0.6 : 0.7) * pulseVal),
                      width: 1.2,
                    ),
                    boxShadow: [
                      if (!isDark)
                        const BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      BoxShadow(
                        color: glowColor,
                        blurRadius: isUrgent ? 14.0 : 8.0,
                        spreadRadius: isUrgent ? 1.0 : 0.0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // AI Status Dot
                      Container(
                        width: 7.0,
                        height: 7.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: aiColor,
                          boxShadow: [
                            BoxShadow(
                              color: aiColor.withValues(alpha: 0.8 * _pulseAnimation.value),
                              blurRadius: 6.0,
                              spreadRadius: 1.0,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: SpacingTokens.xs),

                      // Objective Icon
                      Icon(
                        widget.objectiveIcon,
                        size: 15.0,
                        color: urgencyColor,
                      ),
                      const SizedBox(width: 5.0),

                      // Objective Name
                      Text(
                        widget.objectiveName.toUpperCase(),
                        style: TypographyTokens.tacticalLabel.copyWith(
                          color: colors.textPrimary,
                          fontSize: 10.5,
                          letterSpacing: 1.1,
                        ),
                      ),

                      // Divider pip
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Container(
                          width: 3.0,
                          height: 3.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.borderGlass,
                          ),
                        ),
                      ),

                      // Monospaced Countdown Timer
                      Text(
                        _formatTimer(widget.countdownSeconds),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: urgencyColor,
                          letterSpacing: -0.3,
                          fontFeatures: const [
                            ui.FontFeature.tabularFigures(),
                            ui.FontFeature.slashedZero(),
                          ],
                        ),
                      ),

                      // Chevron Indicator for Expansion
                      const SizedBox(width: 5.0),
                      AnimatedRotation(
                        turns: _effectiveExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16.0,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    final Widget content = _effectiveExpanded
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              pillWidget,
              const SizedBox(height: SpacingTokens.xs),
              _buildExpandedDrawer(urgencyColor, context),
            ],
          )
        : pillWidget;

    if (widget.onPositionChanged != null) {
      return content;
    }

    return Transform.translate(
      offset: _position - widget.initialPosition,
      child: content,
    );
  }

  Widget _buildExpandedDrawer(Color accentColor, BuildContext context) {
    if (widget.expandedChild != null) {
      return widget.expandedChild!;
    }

    final colors = ColorTokens.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: RadiusTokens.card,
      child: BackdropFilter(
        filter: ElevationTokens.glassFilterDense,
        child: Container(
          width: 275.0,
          padding: const EdgeInsets.all(SpacingTokens.sm),
          decoration: BoxDecoration(
            color: isDark
                ? ColorPrimitives.glassOled85
                : const Color(0xF5FFFFFF),
            borderRadius: RadiusTokens.card,
            border: Border.all(
              color: accentColor.withValues(alpha: isDark ? 0.4 : 0.6),
              width: 1.0,
            ),
            boxShadow: [
              if (!isDark)
                const BoxShadow(
                  color: Color(0x18000000),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ElevationTokens.cardAmbient,
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TACTICAL TELEMETRY',
                    style: TypographyTokens.tacticalBadge.copyWith(
                      color: colors.textSecondary,
                      fontSize: 8.5,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: isDark
                          ? ColorPrimitives.glassCyan15
                          : const Color(0xFFE0F2FE),
                      borderRadius: RadiusTokens.borderXs,
                    ),
                    child: Text(
                      'AI ACTIVE',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 8.0,
                        fontWeight: FontWeight.w700,
                        color: colors.accentCyan,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.xs),

              // Detail Row
              Row(
                children: [
                  Icon(widget.objectiveIcon, size: 14.0, color: accentColor),
                  const SizedBox(width: 6.0),
                  Expanded(
                    child: Text(
                      widget.objectiveName,
                      style: TypographyTokens.bodySmall.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  Text(
                    'SPAWN IN ${_formatTimer(widget.countdownSeconds)}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.xs),
              Divider(color: colors.borderGlass, height: 1.0),
              const SizedBox(height: SpacingTokens.xs),

              // Quick Action Pings
              Wrap(
                spacing: SpacingTokens.xxs,
                runSpacing: SpacingTokens.xxs,
                children: [
                  _buildQuickActionBtn('CONTEST', Icons.flash_on_rounded, accentColor),
                  _buildQuickActionBtn('TRADE', Icons.swap_horiz_rounded, colors.accentPurple),
                  _buildQuickActionBtn('GIVE/PUSH', Icons.arrow_forward_rounded, colors.alertWarning),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionBtn(String label, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onQuickAction?.call(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: RadiusTokens.borderXs,
          border: Border.all(
            color: color.withValues(alpha: 0.4),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11.0, color: color),
            const SizedBox(width: 3.5),
            Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
