import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Animated Cupertino Button with physical touch feel and glass glow.
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

class _AnimatedCupertinoButtonState extends State<AnimatedCupertinoButton> {
  bool _isPressed = false;
  bool _isHeld = false;

  void _onTapDown(_) {
    if (!widget.enabled || widget.isLoading) return;
    setState(() => _isPressed = true);
  }

  void _onTapUp(_) {
    if (!widget.enabled || widget.isLoading) return;
    setState(() {
      _isPressed = false;
      _isHeld = false;
    });
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
      _isHeld = false;
    });
  }

  void _onLongPress() {
    if (!widget.enabled || widget.isLoading) return;
    setState(() {
      _isHeld = true;
      _isPressed = false;
    });
  }

  void _onLongPressEnd(_) {
    setState(() {
      _isHeld = false;
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    final scale = _isHeld
        ? 1.02
        : _isPressed
            ? 0.92
            : 1.0;

    final glowOpacity = _isHeld ? 0.32 : (_isPressed ? 0.24 : 0.14);
    final shadowBlur = _isHeld ? 28.0 : (_isPressed ? 16.0 : 14.0);
    final shadowOffset = _isHeld ? 10.0 : (_isPressed ? 6.0 : 5.0);

    return Transform.scale(
      scale: scale,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onLongPress: _onLongPress,
        onLongPressEnd: _onLongPressEnd,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: widget.enabled && !widget.isLoading ? 1.0 : 0.58,
          child: Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (widget.backgroundColor ??
                          (isDark
                              ? AppColors.primaryBlueLight
                              : AppColors.primaryBlue))
                      .withOpacity(0.96),
                  (widget.backgroundColor ??
                          (isDark
                              ? AppColors.primaryBlueLight
                              : AppColors.primaryBlue))
                      .withOpacity(0.86),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(glowOpacity),
                  blurRadius: shadowBlur,
                  offset: Offset(0, shadowOffset),
                )
              ],
            ),
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
    );
  }
}
