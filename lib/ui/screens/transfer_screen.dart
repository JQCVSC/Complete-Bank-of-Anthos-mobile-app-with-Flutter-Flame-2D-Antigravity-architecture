import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/contact.dart';
import '../../providers/auth_provider.dart';
import '../../providers/banking_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/contact_avatar.dart';
import '../widgets/flame_celebration_dialog.dart';

class TransferScreen extends StatefulWidget {
  final Contact? initialContact;

  const TransferScreen({super.key, this.initialContact});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientAccountController = TextEditingController();
  final _routingController = TextEditingController(text: '123456789');
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();

  Contact? _selectedContact;

  @override
  void initState() {
    super.initState();
    if (widget.initialContact != null) {
      _selectContact(widget.initialContact!);
    }
  }

  void _selectContact(Contact contact) {
    setState(() {
      _selectedContact = contact;
      _recipientAccountController.text = contact.accountNum;
      _routingController.text = contact.routingNum;
      _memoController.text = 'Payment to ${contact.label}';
    });
  }

  void _clearSelectedContact() {
    setState(() {
      _selectedContact = null;
      _recipientAccountController.clear();
      _routingController.text = '123456789';
      _memoController.clear();
    });
  }

  @override
  void dispose() {
    _recipientAccountController.dispose();
    _routingController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _handleTransfer() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final banking = context.read<BankingProvider>();
    final user = auth.currentUser;

    if (user == null) return;

    final cents = CurrencyFormatter.parseDollarsToCents(_amountController.text);
    if (cents <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount greater than \$0.00')),
      );
      return;
    }

    final success = await banking.sendPayment(
      fromAccountId: user.accountId,
      toAccountId: _recipientAccountController.text.trim(),
      amountCents: cents,
      accountLabel: _memoController.text.trim().isNotEmpty
          ? _memoController.text.trim()
          : (_selectedContact != null ? 'Payment to ${_selectedContact!.label}' : 'Payment transfer'),
      username: user.username,
    );

    if (success && mounted) {
      await FlameCelebrationDialog.show(
        context,
        title: 'Transfer Sent!',
        amountCents: cents,
        subtitle: 'Sent to Account ${_recipientAccountController.text.trim()}',
        isDeposit: false,
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
        title: const Text('Send Money'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Quick contacts row
                if (banking.contacts.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select from Contacts',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      if (_selectedContact != null)
                        TextButton(
                          onPressed: _clearSelectedContact,
                          child: const Text('Custom account', style: TextStyle(fontSize: 12)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 86,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: banking.contacts.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 14),
                      itemBuilder: (ctx, i) {
                        final contact = banking.contacts[i];
                        final isSelected = _selectedContact?.accountNum == contact.accountNum;
                        return Column(
                          children: [
                            Stack(
                              children: [
                                ContactAvatar(
                                  contact: contact,
                                  size: 48,
                                  onTap: () => _selectContact(contact),
                                ),
                                if (isSelected)
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: AppColors.anthosEmerald,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.check, size: 12, color: Colors.white),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: 68,
                              child: Text(
                                contact.label,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? AppColors.anthosBlue : null,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const Divider(height: 24),
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

                // Recipient Account
                CustomTextField(
                  controller: _recipientAccountController,
                  label: 'Recipient Account Number',
                  hint: '10-digit account ID (e.g. 3948201948)',
                  prefixIcon: Icons.account_balance,
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.trim().length < 8 ? 'Valid account number required' : null,
                ),
                const SizedBox(height: 16),

                // Routing Number
                CustomTextField(
                  controller: _routingController,
                  label: 'Bank Routing Number',
                  hint: '123456789',
                  prefixIcon: Icons.route_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.trim().length != 9 ? '9-digit routing number required' : null,
                ),
                const SizedBox(height: 16),

                // Amount
                CustomTextField(
                  controller: _amountController,
                  label: 'Amount (USD)',
                  hint: '0.00',
                  prefixIcon: Icons.attach_money,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter amount';
                    final cents = CurrencyFormatter.parseDollarsToCents(v);
                    if (cents <= 0) return 'Amount must be greater than 0';
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Quick amount chips
                Wrap(
                  spacing: 8,
                  children: [25, 50, 100, 250, 500].map((amt) {
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
                const SizedBox(height: 16),

                // Memo / Note
                CustomTextField(
                  controller: _memoController,
                  label: 'Note / Memo (Optional)',
                  hint: 'e.g. Rent, Utilities, Dinner',
                  prefixIcon: Icons.edit_note,
                ),
                const SizedBox(height: 28),

                // Available balance preview
                if (banking.balance != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Available to send:',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        Text(
                          banking.balance!.formatted,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                ElevatedButton(
                  onPressed: banking.isProcessingAction ? null : _handleTransfer,
                  child: banking.isProcessingAction
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Confirm & Send Payment'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
