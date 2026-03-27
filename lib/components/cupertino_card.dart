import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Cupertino-styled Card with glassmorphism and touch microinteraction support.
class CupertinoCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final double? elevation;
  final VoidCallback? onTap;
  final bool enableFeedback;

  const CupertinoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 16,
    this.elevation = 0,
    this.onTap,
    this.enableFeedback = true,
  });

  @override
  State<CupertinoCard> createState() => _CupertinoCardState();
}

class _CupertinoCardState extends State<CupertinoCard> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  bool _isHeld = false;

  void _setPressed(bool value) {
    setState(() {
      _isPressed = value;
      if (!value) _isHeld = false;
    });
  }

  void _setHeld(bool value) {
    setState(() {
      _isHeld = value;
      if (value) _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final bgColor = widget.backgroundColor ?? (isDark ? AppColors.darkTertiaryBackground : AppColors.lightBackground);
    final borderCol = widget.borderColor ?? (isDark ? AppColors.darkBorder : AppColors.lightBorder);

    final scale = _isHeld
        ? 1.02
        : _isPressed
        ? 0.96
        : 1.0;

    final shadowOpacity = _isHeld ? 0.22 : (_isPressed ? 0.08 : 0.12);
    final blurRadius = _isHeld ? 20.0 : 14.0;
    final offsetY = _isHeld ? 8.0 : 6.0;

    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutQuint,
      transform: Matrix4.identity()..scale(scale, scale, 1.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: borderCol.withOpacity(0.6), width: 1.1),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bgColor.withOpacity(0.48), bgColor.withOpacity(0.26)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(shadowOpacity),
            blurRadius: blurRadius,
            spreadRadius: _isHeld ? 1.8 : 0.4,
            offset: Offset(0, offsetY),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: _isHeld ? 14 : 9, sigmaY: _isHeld ? 14 : 9),
                child: Container(color: Colors.white.withOpacity(0.12)),
              ),
            ),
          ),
          Positioned.fill(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: _isHeld ? 0.22 : 0.14,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white.withOpacity(0.18), Colors.white.withOpacity(0.01)],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  gradient: LinearGradient(colors: [Colors.white.withOpacity(0.15), Colors.transparent], stops: const [0.0, 0.94]),
                ),
              ),
            ),
          ),
          Padding(padding: widget.padding, child: widget.child),
        ],
      ),
    );

    if (widget.onTap != null) {
      content = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) {
          _setPressed(false);
          widget.onTap?.call();
        },
        onTapCancel: () => _setPressed(false),
        onLongPress: () => _setHeld(true),
        onLongPressEnd: (_) => _setHeld(false),
        child: content,
      );
    }

    return content;
  }
}
