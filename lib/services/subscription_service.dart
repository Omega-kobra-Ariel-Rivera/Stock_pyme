import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../utils/constants.dart';
import 'storage_service.dart';

/// Prueba gratis + suscripción mensual con Google Play Billing.
class SubscriptionService extends ChangeNotifier {
  SubscriptionService(this._storage);

  final StorageService _storage;

  // Se accede solo en Android: en web no hay tienda.
  InAppPurchase get _iap => InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  DateTime _trialStart = DateTime.now();
  bool _subscribed = false;
  bool _storeAvailable = false;
  bool _loading = false;
  ProductDetails? _product;
  String? _error;

  bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  bool get isSubscribed => _subscribed;
  bool get loading => _loading;
  String? get error => _error;

  int get trialDaysLeft {
    final end = _trialStart.add(const Duration(days: AppConstants.trialDays));
    final left = end.difference(DateTime.now());
    if (left.isNegative) return 0;
    return (left.inHours / 24).ceil();
  }

  bool get inTrial => !_subscribed && trialDaysLeft > 0;
  bool get hasAccess => _subscribed || trialDaysLeft > 0;

  String get priceLabel =>
      '${_product?.price ?? AppConstants.fallbackPrice} / mes';

  Future<void> init() async {
    final saved = _storage.getString(StorageKeys.trialStart);
    final parsed = saved == null ? null : DateTime.tryParse(saved);
    if (parsed == null) {
      _trialStart = DateTime.now();
      await _storage.setString(
          StorageKeys.trialStart, _trialStart.toIso8601String());
    } else {
      _trialStart = parsed;
    }
    _subscribed = _storage.getBool(StorageKeys.subscribed) ?? false;

    // La tienda se conecta en segundo plano para no retrasar el inicio.
    if (isAndroid) unawaited(_connectStore());
  }

  Future<void> _connectStore() async {
    try {
      _storeAvailable = await _iap.isAvailable();
      if (!_storeAvailable) {
        notifyListeners();
        return;
      }
      _purchaseSub ??= _iap.purchaseStream.listen(
        _onPurchaseUpdates,
        onError: (Object e) {
          _error = 'Error de Google Play: $e';
          _loading = false;
          notifyListeners();
        },
      );
      final response =
          await _iap.queryProductDetails({AppConstants.subscriptionId});
      if (response.productDetails.isNotEmpty) {
        _product = response.productDetails.first;
      }
      await _syncActiveSubscription();
    } catch (e) {
      _error = 'No se pudo conectar con Google Play.';
    }
    notifyListeners();
  }

  /// Consulta a Google Play si la suscripción sigue activa.
  Future<void> _syncActiveSubscription() async {
    final android =
        _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
    final response = await android.queryPastPurchases();
    if (response.error != null) return; // sin conexión: se mantiene el caché
    final active = response.pastPurchases
        .any((p) => p.productID == AppConstants.subscriptionId);
    await _setSubscribed(active);
    for (final purchase in response.pastPurchases) {
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != AppConstants.subscriptionId) continue;
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _loading = true;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _setSubscribed(true);
          _loading = false;
          _error = null;
        case PurchaseStatus.error:
          _error = purchase.error?.message ?? 'La compra no se completó.';
          _loading = false;
        case PurchaseStatus.canceled:
          _loading = false;
      }
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
    notifyListeners();
  }

  Future<void> _setSubscribed(bool value) async {
    _subscribed = value;
    await _storage.setBool(StorageKeys.subscribed, value);
  }

  Future<void> subscribe() async {
    _error = null;
    if (!isAndroid) {
      _error =
          'La suscripción se contrata desde la app Android en Google Play.';
      notifyListeners();
      return;
    }
    if (!_storeAvailable || _product == null) {
      _error =
          'La suscripción no está disponible ahora. Revisa tu conexión e inténtalo otra vez.';
      notifyListeners();
      await _connectStore();
      return;
    }
    _loading = true;
    notifyListeners();
    try {
      await _iap.buyNonConsumable(
          purchaseParam: PurchaseParam(productDetails: _product!));
    } catch (e) {
      _error = 'No se pudo iniciar la compra.';
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> restore() async {
    _error = null;
    if (!isAndroid) {
      _error = 'Restaura tu compra desde la app Android.';
      notifyListeners();
      return;
    }
    _loading = true;
    notifyListeners();
    try {
      if (!_storeAvailable) await _connectStore();
      await _syncActiveSubscription();
      if (!_subscribed) {
        _error = 'No encontramos una suscripción activa en esta cuenta de Google.';
      }
    } catch (e) {
      _error = 'No se pudo restaurar la compra.';
    }
    _loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }
}
