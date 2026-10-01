import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../components/coin_particle.dart';

class TransactionCelebrationGame extends FlameGame with TapCallbacks implements ComponentWithBounds {
  final int initialCoinCount;
  final bool isDeposit;
  final Random _rnd = Random();

  TransactionCelebrationGame({
    this.initialCoinCount = 45,
    this.isDeposit = true,
  });

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Rect get bounds => Rect.fromLTWH(0, 0, size.x, size.y);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _spawnCelebrationBurst(Vector2(size.x / 2, size.y * 0.75), initialCoinCount);
  }

  void _spawnCelebrationBurst(Vector2 origin, int count) {
    for (int i = 0; i < count; i++) {
      // Angle spread upwards in an arc (-160 to -20 degrees)
      final angle = (-160 + _rnd.nextDouble() * 140) * (pi / 180);
      final speed = 350.0 + _rnd.nextDouble() * 500.0;
      final velocity = Vector2(cos(angle) * speed, sin(angle) * speed);

      final isGold = _rnd.nextBool();
      final color = isDeposit
          ? (isGold ? const Color(0xFFFFD700) : const Color(0xFF00E676))
          : (isGold ? const Color(0xFFFFD700) : const Color(0xFF00E5FF));

      final coin = CoinParticle(
        position: origin.clone(),
        velocity: velocity,
        radius: 12.0 + _rnd.nextDouble() * 8.0,
        color: color,
        label: isDeposit ? '+' : '\$',
        maxLifeTime: 2.8 + _rnd.nextDouble() * 1.5,
        rotationSpeed: (-6.0 + _rnd.nextDouble() * 12.0),
      );
      add(coin);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    _spawnCelebrationBurst(event.localPosition, 20);
  }
}
