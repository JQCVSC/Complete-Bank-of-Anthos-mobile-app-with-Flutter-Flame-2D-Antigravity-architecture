import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../flame/games/anthos_quest_game.dart';
import '../../providers/auth_provider.dart';
import '../../providers/banking_provider.dart';

class VaultQuestScreen extends StatefulWidget {
  const VaultQuestScreen({super.key});

  @override
  State<VaultQuestScreen> createState() => _VaultQuestScreenState();
}

class _VaultQuestScreenState extends State<VaultQuestScreen> {
  late AnthosQuestGame _game;
  bool _isFinished = false;
  int _earnedCents = 0;
  int _finalScore = 0;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      _isFinished = false;
      _earnedCents = 0;
      _finalScore = 0;
    });

    _game = AnthosQuestGame(
      onGameOver: (earned, score) {
        if (!mounted) return;
        setState(() {
          _isFinished = true;
          _earnedCents = earned;
          _finalScore = score;
        });
      },
    );
  }

  Future<void> _claimReward() async {
    final auth = context.read<AuthProvider>();
    final banking = context.read<BankingProvider>();
    final user = auth.currentUser;

    if (user != null && _earnedCents > 0) {
      await banking.deposit(
        accountId: user.accountId,
        amountCents: _earnedCents,
        username: user.username,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.anthosEmerald,
          content: Text('🎉 Claimed ${CurrencyFormatter.formatCents(_earnedCents)} deposit bonus!'),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1118),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2027),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.sports_esports, color: AppColors.anthosCyan, size: 20),
            SizedBox(width: 8),
            Text(
              'Anthos Vault Quest',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _startNewGame,
            tooltip: 'Restart Round',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Embedded 2D Flame Game
          Positioned.fill(
            child: GameWidget(
              game: _game,
            ),
          ),

          // Instructions banner at bottom
          if (!_isFinished)
            Positioned(
              bottom: 16,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: const Text(
                  '👈 Drag or Tap paddle to catch Coins & Cloud Nodes! Dodge Red Fees! 👉',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
                ),
              ),
            ),

          // Game Over / Victory Modal Overlay
          if (_isFinished)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.82),
                padding: const EdgeInsets.all(28),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.cardGradient,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.anthosCyan.withValues(alpha: 0.4), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.anthosCyan.withValues(alpha: 0.25),
                          blurRadius: 30,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.accentGradient,
                          ),
                          child: const Icon(Icons.emoji_events, color: Colors.white, size: 32),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Round Completed!',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Final Score: $_finalScore points',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.anthosEmerald.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'TOTAL CASH BONUS EARNED',
                                style: TextStyle(
                                  color: AppColors.anthosEmerald,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                CurrencyFormatter.formatCents(_earnedCents),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.anthosEmerald,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          onPressed: _claimReward,
                          icon: const Icon(Icons.account_balance_wallet),
                          label: const Text('Claim & Deposit into Account', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          onPressed: _startNewGame,
                          child: const Text('Play Again'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
