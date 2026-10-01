import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../flame/games/transaction_celebration_game.dart';

class FlameCelebrationDialog extends StatelessWidget {
  final String title;
  final int amountCents;
  final String subtitle;
  final bool isDeposit;

  const FlameCelebrationDialog({
    super.key,
    required this.title,
    required this.amountCents,
    required this.subtitle,
    this.isDeposit = true,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required int amountCents,
    required String subtitle,
    bool isDeposit = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => FlameCelebrationDialog(
        title: title,
        amountCents: amountCents,
        subtitle: subtitle,
        isDeposit: isDeposit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Embedded Flame Physics Particle Canvas
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: GameWidget(
                game: TransactionCelebrationGame(
                  initialCoinCount: 35,
                  isDeposit: isDeposit,
                ),
              ),
            ),
          ),

          // Foreground Card Content
          Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0F2027).withValues(alpha: 0.92),
                  const Color(0xFF203A43).withValues(alpha: 0.95),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDeposit ? AppColors.anthosEmerald : AppColors.anthosCyan,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDeposit ? AppColors.anthosEmerald : AppColors.anthosCyan).withValues(alpha: 0.3),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isDeposit ? AppColors.anthosEmerald : AppColors.anthosCyan).withValues(alpha: 0.2),
                    border: Border.all(
                      color: isDeposit ? AppColors.anthosEmerald : AppColors.anthosCyan,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isDeposit ? Icons.check_circle_outline : Icons.send_rounded,
                    color: isDeposit ? AppColors.anthosEmerald : AppColors.anthosCyan,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    CurrencyFormatter.formatCents(amountCents),
                    style: TextStyle(
                      color: isDeposit ? AppColors.anthosEmerald : Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDeposit ? AppColors.anthosEmerald : AppColors.anthosCyan,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
