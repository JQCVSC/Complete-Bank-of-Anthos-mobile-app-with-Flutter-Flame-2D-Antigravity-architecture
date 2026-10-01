import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

enum ItemType {
  coin,
  dividend,
  anthosCloud,
  feeHazard,
}

class FallingItem {
  Vector2 position;
  final double speed;
  final ItemType type;
  final double radius;
  double angle;
  final double rotationSpeed;

  FallingItem({
    required this.position,
    required this.speed,
    required this.type,
    this.radius = 18.0,
    this.angle = 0.0,
    this.rotationSpeed = 2.0,
  });

  int get valuePoints {
    switch (type) {
      case ItemType.coin:
        return 50;
      case ItemType.dividend:
        return 100;
      case ItemType.anthosCloud:
        return 250;
      case ItemType.feeHazard:
        return -50;
    }
  }

  int get cashRewardCents {
    switch (type) {
      case ItemType.coin:
        return 5000; // $50.00
      case ItemType.dividend:
        return 10000; // $100.00
      case ItemType.anthosCloud:
        return 25000; // $250.00
      case ItemType.feeHazard:
        return 0;
    }
  }
}

class SparkEffect {
  Vector2 position;
  Vector2 velocity;
  Color color;
  double lifeTime;
  double maxLifeTime;

  SparkEffect({
    required this.position,
    required this.velocity,
    required this.color,
    this.maxLifeTime = 0.6,
  }) : lifeTime = 0.0;
}

class AnthosQuestGame extends FlameGame with DragCallbacks, TapCallbacks {
  final void Function(int totalEarnedCents, int score)? onGameOver;

  AnthosQuestGame({this.onGameOver});

  final Random _rnd = Random();
  final List<FallingItem> items = [];
  final List<SparkEffect> sparks = [];

  // Player Vault Paddle
  late Vector2 playerPos;
  final double playerWidth = 84.0;
  final double playerHeight = 22.0;

  int score = 0;
  int lives = 3;
  int totalEarnedCents = 0;
  int combo = 1;
  double gameTimeLeft = 35.0; // 35 second round
  bool isGameOver = false;

  double _spawnTimer = 0.0;

  @override
  Color backgroundColor() => const Color(0xFF0A1118);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    playerPos = Vector2(size.x / 2, size.y - 65.0);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    gameTimeLeft -= dt;
    if (gameTimeLeft <= 0) {
      _endGame();
      return;
    }

    // Spawn falling items
    _spawnTimer += dt;
    if (_spawnTimer >= 0.55) {
      _spawnTimer = 0.0;
      _spawnItem();
    }

    // Update items
    final playerRect = Rect.fromCenter(
      center: Offset(playerPos.x, playerPos.y),
      width: playerWidth,
      height: playerHeight,
    );

    for (int i = items.length - 1; i >= 0; i--) {
      final item = items[i];
      item.position.y += item.speed * dt;
      item.angle += item.rotationSpeed * dt;

      // Check collision with player paddle
      final itemRect = Rect.fromCircle(
        center: Offset(item.position.x, item.position.y),
        radius: item.radius,
      );

      if (playerRect.overlaps(itemRect)) {
        _collectItem(item);
        items.removeAt(i);
        continue;
      }

      // Fallen below screen
      if (item.position.y > size.y + 30) {
        items.removeAt(i);
      }
    }

    // Update sparks
    for (int i = sparks.length - 1; i >= 0; i--) {
      final s = sparks[i];
      s.lifeTime += dt;
      s.position += s.velocity * dt;
      if (s.lifeTime >= s.maxLifeTime) {
        sparks.removeAt(i);
      }
    }
  }

  void _spawnItem() {
    final x = 30.0 + _rnd.nextDouble() * (size.x - 60.0);
    final roll = _rnd.nextDouble();

    ItemType type;
    if (roll < 0.45) {
      type = ItemType.coin;
    } else if (roll < 0.70) {
      type = ItemType.dividend;
    } else if (roll < 0.85) {
      type = ItemType.anthosCloud;
    } else {
      type = ItemType.feeHazard;
    }

    final speed = 180.0 + _rnd.nextDouble() * 150.0;
    items.add(
      FallingItem(
        position: Vector2(x, -20.0),
        speed: speed,
        type: type,
        rotationSpeed: (-4.0 + _rnd.nextDouble() * 8.0),
      ),
    );
  }

  void _collectItem(FallingItem item) {
    Color burstColor;
    if (item.type == ItemType.feeHazard) {
      lives--;
      combo = 1;
      burstColor = const Color(0xFFEA4335);
      if (lives <= 0) {
        _endGame();
      }
    } else {
      burstColor = item.type == ItemType.coin
          ? const Color(0xFFFFD700)
          : (item.type == ItemType.dividend ? const Color(0xFF00E5FF) : const Color(0xFF00E676));

      score += item.valuePoints * combo;
      totalEarnedCents += item.cashRewardCents;
      combo = min(combo + 1, 5);
    }

    // Spawn sparks
    for (int i = 0; i < 16; i++) {
      final angle = _rnd.nextDouble() * 2 * pi;
      final spd = 60.0 + _rnd.nextDouble() * 180.0;
      sparks.add(
        SparkEffect(
          position: item.position.clone(),
          velocity: Vector2(cos(angle) * spd, sin(angle) * spd),
          color: burstColor,
        ),
      );
    }
  }

  void _endGame() {
    isGameOver = true;
    if (onGameOver != null) {
      onGameOver!(totalEarnedCents, score);
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (isGameOver) return;
    playerPos.x += event.localDelta.x;
    playerPos.x = playerPos.x.clamp(playerWidth / 2, size.x - playerWidth / 2);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (isGameOver) return;
    playerPos.x = event.localPosition.x.clamp(playerWidth / 2, size.x - playerWidth / 2);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 1. Draw Player Vault Collector
    final playerRect = Rect.fromCenter(
      center: Offset(playerPos.x, playerPos.y),
      width: playerWidth,
      height: playerHeight,
    );

    // Vault glow
    final glowPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawRRect(RRect.fromRectAndRadius(playerRect, const Radius.circular(12)), glowPaint);

    // Vault body gradient
    final paddlePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00E5FF), Color(0xFF1A73E8), Color(0xFF00C49F)],
      ).createShader(playerRect);
    canvas.drawRRect(RRect.fromRectAndRadius(playerRect, const Radius.circular(12)), paddlePaint);

    final paddleBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(RRect.fromRectAndRadius(playerRect, const Radius.circular(12)), paddleBorder);

    // 2. Draw Falling Items
    for (final item in items) {
      final center = Offset(item.position.x, item.position.y);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(item.angle);

      if (item.type == ItemType.feeHazard) {
        // Red fee hazard triangle
        final p = Path()
          ..moveTo(0, -item.radius)
          ..lineTo(item.radius, item.radius)
          ..lineTo(-item.radius, item.radius)
          ..close();
        final hazPaint = Paint()..color = const Color(0xFFEA4335);
        canvas.drawPath(p, hazPaint);
        final hazBorder = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawPath(p, hazBorder);
      } else {
        // Circle item
        Color baseColor = const Color(0xFFFFD700);
        String sym = '\$';
        if (item.type == ItemType.dividend) {
          baseColor = const Color(0xFF00E5FF);
          sym = '✦';
        } else if (item.type == ItemType.anthosCloud) {
          baseColor = const Color(0xFF00E676);
          sym = '☁';
        }

        final itemPaint = Paint()..color = baseColor;
        canvas.drawCircle(Offset.zero, item.radius, itemPaint);
        final rim = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8;
        canvas.drawCircle(Offset.zero, item.radius, rim);

        final textSpan = TextSpan(
          text: sym,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        );
        final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
        tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      }
      canvas.restore();
    }

    // 3. Draw Sparks
    for (final s in sparks) {
      final alpha = (1.0 - (s.lifeTime / s.maxLifeTime)).clamp(0.0, 1.0);
      final spPaint = Paint()..color = s.color.withValues(alpha: alpha);
      canvas.drawCircle(Offset(s.position.x, s.position.y), 3.0, spPaint);
    }

    // 4. Render HUD Overlay
    _renderHUD(canvas);
  }

  void _renderHUD(Canvas canvas) {
    // Top Bar Background
    final hudRect = Rect.fromLTWH(0, 0, size.x, 50);
    final hudPaint = Paint()..color = const Color(0xFF0F2027).withValues(alpha: 0.85);
    canvas.drawRect(hudRect, hudPaint);

    // Score & Multiplier
    final scoreSpan = TextSpan(
      text: 'Score: $score (${combo}x)',
      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
    );
    final tp1 = TextPainter(text: scoreSpan, textDirection: TextDirection.ltr)..layout();
    tp1.paint(canvas, const Offset(16, 16));

    // Time Remaining
    final timeSpan = TextSpan(
      text: 'Time: ${max(0, gameTimeLeft.ceil())}s',
      style: TextStyle(
        color: gameTimeLeft < 10 ? const Color(0xFFFF5252) : const Color(0xFF00E5FF),
        fontSize: 13,
        fontWeight: FontWeight.bold,
      ),
    );
    final tp2 = TextPainter(text: timeSpan, textDirection: TextDirection.ltr)..layout();
    tp2.paint(canvas, Offset(size.x / 2 - tp2.width / 2, 16));

    // Lives
    final livesSpan = TextSpan(
      text: '❤️ ' * lives,
      style: const TextStyle(fontSize: 13),
    );
    final tp3 = TextPainter(text: livesSpan, textDirection: TextDirection.ltr)..layout();
    tp3.paint(canvas, Offset(size.x - tp3.width - 16, 16));
  }
}
