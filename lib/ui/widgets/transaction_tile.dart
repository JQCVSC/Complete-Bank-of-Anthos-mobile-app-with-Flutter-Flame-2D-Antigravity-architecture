import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final BankTransaction transaction;
  final String currentAccountId;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.currentAccountId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isInflow = transaction.isInflow(currentAccountId);

    final amountColor = isInflow
        ? (isDark ? AppColors.anthosCyan : AppColors.anthosEmerald)
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return InkWell(
      onTap: () => _showTransactionDetail(context, isDark, isInflow),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isInflow
                    ? AppColors.anthosEmerald.withValues(alpha: 0.12)
                    : (isDark ? AppColors.surfaceVariantDark : AppColors.primary.withValues(alpha: 0.08)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isInflow ? Icons.arrow_downward : Icons.arrow_upward,
                color: isInflow
                    ? AppColors.anthosEmerald
                    : (isDark ? AppColors.anthosCyan : AppColors.primary),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.displayTitle(currentAccountId),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    DateFormatter.formatRelativeOrDate(transaction.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              transaction.formattedAmount(currentAccountId: currentAccountId),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetail(BuildContext context, bool isDark, bool isInflow) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isInflow
                    ? AppColors.anthosEmerald.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isInflow ? Icons.arrow_downward : Icons.arrow_upward,
                color: isInflow ? AppColors.anthosEmerald : AppColors.anthosBlue,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              transaction.formattedAmount(currentAccountId: currentAccountId),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isInflow ? AppColors.anthosEmerald : (isDark ? Colors.white : AppColors.primary),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              transaction.displayTitle(currentAccountId),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            _buildDetailRow('Status', 'Completed', isDark, isStatus: true),
            _buildDetailRow('Date & Time', DateFormatter.formatDateTime(transaction.timestamp), isDark),
            _buildDetailRow('From Account', transaction.fromAccountNum.isEmpty ? 'External Cash/Check' : transaction.fromAccountNum, isDark),
            _buildDetailRow('To Account', transaction.toAccountNum, isDark),
            _buildDetailRow('Routing Number', transaction.toRoutingNum, isDark),
            _buildDetailRow(
              'Transaction ID',
              transaction.id,
              isDark,
              onCopy: () {
                Clipboard.setData(ClipboardData(text: transaction.id));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transaction ID copied!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark, {bool isStatus = false, VoidCallback? onCopy}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          Row(
            children: [
              if (isStatus)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.anthosEmerald,
                    shape: BoxShape.circle,
                  ),
                ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isStatus
                      ? AppColors.anthosEmerald
                      : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                ),
              ),
              if (onCopy != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.copy, size: 14),
                  onPressed: onCopy,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
