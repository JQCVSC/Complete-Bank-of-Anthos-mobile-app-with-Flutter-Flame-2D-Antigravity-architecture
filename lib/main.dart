import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'data/services/storage_service.dart';
import 'data/services/api_service.dart';
import 'data/services/mock_banking_service.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/banking_repository.dart';
import 'data/repositories/contacts_repository.dart';
import 'providers/settings_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/banking_provider.dart';
import 'ui/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations for mobile
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize persistent storage
  final storageService = await StorageService.init();

  // Services
  final apiService = ApiService();
  final mockService = MockBankingService(storageService);

  // Repositories
  final authRepository = AuthRepository(
    apiService: apiService,
    mockService: mockService,
    storageService: storageService,
  );

  final bankingRepository = BankingRepository(
    apiService: apiService,
    mockService: mockService,
    storageService: storageService,
  );

  final contactsRepository = ContactsRepository(
    apiService: apiService,
    mockService: mockService,
    storageService: storageService,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(
            storage: storageService,
            apiService: apiService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            repository: authRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => BankingProvider(
            bankingRepository: bankingRepository,
            contactsRepository: contactsRepository,
          ),
        ),
      ],
      child: const BankOfAnthosApp(),
    ),
  );
}

class BankOfAnthosApp extends StatelessWidget {
  const BankOfAnthosApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      title: 'Bank of Anthos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // When opened on a wide desktop browser screen, constrain into a realistic mobile chassis
            if (constraints.maxWidth > 500) {
              return Scaffold(
                backgroundColor: const Color(0xFF070B14),
                body: Center(
                  child: Container(
                    width: 412,
                    height: constraints.maxHeight > 880 ? 844 : constraints.maxHeight,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundDark,
                      borderRadius: constraints.maxHeight > 880 ? BorderRadius.circular(44) : BorderRadius.zero,
                      border: constraints.maxHeight > 880
                          ? Border.all(color: const Color(0xFF1E293B), width: 8)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
              );
            }
            return child ?? const SizedBox.shrink();
          },
        );
      },
      home: const SplashScreen(),
    );
  }
}
