import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
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
      ],
      child: Consumer2<AuthController, AppearanceController>(
        builder: (context, auth, appearance, _) {
          final repository = posRepository ??
              PosRepository(
                apiClient: LaravelApiClient(
                  tokenProvider: () async => auth.token,
                ),
              );
          return MaterialApp(
            title: 'POS Flutter',
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
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
