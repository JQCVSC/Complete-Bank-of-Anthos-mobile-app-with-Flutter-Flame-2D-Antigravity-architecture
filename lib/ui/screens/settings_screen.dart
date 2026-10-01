import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/banking_provider.dart';
import '../widgets/custom_text_field.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _urlController = TextEditingController(text: settings.baseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<SettingsProvider>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Cloud Config'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Profile card
          if (user != null) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      gradient: AppColors.accentGradient,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@${user.username} • ${user.email}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Acct: ${user.accountId} | Routing: ${user.routingNumber}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            color: AppColors.anthosBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Cluster Connection Configuration
          _buildSectionHeader('ANTHOS BACKEND & CLUSTER CONFIG'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceVariantDark : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Sandbox Demo Mode',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Runs offline with realistic in-memory ledger and pre-seeded accounts',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  value: settings.isDemoMode,
                  activeThumbColor: AppColors.anthosCyan,
                  onChanged: (val) async {
                    await settings.toggleDemoMode(val);
                    if (!context.mounted) return;
                    if (user != null) {
                      context.read<BankingProvider>().refreshAll(user.accountId, user.username);
                    }
                  },
                ),
                if (!settings.isDemoMode) ...[
                  const Divider(height: 24),
                  CustomTextField(
                    controller: _urlController,
                    label: 'Cluster Ingress Base URL',
                    hint: 'http://<ingress-ip-or-host>:8080',
                    prefixIcon: Icons.dns_outlined,
                    onChanged: (val) => settings.updateBaseUrl(val),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(140, 42),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                        ),
                        onPressed: settings.isCheckingHealth ? null : () => settings.checkClusterHealth(),
                        icon: settings.isCheckingHealth
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.network_ping, size: 16),
                        label: const Text('Probe Cluster', style: TextStyle(fontSize: 13)),
                      ),
                      const SizedBox(width: 12),
                      if (settings.isClusterHealthy != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: settings.isClusterHealthy!
                                ? AppColors.anthosEmerald.withValues(alpha: 0.15)
                                : AppColors.anthosRed.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                settings.isClusterHealthy! ? Icons.check_circle : Icons.cancel,
                                size: 14,
                                color: settings.isClusterHealthy! ? AppColors.anthosEmerald : AppColors.anthosRed,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                settings.isClusterHealthy! ? 'Online (200 OK)' : 'Unreachable',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: settings.isClusterHealthy! ? AppColors.anthosEmerald : AppColors.anthosRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Appearance
          _buildSectionHeader('APPEARANCE'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceVariantDark : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Column(
              children: [
                _buildThemeTile('System Default', ThemeMode.system, settings.themeMode, (m) => settings.setThemeMode(m)),
                const Divider(),
                _buildThemeTile('Light Mode', ThemeMode.light, settings.themeMode, (m) => settings.setThemeMode(m)),
                const Divider(),
                _buildThemeTile('Dark Mode', ThemeMode.dark, settings.themeMode, (m) => settings.setThemeMode(m)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Demo Data Reset
          _buildSectionHeader('SANDBOX DATA'),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceVariantDark : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: ListTile(
              title: const Text('Reset Demo Data', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: const Text('Restore initial balance, demo transactions, and contacts', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.restore),
              onTap: () async {
                await settings.resetDemoData();
                if (!context.mounted) return;
                if (user != null) {
                  await context.read<BankingProvider>().refreshAll(user.accountId, user.username);
                }
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sandbox data restored to defaults!')),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Google Antigravity & Systems Engineering Card
          _buildSectionHeader('AI & SYSTEMS ARCHITECTURE'),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.anthosCyan.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.anthosCyan.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.anthosCyan.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.auto_awesome, color: AppColors.anthosCyan, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Google Antigravity',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.anthosCyan.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.anthosCyan.withValues(alpha: 0.4)),
                      ),
                      child: const Text(
                        'AGENTIC PAIR',
                        style: TextStyle(
                          color: AppColors.anthosCyan,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Engineered and architected via Google Antigravity with autonomous multi-agent code generation, self-healing diagnostic loops, and generative UI verification.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(color: Color(0xFF334155), height: 1),
                const SizedBox(height: 14),
                const Text(
                  'Core Systems Stack:',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _buildSystemBadge(Icons.phone_android, 'Flutter SDK & Dart 3.47+', 'Cross-Platform Android, iOS & Web'),
                const SizedBox(height: 6),
                _buildSystemBadge(Icons.sports_esports, 'Flame 2D Game Engine', 'Physics Coin Fountains & Anthos Mesh'),
                const SizedBox(height: 6),
                _buildSystemBadge(Icons.cloud_queue, 'Google Cloud Bank of Anthos', 'GKE Microservices & Ledger API'),
                const SizedBox(height: 6),
                _buildSystemBadge(Icons.psychology, 'Antigravity Skills & CLI', 'Autonomous QA, Static Analysis & Testing'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Logout Button
          if (auth.isAuthenticated)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.anthosRed,
                side: const BorderSide(color: AppColors.anthosRed),
              ),
              onPressed: () async {
                await auth.logout();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
            ),
          const SizedBox(height: 24),

          // Version Footer
          Center(
            child: Column(
              children: [
                Text(
                  'Bank of Anthos Mobile v1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Google Cloud Architecture Reference Application',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: AppColors.anthosBlue,
        ),
      ),
    );
  }

  Widget _buildThemeTile(
    String title,
    ThemeMode mode,
    ThemeMode current,
    void Function(ThemeMode) onSelect,
  ) {
    return InkWell(
      onTap: () => onSelect(mode),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 14)),
            if (current == mode)
              const Icon(Icons.check, color: AppColors.anthosCyan, size: 20)
            else
              const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemBadge(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.anthosCyan),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
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
