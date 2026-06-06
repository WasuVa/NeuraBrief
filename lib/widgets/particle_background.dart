import "dart:math";

import "package:flutter/material.dart";

class ParticleBackground extends StatefulWidget {
  const ParticleBackground({super.key, required this.child});

  final Widget child;

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final random = Random(42);
    _particles = List.generate(
      45,
      (_) => _Particle(
        position: Offset(random.nextDouble(), random.nextDouble()),
        speed: Offset(
          (random.nextDouble() - 0.5) * 0.02,
          (random.nextDouble() - 0.5) * 0.02,
        ),
        radius: random.nextDouble() * 1.8 + 0.8,
      ),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
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
        return CustomPaint(
          painter: _ParticlePainter(_particles, _controller.value),
          child: widget.child,
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.particles, this.progress);

  final List<_Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.6);
    for (final particle in particles) {
      final offset = Offset(
        (particle.position.dx + particle.speed.dx * progress * 60) % 1.0,
        (particle.position.dy + particle.speed.dy * progress * 60) % 1.0,
      );
      final position = Offset(offset.dx * size.width, offset.dy * size.height);
      canvas.drawCircle(position, particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _Particle {
  _Particle({
    required this.position,
    required this.speed,
    required this.radius,
  });

  final Offset position;
  final Offset speed;
  final double radius;
}
