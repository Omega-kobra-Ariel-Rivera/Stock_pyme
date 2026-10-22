import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../utils/constants.dart';
import '../utils/id_generator.dart';
import 'storage_service.dart';

/// Prueba gratis + suscripción mensual con Mercado Pago.
///
/// La app nunca guarda el Access Token de Mercado Pago: habla con un
/// servidor propio (funciones de Netlify) que lo tiene como variable secreta.
class SubscriptionService extends ChangeNotifier with WidgetsBindingObserver {
  SubscriptionService(this._storage);

  final StorageService _storage;

  static final RegExp _emailPattern =
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  DateTime _trialStart = DateTime.now();
  bool _subscribed = false;
  bool _loading = false;
  String? _error;
  String? _info;
  String _accountId = '';
  String _payerEmail = '';
  String? _preapprovalId;
  DateTime? _lastCheck;

  bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  bool get isSubscribed => _subscribed;
  bool get loading => _loading;
  String? get error => _error;

  /// Mensaje informativo (por ejemplo, "pago pendiente").
  String? get info => _info;
  String get payerEmail => _payerEmail;

  /// Hay un pago iniciado en Mercado Pago que aún no se confirma.
  bool get hasPendingPayment => _preapprovalId != null && !_subscribed;

  int get trialDaysLeft {
    final end = _trialStart.add(const Duration(days: AppConstants.trialDays));
    final left = end.difference(DateTime.now());
    if (left.isNegative) return 0;
    return (left.inHours / 24).ceil();
  }

  bool get inTrial => !_subscribed && trialDaysLeft > 0;
  bool get hasAccess => _subscribed || trialDaysLeft > 0;

  String get priceLabel => '${AppConstants.fallbackPrice} / mes';

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
    _payerEmail = _storage.getString(StorageKeys.payerEmail) ?? '';
    final savedId = _storage.getString(StorageKeys.preapprovalId);
    _preapprovalId = (savedId == null || savedId.isEmpty) ? null : savedId;
    final last = _storage.getString(StorageKeys.lastPaymentCheck);
    _lastCheck = last == null ? null : DateTime.tryParse(last);

    var account = _storage.getString(StorageKeys.accountId);
    if (account == null || account.isEmpty) {
      account = 'sp_${newId()}';
      await _storage.setString(StorageKeys.accountId, account);
    }
    _accountId = account;

    WidgetsBinding.instance.addObserver(this);

    // Revisa el estado en segundo plano para no retrasar el inicio.
    if (_preapprovalId != null && _isCheckDue) {
      unawaited(checkPayment(silent: true));
    }
  }

  bool get _isCheckDue {
    final last = _lastCheck;
    if (last == null) return true;
    return DateTime.now().difference(last).inHours >=
        AppConstants.paymentCheckHours;
  }

  /// Al volver a la app desde Mercado Pago, revisa si el pago se aprobó.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && hasPendingPayment && !_loading) {
      unawaited(checkPayment(silent: true));
    }
  }

  Future<void> setPayerEmail(String email) async {
    _payerEmail = email.trim().toLowerCase();
    await _storage.setString(StorageKeys.payerEmail, _payerEmail);
  }

  /// Crea la suscripción y abre Mercado Pago para pagar.
  Future<void> subscribe([String? email]) async {
    _error = null;
    _info = null;
    if (email != null) await setPayerEmail(email);
    if (!_emailPattern.hasMatch(_payerEmail)) {
      _error = 'Escribe un correo válido. Mercado Pago lo usa para tu suscripción.';
      notifyListeners();
      return;
    }

    _loading = true;
    notifyListeners();
    try {
      final response = await http
          .post(
            Uri.parse('${AppConstants.paymentsApiUrl}/crear-suscripcion'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': _payerEmail, 'accountId': _accountId}),
          )
          .timeout(const Duration(seconds: 20));
      final data = _decode(response.body);

      if (response.statusCode != 200 || data['init_point'] == null) {
        _error = (data['error'] as String?) ??
            'No se pudo iniciar el pago. Inténtalo otra vez.';
        return;
      }

      _preapprovalId = data['id'] as String?;
      if (_preapprovalId != null) {
        await _storage.setString(StorageKeys.preapprovalId, _preapprovalId!);
      }

      final opened = await launchUrl(
        Uri.parse(data['init_point'] as String),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) {
        _error = 'No se pudo abrir Mercado Pago en este teléfono.';
      } else {
        _info =
            'Completa el pago en Mercado Pago y vuelve a StockPyme. Lo revisaremos al volver.';
      }
    } on TimeoutException {
      _error = 'Mercado Pago está tardando. Revisa tu conexión e inténtalo otra vez.';
    } catch (_) {
      _error = 'Sin conexión. Conéctate a internet para pagar.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Consulta el estado de la suscripción en Mercado Pago.
  /// Con [silent] no muestra errores (revisiones automáticas).
  Future<void> checkPayment({bool silent = false}) async {
    final id = _preapprovalId;
    if (id == null) {
      if (!silent) {
        _error = 'Aún no has iniciado un pago desde este teléfono.';
        notifyListeners();
      }
      return;
    }

    if (!silent) {
      _error = null;
      _info = null;
      _loading = true;
      notifyListeners();
    }
    try {
      final response = await http
          .get(Uri.parse(
              '${AppConstants.paymentsApiUrl}/estado-suscripcion?id=${Uri.encodeQueryComponent(id)}'))
          .timeout(const Duration(seconds: 20));
      final data = _decode(response.body);
      if (response.statusCode != 200) {
        if (!silent) {
          _error = (data['error'] as String?) ??
              'No se pudo revisar el pago. Inténtalo más tarde.';
        }
        return;
      }

      final status = data['status'] as String? ?? '';
      _lastCheck = DateTime.now();
      await _storage.setString(
          StorageKeys.lastPaymentCheck, _lastCheck!.toIso8601String());

      switch (status) {
        case 'authorized':
          await _setSubscribed(true);
          _info = null;
        case 'pending':
          if (!silent) {
            _info = 'El pago aún está pendiente en Mercado Pago.';
          }
        case 'paused':
        case 'cancelled':
          await _setSubscribed(false);
          if (!silent) {
            _error = status == 'paused'
                ? 'Tu suscripción está pausada en Mercado Pago.'
                : 'Tu suscripción fue cancelada. Puedes suscribirte otra vez.';
          }
          if (status == 'cancelled') {
            _preapprovalId = null;
            await _storage.setString(StorageKeys.preapprovalId, '');
          }
      }
    } on TimeoutException {
      if (!silent) _error = 'Mercado Pago está tardando. Inténtalo otra vez.';
    } catch (_) {
      // Sin conexión: se mantiene el último estado guardado.
      if (!silent) _error = 'Sin conexión. Conéctate a internet para revisar el pago.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Compatibilidad con la versión anterior ("restaurar compra").
  Future<void> restore() => checkPayment();

  Map<String, dynamic> _decode(String body) {
    try {
      final value = jsonDecode(body);
      return value is Map<String, dynamic> ? value : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Future<void> _setSubscribed(bool value) async {
    _subscribed = value;
    await _storage.setBool(StorageKeys.subscribed, value);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
