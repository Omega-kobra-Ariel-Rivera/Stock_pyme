import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';
import 'services/noise_service.dart';
import 'services/storage_service.dart';
import 'utils/app_colors.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();
  await NoiseService.instance.init();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.navBar,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const NutrySleepApp());
}

class NutrySleepApp extends StatelessWidget {
  const NutrySleepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutrySleep',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      navigatorObservers: [routeObserver],
      home: const SplashScreen(),
    );
  }
}
