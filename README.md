# NutrySleep 🌙

App de sueño de **Rivera Systems** (familia NutryScan), hecha en Flutter con estilo nocturno oscuro.

## Funciones
- **Inicio**: racha de noches, semana registrada, Kit de Sueño, *Plan para esta noche* (4 tareas con progreso), artículos, Luna y consejo del día.
- **Iniciar Sueño**: registra la noche (sigue contando aunque cierres la app) y al despertar calificas cómo dormiste.
- **Sonidos**: ruido blanco, rosa, marrón, lluvia, mar y ventilador generados dentro de la app (sin archivos de audio), mezclables con volumen propio y temporizador de apagado.
- **Aliento / Meditación**: respiración guiada 4-4-4-4 y 4-7-8 con círculo animado.
- **Luna**: asistente de sueño sin internet que analiza tus noches y responde dudas comunes.
- **Estadísticas**: promedio, meta, racha, calidad, gráfico de 7 días e historial.
- **Rachas y logros**: racha actual y mejor racha, 12 logros (rachas de 3/7/14/30 noches, noches totales, metas cumplidas, plan completo y respiración) con barra de progreso y celebración al desbloquear. Se abre tocando la gotita 💧 del Inicio o desde Perfil.
- **Pantalla de inicio**: logo animado de NutrySleep con "Hecho por Rivera Systems"; el crédito también aparece al final del Inicio y en Perfil.
- **Ícono**: luna con estrellas y la gotita de la racha (`assets/icon/`), generado en Actions con `flutter_launcher_icons` y `flutter_native_splash`.
- **Perfil**: nombre, meta de horas, logros, ajustes y borrado de datos.

Todo se guarda en el teléfono (`shared_preferences`).

## Estructura
```
lib/
  main.dart
  screens/   splash, main_shell, achievements, home, sounds, stats, profile, article, articles_list,
             sleep_tracking, breathing, luna_chat
  widgets/   common (tarjetas, chips, botones, hojas), night_background
  services/  achievement_service, storage_service, noise_service, luna_bot_service
  models/    achievement, article, sleep_session, plan_task, breath_pattern
  data/      achievements_data, articles_data, plan_data
  utils/     app_colors, app_theme
```

## Compilar el APK (GitHub Actions)
1. Crea un repositorio nuevo en GitHub (por ejemplo `NutrySleep`).
2. Sube el contenido de esta carpeta a la rama `main`.
3. Ve a **Actions → Compilar APK NutrySleep**; se ejecuta solo en cada push (o con *Run workflow*).
4. Al terminar, descarga el artefacto **NutrySleep-apk** → `NutrySleep.apk`.

El workflow genera la carpeta `android/` automáticamente (paquete `cl.riverasystems.nutrysleep`) y le pone el nombre visible "NutrySleep".

## Local (VS Code)
```
flutter create . --platforms=android --org cl.riverasystems --project-name nutrysleep
flutter pub get
flutter run
```

## Pendiente
- Notificaciones reales para el recordatorio de respiración (hoy solo guarda la hora).
- Pulso y Sync con reloj (muestran "próximamente").
- Plan PRO.
