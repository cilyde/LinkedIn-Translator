import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Animated Cupertino Button with scale and opacity feedback
class AnimatedCupertinoButton extends StatefulWidget {
  final String? text;
  final Widget? icon;
  final Widget? child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool enabled;

  const AnimatedCupertinoButton({
    super.key,
    this.text,
    this.icon,
    this.child,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor = AppColors.primaryBlue,
    this.foregroundColor = Colors.white,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    this.borderRadius = 12,
    this.enabled = true,
  });

  @override
  State<AnimatedCupertinoButton> createState() =>
      _AnimatedCupertinoButtonState();
}

class _AnimatedCupertinoButtonState extends State<AnimatedCupertinoButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onPressed() async {
    if (!widget.enabled || widget.isLoading) return;
    
    await _controller.forward();
    await _controller.reverse();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: GestureDetector(
          onTap: _onPressed,
          child: AnimatedOpacity(
            opacity: widget.enabled && !widget.isLoading ? 1.0 : 0.6,
            duration: const Duration(milliseconds: 200),
            child: Container(
              decoration: BoxDecoration(
                color: widget.backgroundColor ??
                    (isDark ? AppColors.primaryBlueLight : AppColors.primaryBlue),
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              padding: widget.padding,
              child: widget.isLoading
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CupertinoActivityIndicator(
                        color: widget.foregroundColor ?? Colors.white,
                      ),
                    )
                  : (widget.child ??
                      (widget.icon != null
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                widget.icon!,
                                const SizedBox(width: 8),
                                Text(
                                  widget.text ?? '',
                                  style: AppTypography.headline.copyWith(
                                    color: widget.foregroundColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              widget.text ?? '',
                              style: AppTypography.headline.copyWith(
                                color: widget.foregroundColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ))),
            ),
          ),
        ),
      ),
    );
  }
}
