# StockPyme

**Inventario y punto de venta para almacenes, minimarkets y pymes.**
App Flutter para Android, desarrollada por **Rivera Systems** (San Felipe, Chile).

Precio: **$4.990 CLP al mes**, con **14 días de prueba gratis**.

## Funciones

| Función | Detalle |
|---|---|
| Productos | Nombre, código de barras, categoría, unidad (unidad, kg, litro…), costo, precio, stock y stock mínimo |
| Escáner | Lee códigos de barras con la cámara para buscar, crear o vender |
| Punto de venta | Carrito con cantidades a granel, medios de pago y cálculo de vuelto |
| Stock | Descuento automático al vender, entradas de mercadería, mermas e historial por producto |
| Alertas | Productos bajo el mínimo destacados en Inicio |
| Reportes | Ventas, ganancia, ticket promedio, gráfico diario y más vendidos (hoy, 7 y 30 días) |
| Exportar | Inventario y ventas en CSV para Excel o Google Sheets |
| Suscripción | Prueba de 14 días y suscripción mensual con **Mercado Pago** |
| Demo | Carga productos de ejemplo para mostrar la app |

Funciona **sin internet**: los datos quedan guardados en el teléfono.

## Novedades v1.2.0

- **Pago con Mercado Pago:** el botón "Pagar con Mercado Pago" abre Mercado Pago directamente (la app de Mercado Pago o el navegador). El cobro se repite automáticamente cada mes.
- La app revisa sola si el pago se aprobó al volver de Mercado Pago y una vez al día.
- El Access Token **no va en la app**: vive en el servidor de pagos (`stockpyme-pagos`, funciones de Netlify).
- Para cambiar la dirección del servidor, edita `paymentsApiUrl` en `lib/utils/constants.dart`.

## Novedades v1.1.0

- Diseño más profesional: tema unificado, tarjetas con borde, barra de navegación y tipografía más marcada.
- Inicio con un resumen destacado de las ventas del día (total, número de ventas y ganancia).
- Pantalla de suscripción renovada, con la etiqueta "14 días gratis".
- Firma de Rivera Systems con el logo en la pantalla de carga, en Inicio, en la suscripción y en Ajustes.
- La app aparece como **StockPyme** en el teléfono.

## Estructura

```
lib/
├── main.dart            Arranque y carga de servicios
├── models/              Producto, venta, movimiento de stock, reportes
├── services/            Almacenamiento, inventario, carrito, suscripción
├── screens/             Inicio, productos, vender, reportes, ajustes, suscripción
├── widgets/             Componentes reutilizables
└── utils/               Tema, constantes, formatos, permisos de acceso
assets/branding/         Ícono, pantalla de inicio y logo de Rivera Systems
.github/workflows/       Compilación automática del APK
```

## Compilar el APK

Cada `git push` a `main` compila el APK en GitHub Actions y lo publica en **Releases** como versión de prueba.

Para publicar una versión oficial:

```bash
git tag v1.1.0
git push origin v1.1.0
```

## Probar en el computador

```bash
flutter pub get
flutter run
```

## Publicar en Google Play

1. Crea tu clave de firma (keystore) y configúrala en `android/app/build.gradle.kts`.
2. Compila con `flutter build appbundle --release`.
3. En Google Play, las suscripciones dentro de la app deben cobrarse con Google Play Billing.
   La versión con Google Play Billing está en el historial de Git (v1.1.0).

---

© Rivera Systems
