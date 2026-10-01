import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../flame/games/vault_mesh_game.dart';

class FlameVaultMeshWidget extends StatefulWidget {
  final double height;

  const FlameVaultMeshWidget({
    super.key,
    this.height = 240.0,
  });

  @override
  State<FlameVaultMeshWidget> createState() => _FlameVaultMeshWidgetState();
}

class _FlameVaultMeshWidgetState extends State<FlameVaultMeshWidget> {
  late VaultMeshGame _game;

  @override
  void initState() {
    super.initState();
    _game = VaultMeshGame();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFF0C141F),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.anthosCyan.withValues(alpha: 0.25), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Live Flame Game canvas
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: GameWidget(
              game: _game,
            ),
          ),

          // Top Header Overlay
          Positioned(
            top: 12,
            left: 14,
            right: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.anthosCyan,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Anthos Service Mesh Live',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Interactive • Tap Nodes',
                    style: TextStyle(
                      color: AppColors.anthosCyan,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
