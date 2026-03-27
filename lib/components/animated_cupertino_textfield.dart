import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Animated Cupertino Text Field with focus effects
class AnimatedCupertinoTextField extends StatefulWidget {
  final TextEditingController controller;
  final String placeholder;
  final String? label;
  final int minLines;
  final int? maxLines;
  final TextInputType keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final Icon? prefixIcon;
  final IconButton? suffixIcon;

  const AnimatedCupertinoTextField({
    super.key,
    required this.controller,
    this.placeholder = '',
    this.label,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.onChanged,
    this.onEditingComplete,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  State<AnimatedCupertinoTextField> createState() =>
      _AnimatedCupertinoTextFieldState();
}

class _AnimatedCupertinoTextFieldState
    extends State<AnimatedCupertinoTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _controller;
  late Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _borderAnimation =
        Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTypography.subheadline.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        AnimatedBuilder(
          animation: _borderAnimation,
          builder: (context, _) {
            return Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkTertiaryBackground
                    : AppColors.lightBackground,
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? AppColors.primaryBlue.withValues(alpha: 0.5)
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: _borderAnimation.value,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                child: Row(
                  children: [
                    if (widget.prefixIcon != null) ...[
                      widget.prefixIcon!,
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: CupertinoTextField(
                        controller: widget.controller,
                        focusNode: _focusNode,
                        placeholder: widget.placeholder,
                        placeholderStyle: AppTypography.body.copyWith(
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary,
                        ),
                        style: AppTypography.body.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                        minLines: widget.minLines,
                        maxLines: widget.maxLines,
                        keyboardType: widget.keyboardType,
                        obscureText: widget.obscureText,
                        onChanged: widget.onChanged,
                        onEditingComplete: widget.onEditingComplete,
                        decoration: null,
                      ),
                    ),
                    if (widget.suffixIcon != null) ...[
                      const SizedBox(width: 8),
                      widget.suffixIcon!,
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
