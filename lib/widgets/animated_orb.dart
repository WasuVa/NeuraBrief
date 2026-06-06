import "dart:math";

import "package:flutter/material.dart";

import "../core/constants/app_constants.dart";

class AnimatedOrb extends StatefulWidget {
  const AnimatedOrb({super.key, this.size = 180});

  final double size;

  @override
  State<AnimatedOrb> createState() => _AnimatedOrbState();
}

class _AnimatedOrbState extends State<AnimatedOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Transform.scale(
          scale: _pulse.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _buildRing(0.0, widget.size, 0.12),
              _buildRing(pi / 3, widget.size * 0.8, 0.2),
              _buildCore(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRing(double rotation, double size, double opacity) {
    return Transform.rotate(
      angle: _controller.value * 2 * pi + rotation,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppConstants.primary.withValues(alpha: opacity),
              AppConstants.secondary.withValues(alpha: opacity),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppConstants.primary.withValues(alpha: 0.3),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCore() {
    return Container(
      width: widget.size * 0.45,
      height: widget.size * 0.45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppConstants.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppConstants.secondary.withValues(alpha: 0.6),
            blurRadius: 30,
            spreadRadius: 6,
          ),
        ],
      ),
    );
  }
}
