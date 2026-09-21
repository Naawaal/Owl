import 'package:flutter/material.dart';
import '../theme/app_typography.dart';
import '../theme/owl_theme_extension.dart';

/// Modal bottom sheet container featuring Minimal Titanium & Slate styling,
/// drag handle, optional title bar, and dark surface background.
class OwlBottomSheet extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget child;
  final bool showCloseButton;
  final EdgeInsetsGeometry padding;

  const OwlBottomSheet({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.showCloseButton = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  });

  /// Displays the modal bottom sheet using standard Navigator and Titanium theme.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    String? subtitle,
    bool showCloseButton = true,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) {
        return OwlBottomSheet(
          title: title,
          subtitle: subtitle,
          showCloseButton: showCloseButton,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = OwlThemeExtension.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: tokens.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: tokens.borderStrong,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 30,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            // Centered Drag Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: tokens.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Header (Title, Subtitle & Close Action)
            if (title != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title!,
                            style: AppTypography.headlineMedium.copyWith(
                              color: tokens.textPrimary,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              style: AppTypography.bodySmall.copyWith(
                                color: tokens.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (showCloseButton)
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close_rounded,
                          color: tokens.textTertiary,
                          size: 20,
                        ),
                        splashRadius: 20,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Divider(
                color: tokens.borderSubtle,
                height: 1,
                thickness: 1,
              ),
            ],

            // Content body
            Flexible(
              child: Padding(
                padding: padding,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
