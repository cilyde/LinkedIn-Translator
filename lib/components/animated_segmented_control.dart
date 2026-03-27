import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Animated Cupertino Segmented Control
/// Features: Spring-based sliding animation, haptic feedback, tap scaling, swiping support.
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
    this.animationDuration = const Duration(milliseconds: 580),
    this.enableHaptics = true,
    this.activeColor = AppColors.primaryBlue,
    this.inactiveColor = AppColors.lightSecondaryBackground,
  });

  @override
  State<AnimatedCupertinoSegmentedControl> createState() =>
      _AnimatedCupertinoSegmentedControlState<T>();
}

class _AnimatedCupertinoSegmentedControlState<T>
    extends State<AnimatedCupertinoSegmentedControl<T>> {
  bool _isDragging = false;
  double _dragDelta = 0.0;
  int? _pressedIndex;

  void _onSegmentTapDown(int index) {
    setState(() {
      _pressedIndex = index;
    });
  }

  void _onSegmentTapUpCancel() {
    setState(() {
      _pressedIndex = null;
    });
  }

  int get _currentIndex {
    final entries = widget.children.entries.toList();
    final index = entries.indexWhere(
      (element) => element.key == widget.groupValue,
    );
    return index < 0 ? 0 : index;
  }

  void _onSegmentTapped(int index, Widget child) {
    if (widget.enableHaptics) HapticFeedback.selectionClick();
    final value = widget.children.keys.elementAt(index);
    widget.onValueChanged(value);
  }

  void _onDragUpdate(DragUpdateDetails details, double segmentWidth) {
    setState(() {
      _isDragging = true;
      _dragDelta += details.delta.dx;
      if (_dragDelta.abs() > segmentWidth * 0.35) {
        final direction = _dragDelta.sign.toInt();
        final nextIndex = (_currentIndex + direction).clamp(
          0,
          widget.children.length - 1,
        );
        if (nextIndex != _currentIndex) {
          _onSegmentTapped(
            nextIndex,
            widget.children.values.elementAt(nextIndex),
          );
        }
        _dragDelta = 0;
      }
    });
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _dragDelta = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.children.entries.toList();
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final int selectedIndex = _currentIndex;

    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkGroupedBackground.withOpacity(0.65)
            : AppColors.lightGroupedBackground.withOpacity(0.68),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border(context).withOpacity(0.25),
          width: 0.7,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth =
              (constraints.maxWidth - widget.padding.horizontal) /
              entries.length;
          final indicatorWidth = segmentWidth * (_isDragging ? 1.08 : 1.0);
          final leftPos =
              (selectedIndex * segmentWidth) +
              (0.5 * (segmentWidth - indicatorWidth));

          return GestureDetector(
            onHorizontalDragUpdate: (details) =>
                _onDragUpdate(details, segmentWidth),
            onHorizontalDragEnd: _onDragEnd,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                AnimatedPositioned(
                  duration: widget.animationDuration,
                  curve: Curves.bounceOut,
                  left: leftPos,
                  width: indicatorWidth,
                  height: 38,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.activeColor.withOpacity(0.76),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.14),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 0.8,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: entries.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final child = entry.value.value;
                    final isSelected = idx == selectedIndex;

                    final isPressed = _pressedIndex == idx;
                    return Expanded(
                      child: Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          splashFactory: InkRipple.splashFactory,
                          splashColor: widget.activeColor.withOpacity(0.35),
                          highlightColor: widget.activeColor.withOpacity(0.18),
                          onTap: () => _onSegmentTapped(idx, child),
                          onTapDown: (_) => _onSegmentTapDown(idx),
                          onTapUp: (_) => _onSegmentTapUpCancel(),
                          onTapCancel: _onSegmentTapUpCancel,
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 120),
                            curve: Curves.easeOutCubic,
                            scale: isPressed ? 0.94 : 1.0,
                            child: AnimatedContainer(
                              duration: widget.animationDuration,
                              curve: Curves.easeOutCubic,
                              alignment: Alignment.center,
                              height: 42,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: DefaultTextStyle(
                                style: AppTypography.headline.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary),
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                                child: child,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
