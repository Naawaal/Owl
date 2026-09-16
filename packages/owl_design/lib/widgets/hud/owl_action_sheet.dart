// language: Dart, file: owl_action_sheet.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owl_design/theme/tokens/tokens.dart';

/// Data model representing a tactical ping action in [OwlActionSheet].
class OwlTacticalPing {
  const OwlTacticalPing({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    this.badgeText,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String? badgeText;

  /// Built-in MOBA fast match pings
  static const List<OwlTacticalPing> defaultPings = [
    OwlTacticalPing(
      id: 'mid_missing',
      title: 'MID MISSING',
      subtitle: 'Enemy lane roaming',
      icon: Icons.visibility_off_rounded,
      accentColor: ColorTokens.alertWarning,
      badgeText: 'CARE',
    ),
    OwlTacticalPing(
      id: 'contest',
      title: 'CONTEST OBJECTIVE',
      subtitle: 'Group for river fight',
      icon: Icons.flash_on_rounded,
      accentColor: ColorTokens.accentCyan,
      badgeText: 'READY',
    ),
    OwlTacticalPing(
      id: 'recall',
      title: 'RESET / RECALL',
      subtitle: 'Low HP or spend gold',
      icon: Icons.shield_moon_rounded,
      accentColor: ColorTokens.accentPurple,
    ),
    OwlTacticalPing(
      id: 'boss_objective',
      title: 'LORD / BARON',
      subtitle: 'Rush game-ending buff',
      icon: Icons.local_fire_department_rounded,
      accentColor: ColorTokens.alertDanger,
      badgeText: 'SMITE',
    ),
    OwlTacticalPing(
      id: 'invade',
      title: 'INVADE BUFF',
      subtitle: 'Steal enemy jungle camp',
      icon: Icons.explore_rounded,
      accentColor: ColorTokens.alertSuccess,
    ),
    OwlTacticalPing(
      id: 'group_up',
      title: 'GROUP UP 5v5',
      subtitle: 'Teamfight preparation',
      icon: Icons.groups_rounded,
      accentColor: ColorTokens.accentCyan,
      badgeText: 'STACK',
    ),
  ];
}

/// Tactical bottom sheet / drawer engineered for fast in-game match pings.
///
/// Features:
/// - Tactile drag handle at top.
/// - Glassmorphic blur background (sigma: 12.0) with OLED slate fill.
/// - 2-column or 3-column responsive grid of high-priority match pings.
/// - Emil Kowalski interaction polish: 160ms scale down (`0.96`), haptic feedback.
/// - Helper [OwlActionSheet.show] static method for rapid modal presentation.
class OwlActionSheet extends StatelessWidget {
  const OwlActionSheet({
    super.key,
    this.title = 'TACTICAL PINGS',
    this.pings = OwlTacticalPing.defaultPings,
    this.onPingSelected,
    this.onClose,
  });

  final String title;
  final List<OwlTacticalPing> pings;
  final ValueChanged<OwlTacticalPing>? onPingSelected;
  final VoidCallback? onClose;

  /// Helper static method to show [OwlActionSheet] as a bottom sheet.
  static Future<OwlTacticalPing?> show(
    BuildContext context, {
    String title = 'TACTICAL PINGS',
    List<OwlTacticalPing> pings = OwlTacticalPing.defaultPings,
  }) {
    HapticFeedback.mediumImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet<OwlTacticalPing>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: isDark
          ? ColorPrimitives.oledBlack.withValues(alpha: 0.65)
          : const Color(0x660F172A),
      isScrollControlled: true,
      builder: (ctx) => OwlActionSheet(
        title: title,
        pings: pings,
        onPingSelected: (ping) {
          Navigator.of(ctx).pop(ping);
        },
        onClose: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorTokens.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(20.0),
      ),
      child: BackdropFilter(
        filter: ElevationTokens.glassFilterDense,
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? ColorPrimitives.glassDeepSlate85
                : const Color(0xF8FFFFFF),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20.0),
            ),
            border: Border.all(
              color: colors.borderGlass,
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 24.0,
                offset: Offset(0, -6),
              ),
            ],
          ),
          padding: const EdgeInsets.only(
            top: SpacingTokens.sm,
            bottom: SpacingTokens.lg,
            left: SpacingTokens.md,
            right: SpacingTokens.md,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: colors.borderGlass,
                    borderRadius: RadiusTokens.borderPill,
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.md),

              // Sheet Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8.0,
                        height: 8.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.accentCyan,
                          boxShadow: [
                            BoxShadow(
                              color: colors.accentCyan.withValues(alpha: 0.7),
                              blurRadius: 8.0,
                              spreadRadius: 1.0,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: SpacingTokens.xs),
                      Text(
                        title.toUpperCase(),
                        style: TypographyTokens.tacticalLabel.copyWith(
                          color: colors.textPrimary,
                          fontSize: 13.0,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: onClose ?? () => Navigator.of(context).maybePop(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: isDark
                            ? ColorPrimitives.glassElevated85
                            : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.borderGlass,
                          width: 0.8,
                        ),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16.0,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.md),

              // Tactical Ping Grid (2 columns)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pings.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: SpacingTokens.sm,
                  mainAxisSpacing: SpacingTokens.sm,
                  childAspectRatio: 2.3,
                ),
                itemBuilder: (context, index) {
                  final ping = pings[index];
                  return _TacticalPingCard(
                    ping: ping,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      onPingSelected?.call(ping);
                    },
                  );
                },
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

class _TacticalPingCard extends StatefulWidget {
  const _TacticalPingCard({
    required this.ping,
    required this.onTap,
  });

  final OwlTacticalPing ping;
  final VoidCallback onTap;

  @override
  State<_TacticalPingCard> createState() => _TacticalPingCardState();
}

class _TacticalPingCardState extends State<_TacticalPingCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final ping = widget.ping;
    final colors = ColorTokens.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.sm,
            vertical: SpacingTokens.xs,
          ),
          decoration: BoxDecoration(
            color: _isPressed
                ? ping.accentColor.withValues(alpha: 0.18)
                : (isDark ? ColorPrimitives.glassElevated85 : const Color(0xFFF1F5F9)),
            borderRadius: RadiusTokens.card,
            border: Border.all(
              color: _isPressed
                  ? ping.accentColor
                  : ping.accentColor.withValues(alpha: isDark ? 0.35 : 0.5),
              width: _isPressed ? 1.5 : 1.0,
            ),
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: ping.accentColor.withValues(alpha: 0.3),
                      blurRadius: 10.0,
                      spreadRadius: 0.0,
                    ),
                  ]
                : const [ElevationTokens.subtleBorder],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Tactical Icon Container
              Container(
                width: 34.0,
                height: 34.0,
                decoration: BoxDecoration(
                  color: ping.accentColor.withValues(alpha: isDark ? 0.14 : 0.12),
                  borderRadius: RadiusTokens.borderSm,
                  border: Border.all(
                    color: ping.accentColor.withValues(alpha: isDark ? 0.3 : 0.4),
                    width: 0.8,
                  ),
                ),
                child: Icon(
                  ping.icon,
                  size: 18.0,
                  color: ping.accentColor,
                ),
              ),
              const SizedBox(width: SpacingTokens.xs + 2),

              // Title & Subtitle
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ping.title,
                            style: GoogleFonts.outfit(
                              fontSize: 11.0,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (ping.badgeText != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                              vertical: 1.0,
                            ),
                            decoration: BoxDecoration(
                              color: ping.accentColor.withValues(alpha: 0.2),
                              borderRadius: RadiusTokens.borderXs,
                            ),
                            child: Text(
                              ping.badgeText!,
                              style: GoogleFonts.outfit(
                                fontSize: 8.0,
                                fontWeight: FontWeight.w800,
                                color: ping.accentColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      ping.subtitle,
                      style: GoogleFonts.outfit(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w400,
                        color: colors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
