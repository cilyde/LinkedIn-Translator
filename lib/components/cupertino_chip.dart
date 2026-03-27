import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Animated Chip/Tag component for Cupertino UI
class CupertinoChip extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final Color? activeColor;
  final Icon? leadingIcon;
  final bool enabled;

  const CupertinoChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.activeColor = AppColors.primaryBlue,
    this.leadingIcon,
    this.enabled = true,
  });

  @override
  State<CupertinoChip> createState() => _CupertinoChipState();
}

class _CupertinoChipState extends State<CupertinoChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    if (widget.selected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(CupertinoChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      if (widget.selected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: widget.enabled ? widget.onSelected : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: widget.selected
                ? (widget.activeColor ?? AppColors.primaryBlue)
                : (isDark
                    ? AppColors.darkTertiaryBackground
                    : AppColors.lightGroupedBackground),
            borderRadius: BorderRadius.circular(20),
            border: !widget.selected
                ? Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.leadingIcon != null) ...[
                widget.leadingIcon!,
                const SizedBox(width: 6),
              ],
              Text(
                widget.label,
                style: AppTypography.subheadline.copyWith(
                  color: widget.selected
                      ? Colors.white
                      : (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary),
                  fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
