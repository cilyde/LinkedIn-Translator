import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Animated Cupertino Segmented Control
/// Features: Spring-based sliding animation, haptic feedback, tap scaling
class AnimatedCupertinoSegmentedControl<T> extends StatefulWidget {
  final Map<T, Widget> children;
  final T groupValue;
  final ValueChanged<T> onValueChanged;
  final EdgeInsetsGeometry padding;
  final Duration animationDuration;
  final bool enableHaptics;
  final Color activeColor;
  final Color inactiveColor;

  const AnimatedCupertinoSegmentedControl({
    super.key,
    required this.children,
    required this.groupValue,
    required this.onValueChanged,
    this.padding = const EdgeInsets.all(4),
    this.animationDuration = const Duration(milliseconds: 350),
    this.enableHaptics = true,
    this.activeColor = AppColors.primaryBlue,
    this.inactiveColor = AppColors.lightSecondaryBackground,
  });

  @override
  State<AnimatedCupertinoSegmentedControl> createState() =>
      _AnimatedCupertinoSegmentedControlState<T>();
}

class _AnimatedCupertinoSegmentedControlState<T>
    extends State<AnimatedCupertinoSegmentedControl<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _setupAnimations();
  }

  void _setupAnimations() {
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void didUpdateWidget(AnimatedCupertinoSegmentedControl<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.groupValue != widget.groupValue) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSegmentTapped(T value) {
    if (widget.enableHaptics) {
      HapticFeedback.selectionClick();
    }
    _controller.forward(from: 0.0);
    widget.onValueChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final activeColor = widget.activeColor;

    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightGroupedBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: widget.children.entries.toList().asMap().entries.map((entry) {
          final mapEntry = entry.value;
          final value = mapEntry.key;
          final child = mapEntry.value;
          final isSelected = value == widget.groupValue;

          return Expanded(
            child: GestureDetector(
              onTap: () => _onSegmentTapped(value),
              child: ScaleTransition(
                scale: _scaleAnimation.drive(Tween<double>(
                  begin: 1.0,
                  end: isSelected ? 1.02 : 1.0,
                )),
                child: AnimatedContainer(
                  duration: widget.animationDuration,
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: isSelected ? activeColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    child: Center(
                      child: DefaultTextStyle(
                        style: AppTypography.headline.copyWith(
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
