import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'core/i18n/translation_controller.dart';
import 'package:pos_nimirik/core/i18n/i18n.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/state/auth_controller.dart';
import 'features/pos/data/pos_repository.dart';
import 'features/pos/presentation/pages/pos_page.dart';
import 'features/pos/state/appearance_controller.dart';
import 'features/pos/state/printer_controller.dart';
import 'features/pos/state/pos_controller.dart';

class PosApp extends StatelessWidget {
  const PosApp({super.key, this.posRepository, this.authRepository});

  final PosRepository? posRepository;
  final AuthRepository? authRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(
                repository: authRepository ??
                    AuthRepository(
                      apiClient: LaravelApiClient(),
                      tokenStorage: const TokenStorage(),
                    ),
              )..bootstrap(),
        ),
        ChangeNotifierProvider(
          create: (_) => AppearanceController()..bootstrap(),
        ),
        ChangeNotifierProvider(
          create: (_) => TranslationController()..bootstrap(),
        ),
      ],
      child: Consumer3<AuthController, AppearanceController, TranslationController>(
        builder: (context, auth, appearance, translations, _) {
          final repository = posRepository ??
              PosRepository(
                apiClient: LaravelApiClient(
                  tokenProvider: () async => auth.token,
                ),
              );
          return MaterialApp(
            title: tr('POS Flutter'),
            theme: appearance.theme.copyWith(
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            builder: (context, child) {
              final mediaQuery = MediaQuery.of(context);
              return MediaQuery(
                data: mediaQuery.copyWith(
                  textScaleFactor: appearance.uiScale,
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: _buildHome(auth, repository),
          );
        },
      ),
    );
  }

  Widget _buildHome(AuthController auth, PosRepository repository) {
    if (auth.initializing) {
      return const _PosSplashScreen();
    }
    if (!auth.isAuthenticated) {
      return const LoginPage();
    }

    return MultiProvider(
      key: ValueKey(auth.token),
      providers: [
        ChangeNotifierProvider(
          create: (_) => PosController(repository: repository)..bootstrap(),
        ),
        ChangeNotifierProvider(
          create: (_) => PrinterSettingsController(),
        ),
      ],
      child: const PosPage(),
    );
  }
}

class _PosSplashScreen extends StatelessWidget {
  const _PosSplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7C045),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'flutter_02.png',
              width: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 18),
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
