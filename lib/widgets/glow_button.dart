import "package:flutter/material.dart";
import "../core/constants/app_constants.dart";

class GlowButton extends StatefulWidget {
  const GlowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool fullWidth;

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.95);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: widget.fullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            gradient: AppConstants.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppConstants.primary.withValues(alpha: 0.5),
                blurRadius: 16,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Row(
            mainAxisSize:
                widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: Colors.white),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}