/// Constantes globales de StockPyme.
class AppConstants {
  AppConstants._();

  static const String appName = 'StockPyme';
  static const String appVersion = '1.0.0';
  static const String company = 'Rivera Systems';

  static const String logoPath = 'assets/branding/logo.png';
  static const String logoForegroundPath = 'assets/branding/splash_logo.png';

  /// ID de la suscripción creada en Google Play Console.
  static const String subscriptionId = 'stockpyme_mensual';

  /// Días de prueba gratis antes de exigir la suscripción.
  static const int trialDays = 14;

  /// Precio mostrado si Google Play aún no responde.
  static const String fallbackPrice = r'$4.990';

  static const List<String> units = [
    'unidad',
    'kg',
    'g',
    'litro',
    'caja',
    'paquete',
  ];
}

/// Claves usadas en el almacenamiento local.
class StorageKeys {
  StorageKeys._();

  static const String products = 'sp_products';
  static const String sales = 'sp_sales';
  static const String movements = 'sp_movements';
  static const String businessName = 'sp_business_name';
  static const String trialStart = 'sp_trial_start';
  static const String subscribed = 'sp_subscribed';

  static const List<String> dataKeys = [products, sales, movements];
}
