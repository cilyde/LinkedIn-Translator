import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Cupertino-styled Card with optional blur/vibrancy effect
class CupertinoCard extends StatelessWidget {
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
    this.enableFeedback = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDark ? AppColors.darkTertiaryBackground : AppColors.lightBackground);
    final borderCol = borderColor ??
        (isDark ? AppColors.darkBorder : AppColors.lightBorder);

    Widget content = Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderCol, width: 0.5),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (onTap != null) {
      content = GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
