import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class CoinParticle extends PositionComponent {
  final Vector2 velocity;
  final double gravity;
  final double restitution;
  final double radius;
  final Color color;
  final String label;

  double rotationSpeed;
  double lifeTime;
  double maxLifeTime;

  CoinParticle({
    required Vector2 position,
    required this.velocity,
    this.gravity = 980.0,
    this.restitution = 0.65,
    this.radius = 16.0,
    this.color = const Color(0xFFFFD700),
    this.label = '\$',
    this.maxLifeTime = 3.5,
    this.rotationSpeed = 4.0,
  })  : lifeTime = 0.0,
        super(position: position, size: Vector2.all(radius * 2), anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    lifeTime += dt;

    if (lifeTime >= maxLifeTime) {
      removeFromParent();
      return;
    }

    // Apply gravity
    velocity.y += gravity * dt;

    // Apply velocity
    position += velocity * dt;

    // Rotate
    angle += rotationSpeed * dt;

    // Bounce on ground if parent size is known
    final parentHeight = findParent<ComponentWithBounds>()?.bounds.height ?? 600.0;
    if (position.y + radius >= parentHeight) {
      position.y = parentHeight - radius;
      velocity.y = -velocity.y * restitution;
      velocity.x *= 0.85; // friction
      rotationSpeed *= 0.8;
    }
  }

  @override
  void render(Canvas canvas) {
    final opacity = (1.0 - (lifeTime / maxLifeTime)).clamp(0.0, 1.0);

    // Glow effect
    final glowPaint = Paint()
      ..color = color.withValues(alpha: opacity * 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(radius, radius), radius + 2, glowPaint);

    // Coin base circle
    final coinPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFF4B8).withValues(alpha: opacity),
          color.withValues(alpha: opacity),
          const Color(0xFFC79200).withValues(alpha: opacity),
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(radius, radius), radius: radius));

    canvas.drawCircle(Offset(radius, radius), radius, coinPaint);

    // Inner rim
    final rimPaint = Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(radius, radius), radius - 3, rimPaint);

    // Text symbol
    final textSpan = TextSpan(
      text: label,
      style: TextStyle(
        color: const Color(0xFF6B4700).withValues(alpha: opacity),
        fontSize: radius * 1.1,
        fontWeight: FontWeight.w900,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(radius - textPainter.width / 2, radius - textPainter.height / 2),
    );
  }
}

abstract class ComponentWithBounds extends Component {
  Rect get bounds;
}
