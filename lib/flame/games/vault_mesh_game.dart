import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class ServiceNode {
  final String id;
  final String label;
  final Color color;
  Vector2 basePosition;
  Vector2 position;
  double phase;
  double radius;
  double glowIntensity;

  ServiceNode({
    required this.id,
    required this.label,
    required this.color,
    required this.basePosition,
    this.phase = 0.0,
    this.radius = 24.0,
    this.glowIntensity = 1.0,
  }) : position = basePosition.clone();
}

class DataPacket {
  final ServiceNode from;
  final ServiceNode to;
  double progress;
  final double speed;
  final Color color;

  DataPacket({
    required this.from,
    required this.to,
    this.progress = 0.0,
    this.speed = 1.2,
    this.color = const Color(0xFF00E5FF),
  });
}

class PulseShockwave {
  Vector2 center;
  double radius;
  double maxRadius;
  double lifeTime;
  double maxLifeTime;
  Color color;

  PulseShockwave({
    required this.center,
    this.radius = 0.0,
    this.maxRadius = 140.0,
    this.maxLifeTime = 1.2,
    this.color = const Color(0xFF00E5FF),
  }) : lifeTime = 0.0;
}

class VaultMeshGame extends FlameGame with TapCallbacks, DragCallbacks {
  final List<ServiceNode> nodes = [];
  final List<DataPacket> packets = [];
  final List<PulseShockwave> shockwaves = [];
  final Random _rnd = Random();

  double _time = 0.0;
  double _packetSpawnTimer = 0.0;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initNodes();
  }

  void _initNodes() {
    nodes.clear();
    final cx = size.x / 2;
    final cy = size.y / 2;

    // Center Core: Anthos Vault
    nodes.add(
      ServiceNode(
        id: 'vault',
        label: 'Vault Core',
        color: const Color(0xFFFFD700),
        basePosition: Vector2(cx, cy),
        radius: 28.0,
      ),
    );

    // Surrounding microservice nodes in a ring
    final microservices = [
      {'id': 'frontend', 'name': 'Frontend', 'color': const Color(0xFF00E5FF)},
      {'id': 'ledger', 'name': 'LedgerWriter', 'color': const Color(0xFF00E676)},
      {'id': 'balance', 'name': 'BalanceReader', 'color': const Color(0xFF7C4DFF)},
      {'id': 'users', 'name': 'UserService', 'color': const Color(0xFFFF4081)},
      {'id': 'contacts', 'name': 'Contacts', 'color': const Color(0xFFFFAB00)},
    ];

    final ringRadius = min(size.x, size.y) * 0.36;
    for (int i = 0; i < microservices.length; i++) {
      final angle = (i / microservices.length) * 2 * pi - pi / 2;
      final px = cx + cos(angle) * ringRadius;
      final py = cy + sin(angle) * ringRadius;

      nodes.add(
        ServiceNode(
          id: microservices[i]['id'] as String,
          label: microservices[i]['name'] as String,
          color: microservices[i]['color'] as Color,
          basePosition: Vector2(px, py),
          phase: i * 1.3,
          radius: 20.0,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;

    if (nodes.isEmpty) return;

    // Harmonic floating drift for nodes
    for (final node in nodes) {
      if (node.id != 'vault') {
        final offsetX = sin(_time * 1.5 + node.phase) * 6.0;
        final offsetY = cos(_time * 1.2 + node.phase) * 6.0;
        node.position = node.basePosition + Vector2(offsetX, offsetY);
      }
      node.glowIntensity = 0.8 + 0.3 * sin(_time * 3.0 + node.phase);
    }

    // Spawn packets between vault and microservices
    _packetSpawnTimer += dt;
    if (_packetSpawnTimer >= 0.35) {
      _packetSpawnTimer = 0.0;
      final vault = nodes[0];
      final target = nodes[1 + _rnd.nextInt(nodes.length - 1)];

      final outbound = _rnd.nextBool();
      packets.add(
        DataPacket(
          from: outbound ? vault : target,
          to: outbound ? target : vault,
          speed: 0.8 + _rnd.nextDouble() * 0.8,
          color: target.color,
        ),
      );
    }

    // Update packets
    for (int i = packets.length - 1; i >= 0; i--) {
      packets[i].progress += dt * packets[i].speed;
      if (packets[i].progress >= 1.0) {
        packets.removeAt(i);
      }
    }

    // Update shockwaves
    for (int i = shockwaves.length - 1; i >= 0; i--) {
      final sw = shockwaves[i];
      sw.lifeTime += dt;
      sw.radius = (sw.lifeTime / sw.maxLifeTime) * sw.maxRadius;
      if (sw.lifeTime >= sw.maxLifeTime) {
        shockwaves.removeAt(i);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (nodes.isEmpty) return;

    final vault = nodes[0];

    // 1. Draw connection lines from vault to each microservice
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 1; i < nodes.length; i++) {
      canvas.drawLine(
        Offset(vault.position.x, vault.position.y),
        Offset(nodes[i].position.x, nodes[i].position.y),
        linePaint,
      );
    }

    // 2. Draw shockwaves
    for (final sw in shockwaves) {
      final opacity = (1.0 - (sw.lifeTime / sw.maxLifeTime)).clamp(0.0, 1.0);
      final swPaint = Paint()
        ..color = sw.color.withValues(alpha: opacity * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(Offset(sw.center.x, sw.center.y), sw.radius, swPaint);
    }

    // 3. Draw moving data packets
    for (final pkt in packets) {
      final p1 = Offset(pkt.from.position.x, pkt.from.position.y);
      final p2 = Offset(pkt.to.position.x, pkt.to.position.y);
      final currX = p1.dx + (p2.dx - p1.dx) * pkt.progress;
      final currY = p1.dy + (p2.dy - p1.dy) * pkt.progress;

      final pktPaint = Paint()
        ..color = pkt.color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(Offset(currX, currY), 4.5, pktPaint);

      final corePaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(currX, currY), 2.5, corePaint);
    }

    // 4. Draw nodes
    for (final node in nodes) {
      final center = Offset(node.position.x, node.position.y);

      // Outer glow
      final glowPaint = Paint()
        ..color = node.color.withValues(alpha: 0.35 * node.glowIntensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(center, node.radius + 6, glowPaint);

      // Main circle
      final circlePaint = Paint()
        ..shader = RadialGradient(
          colors: [
            node.color.withValues(alpha: 0.9),
            node.color.withValues(alpha: 0.5),
            const Color(0xFF0F2027),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: node.radius));
      canvas.drawCircle(center, node.radius, circlePaint);

      // Border rim
      final rimPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(center, node.radius, rimPaint);

      // Label below node
      final textSpan = TextSpan(
        text: node.label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(color: Colors.black, blurRadius: 4),
          ],
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(center.dx - textPainter.width / 2, center.dy + node.radius + 4),
      );
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    _triggerPulse(event.localPosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    _triggerPulse(event.localStartPosition);
  }

  void _triggerPulse(Vector2 pos) {
    shockwaves.add(
      PulseShockwave(
        center: pos.clone(),
        maxRadius: 160.0,
        color: const Color(0xFF00E5FF),
      ),
    );

    // Burst fast packets from vault
    if (nodes.isNotEmpty) {
      final vault = nodes[0];
      for (int i = 1; i < nodes.length; i++) {
        packets.add(
          DataPacket(
            from: vault,
            to: nodes[i],
            speed: 2.2,
            color: nodes[i].color,
          ),
        );
      }
    }
  }
}
