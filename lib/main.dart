import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';
import 'services/cart_service.dart';
import 'services/inventory_service.dart';
import 'services/storage_service.dart';
import 'services/subscription_service.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';

void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();

    // En vez de una pantalla gris, muestra el error para poder corregirlo.
    ErrorWidget.builder = (details) => _ErrorView(
          message: details.exceptionAsString(),
        );

    // Se dibuja de inmediato; los datos se cargan dentro de _Bootstrap.
    runApp(const _Bootstrap());
  }, (error, stack) {
    debugPrint('Error no controlado: $error\n$stack');
  });
}

/// Carga los servicios mostrando una pantalla de espera.
/// Si algo falla o tarda demasiado, muestra el error con opción de reintentar.
class _Bootstrap extends StatefulWidget {
  const _Bootstrap();

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  InventoryService? _inventory;
  SubscriptionService? _subscription;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final storage = await StorageService.create()
          .timeout(const Duration(seconds: 10));
      final inventory = InventoryService(storage);
      await inventory.init();
      final subscription = SubscriptionService(storage);
      await subscription.init().timeout(const Duration(seconds: 10));
      if (!mounted) return;
      setState(() {
        _inventory = inventory;
        _subscription = subscription;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventory = _inventory;
    final subscription = _subscription;

    if (inventory == null || subscription == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: _error == null
            ? const _LoadingView()
            : _ErrorView(message: _error!, onRetry: _load),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: inventory),
        ChangeNotifierProvider.value(value: subscription),
        ChangeNotifierProvider(create: (_) => CartService()),
      ],
      child: const StockPymeApp(),
    );
  }
}

class StockPymeApp extends StatelessWidget {
  const StockPymeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const SplashScreen(),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.seed,
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.seed,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 12),
              const Text(
                'No se pudo iniciar StockPyme',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              SelectableText(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFCCEDE7), fontSize: 13),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: onRetry,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                  child: const Text('Reintentar'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
