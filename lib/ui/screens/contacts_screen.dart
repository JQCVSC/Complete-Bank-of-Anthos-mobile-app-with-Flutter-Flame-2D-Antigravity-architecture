import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/banking_provider.dart';
import '../widgets/contact_avatar.dart';
import '../widgets/custom_text_field.dart';
import 'transfer_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddContactDialog() {
    final labelCtrl = TextEditingController();
    final acctCtrl = TextEditingController();
    final routingCtrl = TextEditingController(text: '123456789');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add New Payee Contact',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: labelCtrl,
                label: 'Contact Name / Entity',
                hint: 'e.g. Acme Corporation, Alice Johnson',
                prefixIcon: Icons.person_outline,
                validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: acctCtrl,
                label: 'Account Number',
                hint: '10-digit account ID',
                prefixIcon: Icons.credit_card,
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.trim().length < 8 ? 'Valid account number required' : null,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: routingCtrl,
                label: 'Routing Number',
                hint: '123456789',
                prefixIcon: Icons.route,
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.trim().length != 9 ? '9-digit routing number required' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final auth = context.read<AuthProvider>();
                  final banking = context.read<BankingProvider>();
                  final user = auth.currentUser;
                  if (user == null) return;

                  final success = await banking.addContact(
                    username: user.username,
                    label: labelCtrl.text.trim(),
                    accountNum: acctCtrl.text.trim(),
                    routingNum: routingCtrl.text.trim(),
                  );

                  if (success && ctx.mounted) {
                    Navigator.of(ctx).pop();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Contact added successfully!')),
                    );
                  }
                },
                child: const Text('Save Contact'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final banking = context.watch<BankingProvider>();

    final filteredContacts = banking.contacts.where((c) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return c.label.toLowerCase().contains(q) || c.accountNum.contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payees & Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            tooltip: 'Add Contact',
            onPressed: _showAddContactDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
              decoration: InputDecoration(
                hintText: 'Search contacts by name or account...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: filteredContacts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.contacts_outlined,
                          size: 54,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          banking.contacts.isEmpty ? 'No contacts saved yet' : 'No contacts matching search',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _showAddContactDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Add First Contact'),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredContacts.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      indent: 64,
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                    itemBuilder: (ctx, i) {
                      final contact = filteredContacts[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        leading: ContactAvatar(contact: contact, size: 46),
                        title: Row(
                          children: [
                            Flexible(
                              child: Text(
                                contact.label,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (contact.isExternal) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.anthosBlue.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'EXTERNAL',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.anthosBlue,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          'Acct: ${contact.accountNum} • RT: ${contact.routingNum}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        trailing: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(80, 36),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TransferScreen(initialContact: contact),
                              ),
                            );
                          },
                          icon: const Icon(Icons.send, size: 14),
                          label: const Text('Pay', style: TextStyle(fontSize: 12)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddContactDialog,
        backgroundColor: isDark ? AppColors.anthosCyan : AppColors.primary,
        foregroundColor: isDark ? Colors.black : Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Contact', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
