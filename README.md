# StockPyme

**Inventario y punto de venta para almacenes, minimarkets y pymes.**
App Flutter (Android + Web) de **Rivera Systems**.

Precio sugerido: **$4.990 CLP / mes**, con **14 días de prueba gratis**.

---

## Qué hace

| Función | Detalle |
|---|---|
| Productos | Nombre, código de barras, categoría, unidad (unidad, kg, litro…), costo, precio, stock y stock mínimo |
| Escáner | Lee códigos de barras con la cámara para buscar, crear o vender |
| Punto de venta | Carrito, cantidades con decimales (granel), medios de pago y **cálculo de vuelto** |
| Stock | Descuento automático al vender, entradas (compras) con nuevo costo, salidas/mermas e historial por producto |
| Alertas | Productos bajo el mínimo destacados en Inicio y filtro “Solo stock bajo” |
| Reportes | Ventas, ganancia, n° de ventas, ticket promedio, gráfico diario, más vendidos y totales por medio de pago (hoy / 7 / 30 días) |
| Exportar | Copia inventario y ventas en CSV con `;` para pegar en Excel |
| Suscripción | Prueba de 14 días + suscripción mensual con Google Play Billing |
| Demo | Botón “Cargar ejemplo” con 10 productos típicos de almacén (ideal para capturas de la tienda) |

Funciona **sin internet**: los datos quedan guardados en el dispositivo.

---

## Estructura

```
lib/
├── main.dart
├── models/        product, sale, stock_movement, report_models
├── services/      storage, inventory, cart, subscription
├── screens/       home, dashboard, products, product_form, scanner,
│                  sale, reports, settings, paywall
├── widgets/       stat_card, product_tile, empty_state, trial_banner,
│                  sales_bar_chart, stock_adjust_dialog, checkout_sheet
└── utils/         constants, formatters, theme, id_generator, access_guard
```

---

## Puesta en marcha (VS Code)

```bash
cd stock_pyme
flutter create --org cl.riverasystems --project-name stock_pyme --platforms android,web .
flutter pub get
flutter run
```

`flutter create .` genera solo las carpetas que faltan (`android/`, `web/`); no toca `lib/` ni `pubspec.yaml`.

### Logo e ícono

El logo está en `assets/branding/`. Para ponerlo como ícono de la app y como pantalla de carga:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

Al abrir la app aparece además una pantalla de inicio animada con el logo y la firma "Hecho por Rivera Systems".

> Si `pub get` reclama por versiones, ejecuta `flutter pub upgrade --major-versions`.

### Android: cámara y versión mínima

1. En `android/app/src/main/AndroidManifest.xml`, antes de `<application>`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
```

2. En `android/app/build.gradle.kts` (o `build.gradle`), dentro de `defaultConfig`:

```kotlin
minSdk = 23
```

---

## Cobrar la suscripción (Google Play)

1. Crea la app en **Google Play Console** con el paquete `cl.riverasystems.stock_pyme`.
2. Sube un primer AAB a **Prueba interna**: `flutter build appbundle --release`.
3. Ve a **Monetizar → Productos → Suscripciones** y crea una con ID **`stockpyme_mensual`** (debe coincidir con `AppConstants.subscriptionId`).
4. Agrega un **plan base** mensual de renovación automática a **$4.990 CLP**.
   *No agregues prueba gratis en Play: la app ya da 14 días por su cuenta.*
5. Agrega tu cuenta Gmail como **tester de licencias** (Configuración → Pruebas de licencias) para probar compras sin cobro real.
6. Configura tu **perfil de pagos** para recibir el dinero en tu cuenta bancaria.

Google cobra un 15 % de comisión en suscripciones.

### Firma de la app

```bash
keytool -genkey -v -keystore ~/stockpyme-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias stockpyme
```

Configura `android/key.properties` y el `signingConfig` de release según la guía oficial de Flutter para Android.

---

## Versión web (Netlify)

```bash
flutter build web --release
```

Sube la carpeta `build/web` a Netlify (como tus otros proyectos). En web la prueba gratis funciona igual; la suscripción se contrata desde Android. Si más adelante quieres cobrar también en web, se puede integrar Flow o Mercado Pago.

---

## Límites de esta versión (y siguiente paso)

- **Datos locales**: cada dispositivo tiene su propio inventario. Para varios vendedores o respaldo en la nube, el siguiente paso es sincronizar con **Firebase (Firestore + Auth)**; toda la persistencia está aislada en `StorageService` / `InventoryService` para facilitar el cambio.
- **Prueba gratis local**: si alguien borra los datos de la app, se reinicia la prueba. Con Firebase Auth se puede atar a la cuenta.
- **Validación de compras**: se verifica con Google Play en el dispositivo. Para mayor seguridad, valida los tokens en un backend (Cloud Functions + Google Play Developer API).
- **Boletas SII**: la app registra ventas internas; no emite boleta electrónica.

---

## Cómo venderla

- **Público objetivo**: almacenes de barrio, botillerías, minimarkets, ferreterías y kioscos de San Felipe, Los Andes y alrededores.
- **Gancho**: “Controla tu stock y tus ganancias desde el celular por menos de $170 al día”.
- **Venta directa**: visita negocios con la app cargada con datos de ejemplo y ofrécete a ingresar sus primeros 50 productos gratis.
- **Ficha en Play Store**: capturas de Inicio, Vender (con vuelto) y Reportes usando “Cargar ejemplo”.

---

© Rivera Systems
