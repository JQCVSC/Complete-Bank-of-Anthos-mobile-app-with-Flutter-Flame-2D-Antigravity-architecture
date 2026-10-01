import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/banking_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/flame_celebration_dialog.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  int _selectedMethod = 0; // 0 = Instant Transfer, 1 = Check Deposit

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleDeposit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final banking = context.read<BankingProvider>();
    final user = auth.currentUser;

    if (user == null) return;

    final cents = CurrencyFormatter.parseDollarsToCents(_amountController.text);
    if (cents <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount greater than \$0.00')),
      );
      return;
    }

    final success = await banking.deposit(
      accountId: user.accountId,
      amountCents: cents,
      username: user.username,
    );

    if (success && mounted) {
      await FlameCelebrationDialog.show(
        context,
        title: 'Deposit Successful!',
        amountCents: cents,
        subtitle: 'Funds added to Account ${user.accountId}',
        isDeposit: true,
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final banking = context.watch<BankingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit Funds'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Select Deposit Method',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildMethodCard(
                        index: 0,
                        title: 'Instant Deposit',
                        subtitle: 'Direct wire / transfer',
                        icon: Icons.flash_on,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMethodCard(
                        index: 1,
                        title: 'Mobile Check',
                        subtitle: 'Photo deposit',
                        icon: Icons.camera_alt_outlined,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (_selectedMethod == 1) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.document_scanner_outlined,
                          size: 40,
                          color: isDark ? AppColors.anthosCyan : AppColors.primary,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Front & Back Check Photos Captured',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Simulated check verification enabled',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                if (banking.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.anthosRed.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      banking.errorMessage!,
                      style: const TextStyle(color: AppColors.anthosRed, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                CustomTextField(
                  controller: _amountController,
                  label: 'Deposit Amount (USD)',
                  hint: '0.00',
                  prefixIcon: Icons.attach_money,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter deposit amount';
                    final cents = CurrencyFormatter.parseDollarsToCents(v);
                    if (cents <= 0) return 'Amount must be greater than 0';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  children: [100, 250, 500, 1000, 2500].map((amt) {
                    return ActionChip(
                      label: Text('\$$amt'),
                      onPressed: () {
                        setState(() {
                          _amountController.text = amt.toString();
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: banking.isProcessingAction ? null : _handleDeposit,
                  child: banking.isProcessingAction
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Confirm Deposit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodCard({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _selectedMethod == index;
    final color = isSelected ? AppColors.anthosBlue : (isDark ? AppColors.borderDark : AppColors.borderLight);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethod = index;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.anthosBlue.withValues(alpha: 0.08)
              : (isDark ? AppColors.surfaceVariantDark : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.anthosBlue : (isDark ? Colors.white70 : AppColors.primary),
              size: 26,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.anthosBlue : null,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
