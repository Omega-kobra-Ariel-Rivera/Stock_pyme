import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';
import 'services/cart_service.dart';
import 'services/inventory_service.dart';
import 'services/storage_service.dart';
import 'services/subscription_service.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = await StorageService.create();
  final inventory = InventoryService(storage);
  await inventory.init();
  final subscription = SubscriptionService(storage);
  await subscription.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: inventory),
        ChangeNotifierProvider.value(value: subscription),
        ChangeNotifierProvider(create: (_) => CartService()),
      ],
      child: const StockPymeApp(),
    ),
  );
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
