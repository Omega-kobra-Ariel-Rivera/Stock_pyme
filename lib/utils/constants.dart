/// Constantes globales de StockPyme.
class AppConstants {
  AppConstants._();

  static const String appName = 'StockPyme';
  static const String appVersion = '1.2.0';
  static const String tagline = 'Inventario y ventas para tu negocio';

  static const String company = 'Rivera Systems';
  static const String companyLocation = 'San Felipe, Chile';

  static const String logoPath = 'assets/branding/logo.png';
  static const String logoForegroundPath = 'assets/branding/splash_logo.png';
  static const String companyLogoPath = 'assets/branding/rivera_systems.png';

  /// Dirección del servidor de pagos (sitio de Netlify con las funciones).
  /// Cámbiala por la de tu sitio, por ejemplo:
  /// https://stockpyme-pagos.netlify.app/api
  static const String paymentsApiUrl = 'https://stockpyme-pagos.netlify.app/api';

  /// Cada cuántas horas se vuelve a consultar el estado del pago.
  static const int paymentCheckHours = 24;

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
  static const String accountId = 'sp_account_id';
  static const String payerEmail = 'sp_payer_email';
  static const String preapprovalId = 'sp_mp_preapproval_id';
  static const String lastPaymentCheck = 'sp_mp_last_check';

  static const List<String> dataKeys = [products, sales, movements];
}
