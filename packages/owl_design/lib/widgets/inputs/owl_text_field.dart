// language: Dart, file: owl_text_field.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owl_design/theme/tokens/tokens.dart';

/// A sleek, tactical input field for the Owl MOBA Companion HUD.
///
/// Features:
/// - Deep OLED/Glass background with subtle 1px border.
/// - Glowing neon cyan outline on focus with ambient bloom shadow.
/// - Crimson red alert outline & warning icon on validation error.
/// - Built-in toggle for obscure text (API keys like Gemini / OpenAI / Claude).
/// - Instant clear button (`×`) when text is present.
/// - Monospace typography toggle for token hashes / keys (`JetBrains Mono`).
/// - Micro-animated icon transitions and crisp haptics.
class OwlTextField extends StatefulWidget {
  const OwlTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffix,
    this.isPassword = false,
    this.isMonospace = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffix;
  final bool isPassword;
  final bool isMonospace;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<OwlTextField> createState() => _OwlTextFieldState();
}

class _OwlTextFieldState extends State<OwlTextField> {
  late TextEditingController _effectiveController;
  late FocusNode _effectiveFocusNode;
  bool _isInternalController = false;
  bool _isInternalFocusNode = false;

  bool _isObscured = false;
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _effectiveController = widget.controller!;
    } else {
      _effectiveController = TextEditingController(text: widget.initialValue);
      _isInternalController = true;
    }

    if (widget.focusNode != null) {
      _effectiveFocusNode = widget.focusNode!;
    } else {
      _effectiveFocusNode = FocusNode();
      _isInternalFocusNode = true;
    }

    _isObscured = widget.isPassword;
    _hasText = _effectiveController.text.isNotEmpty;

    _effectiveController.addListener(_handleTextChange);
    _effectiveFocusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant OwlTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _effectiveController.removeListener(_handleTextChange);
        _effectiveController.dispose();
      }
      if (widget.controller != null) {
        _effectiveController = widget.controller!;
        _isInternalController = false;
      } else {
        _effectiveController = TextEditingController(text: widget.initialValue);
        _isInternalController = true;
      }
      _effectiveController.addListener(_handleTextChange);
      _hasText = _effectiveController.text.isNotEmpty;
    }

    if (widget.isPassword != oldWidget.isPassword) {
      _isObscured = widget.isPassword;
    }
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_handleTextChange);
    _effectiveFocusNode.removeListener(_handleFocusChange);

    if (_isInternalController) {
      _effectiveController.dispose();
    }
    if (_isInternalFocusNode) {
      _effectiveFocusNode.dispose();
    }
    super.dispose();
  }

  void _handleTextChange() {
    final hasNow = _effectiveController.text.isNotEmpty;
    if (_hasText != hasNow) {
      setState(() {
        _hasText = hasNow;
      });
    }
  }

  void _handleFocusChange() {
    if (_isFocused != _effectiveFocusNode.hasFocus) {
      setState(() {
        _isFocused = _effectiveFocusNode.hasFocus;
      });
    }
  }

  void _clearText() {
    HapticFeedback.lightImpact();
    _effectiveController.clear();
    widget.onChanged?.call('');
  }

  void _toggleObscure() {
    HapticFeedback.selectionClick();
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = ColorTokens.of(context);
    final bool hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    // Resolve border color & shadow
    Color borderColor;
    List<BoxShadow> shadows;

    if (!widget.enabled) {
      borderColor = t.borderGlass;
      shadows = const [];
    } else if (hasError) {
      borderColor = t.alertDanger;
      shadows = [
        BoxShadow(
          color: t.alertDanger.withValues(alpha: 0.35),
          blurRadius: 10,
          spreadRadius: 0,
        ),
      ];
    } else if (_isFocused) {
      borderColor = t.accentCyan;
      shadows = [
        BoxShadow(
          color: t.accentCyan.withValues(alpha: 0.35),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ];
    } else {
      borderColor = t.borderGlass;
      shadows = t.isDark
          ? const [ElevationTokens.subtleBorder]
          : const [
              BoxShadow(
                color: Color(0x080F172A),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ];
    }

    // Typography style
    final TextStyle inputTextStyle = widget.isMonospace
        ? GoogleFonts.outfit(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: widget.enabled ? t.textPrimary : t.textMuted,
            letterSpacing: _isObscured ? 2.0 : 0.4,
          )
        : GoogleFonts.outfit(
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
            color: widget.enabled ? t.textPrimary : t.textMuted,
            letterSpacing: 0.1,
          );

    final TextStyle hintTextStyle = widget.isMonospace
        ? GoogleFonts.outfit(
            fontSize: 13.0,
            fontWeight: FontWeight.w400,
            color: t.textMuted,
          )
        : GoogleFonts.outfit(
            fontSize: 13.0,
            fontWeight: FontWeight.w400,
            color: t.textMuted,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Optional Upper Label
        if (widget.labelText != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: SpacingTokens.xxs, bottom: SpacingTokens.xs),
            child: Row(
              children: [
                Text(
                  widget.labelText!.toUpperCase(),
                  style: TypographyTokens.tacticalLabel.copyWith(
                    color: hasError
                        ? t.alertDanger
                        : (_isFocused ? t.accentCyan : t.textSecondary),
                    fontSize: 11.0,
                  ),
                ),
                if (widget.isMonospace) ...[
                  const SizedBox(width: SpacingTokens.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: t.isDark ? ColorPrimitives.glassCyan15 : const Color(0x1A0EA5E9),
                      borderRadius: RadiusTokens.borderXs,
                      border: Border.all(
                        color: t.accentCyan.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      'MONO',
                      style: GoogleFonts.outfit(
                        fontSize: 9.0,
                        fontWeight: FontWeight.w700,
                        color: t.accentCyan,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],

        // Input Container
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: widget.enabled
                ? t.inputBg
                : (t.isDark ? ColorPrimitives.glassOled85 : const Color(0xFFF1F5F9)),
            borderRadius: RadiusTokens.card,
            border: Border.all(
              color: borderColor,
              width: _isFocused || hasError ? 1.5 : 1.0,
            ),
            boxShadow: shadows,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md,
            vertical: SpacingTokens.xxs,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Prefix icon
              if (widget.prefixIcon != null) ...[
                Padding(
                  padding: const EdgeInsets.only(right: SpacingTokens.sm),
                  child: IconTheme(
                    data: IconThemeData(
                      color: hasError
                          ? t.alertDanger
                          : (_isFocused ? t.accentCyan : t.textSecondary),
                      size: 18.0,
                    ),
                    child: widget.prefixIcon!,
                  ),
                ),
              ],

              // Actual Editable Text Field
              Expanded(
                child: TextField(
                  controller: _effectiveController,
                  focusNode: _effectiveFocusNode,
                  enabled: widget.enabled,
                  readOnly: widget.readOnly,
                  autofocus: widget.autofocus,
                  obscureText: _isObscured,
                  obscuringCharacter: '•',
                  style: inputTextStyle,
                  cursorColor: t.accentCyan,
                  cursorWidth: 2.0,
                  cursorRadius: const Radius.circular(1.0),
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  maxLines: widget.isPassword ? 1 : widget.maxLines,
                  minLines: widget.minLines,
                  maxLength: widget.maxLength,
                  inputFormatters: widget.inputFormatters,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: SpacingTokens.sm + 2,
                    ),
                    hintText: widget.hintText,
                    hintStyle: hintTextStyle,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    counterText: '',
                  ),
                ),
              ),

              // Clear Button (shows when text is present & editable)
              if (widget.enabled && !widget.readOnly && _hasText) ...[
                GestureDetector(
                  onTap: _clearText,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Container(
                      padding: const EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                        color: t.surfaceElevated,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: t.borderGlass,
                          width: 0.8,
                        ),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 13.0,
                        color: t.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],

              // Obscure / Reveal Toggle (for API keys / password mode)
              if (widget.isPassword) ...[
                GestureDetector(
                  onTap: _toggleObscure,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Icon(
                      _isObscured
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 19.0,
                      color: _isObscured
                          ? t.textSecondary
                          : t.accentCyan,
                    ),
                  ),
                ),
              ],

              // Custom Suffix Widget
              if (widget.suffix != null) ...[
                Padding(
                  padding: const EdgeInsets.only(left: SpacingTokens.xs),
                  child: widget.suffix!,
                ),
              ],
            ],
          ),
        ),

        // Helper or Error Text Display
        if (hasError) ...[
          Padding(
            padding: const EdgeInsets.only(
              left: SpacingTokens.xs,
              top: SpacingTokens.xxs + 2,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 13.0,
                  color: t.alertDanger,
                ),
                const SizedBox(width: 4.0),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: GoogleFonts.outfit(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: t.alertDanger,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else if (widget.helperText != null && widget.helperText!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(
              left: SpacingTokens.xs,
              top: SpacingTokens.xxs + 2,
            ),
            child: Text(
              widget.helperText!,
              style: GoogleFonts.outfit(
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                color: t.textMuted,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
