import '../models/sleep_session.dart';
import '../utils/app_theme.dart';
import 'storage_service.dart';

/// Asistente de sueño basado en reglas (funciona sin internet).
class LunaBotService {
  LunaBotService._();

  static String greeting(String name) =>
      'Hola $name, soy Luna 🌙. Puedo analizar tus noches registradas o darte consejos para dormir mejor. ¿En qué te ayudo?';

  static const suggestions = <String>[
    'Analiza mi sueño',
    'No puedo quedarme dormido',
    'Me despierto de noche',
    '¿Cuántas horas debo dormir?',
    'Consejos para la siesta',
  ];

  static String reply(String message) {
    final m = _normalize(message);
    final storage = StorageService.instance;

    if (_has(m, ['analiza', 'analisis', 'mi sueno', 'como dormi', 'estadistica'])) {
      return _analysis(storage.sessions, storage.goalHours);
    }
    if (_has(m, ['no puedo dormir', 'quedarme dormid', 'insomnio', 'no me duermo', 'conciliar'])) {
      return 'Para conciliar el sueño prueba esto:\n'
          '• Haz el ejercicio de Meditación (4-7-8) del Kit de Sueño.\n'
          '• Escribe tus preocupaciones antes de acostarte.\n'
          '• Activa ruido rosa o lluvia a volumen bajo.\n'
          '• Si pasan 20 minutos y sigues despierto, levántate, haz algo tranquilo con poca luz y vuelve cuando tengas sueño.';
    }
    if (_has(m, ['despierto de noche', 'me despierto', 'despertar', 'madrugada'])) {
      return 'Despertarse de noche es común. Algunas ideas:\n'
          '• Evita alcohol y comidas pesadas cerca de la hora de dormir.\n'
          '• Mantén la pieza oscura y fresca (18–20 °C).\n'
          '• Usa ruido blanco para tapar ruidos que te despiertan.\n'
          '• No mires la hora en el celular: la luz y la ansiedad te activan.';
    }
    if (_has(m, ['cuantas horas', 'horas debo', 'cuanto dormir', 'meta'])) {
      return 'La mayoría de los adultos necesita entre 7 y 9 horas. Tu meta actual es de '
          '${storage.goalHours.toStringAsFixed(1)} h; puedes cambiarla en tu Perfil.';
    }
    if (_has(m, ['siesta'])) {
      return 'Una buena siesta dura entre 10 y 20 minutos y idealmente antes de las 15:00. '
          'Más larga puede dejarte aturdido y quitarte sueño en la noche.';
    }
    if (_has(m, ['cafe', 'cafeina', 'energetica', 'te '])) {
      return 'La cafeína puede seguir activa entre 6 y 8 horas. Si te acuestas a las 23:00, intenta que tu último café sea antes de las 15:00.';
    }
    if (_has(m, ['ronc', 'apnea'])) {
      return 'Dormir de lado suele reducir los ronquidos. Si roncas fuerte, haces pausas al respirar o te despiertas cansado aunque duermas bastante, conversa con un médico: podría ser algo que vale la pena revisar.';
    }
    if (_has(m, ['estres', 'ansiedad', 'preocup', 'nervios'])) {
      return 'Cuando la mente no para, ayuda sacar las ideas de la cabeza. Usa la tarea "Escribe tus preocupaciones" del plan de esta noche y luego haz 5 minutos de respiración en Aliento.';
    }
    if (_has(m, ['ruido', 'sonido', 'musica'])) {
      return 'En la pestaña Sonidos puedes mezclar ruido blanco, rosa, marrón, lluvia, mar y ventilador, cada uno con su volumen, y programar que se apaguen solos.';
    }
    if (_has(m, ['hola', 'buenas', 'hey'])) {
      return '¡Hola! Pregúntame por tu sueño o pídeme que analice tus noches.';
    }
    if (_has(m, ['gracias'])) {
      return '¡De nada! Que descanses 💤';
    }
    return 'No estoy segura de haber entendido. Puedes pedirme "Analiza mi sueño" o preguntarme por insomnio, despertares, siestas, cafeína o ronquidos.';
  }

  static String _analysis(List<SleepSession> all, double goal) {
    if (all.isEmpty) {
      return 'Aún no tienes noches registradas. Esta noche toca "Iniciar Sueño" al acostarte y "Detener" al despertar; mañana podré analizarlo.';
    }
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final recent = all.where((s) => s.start.isAfter(cutoff)).toList();
    final list = recent.isEmpty ? all : recent;
    final avg = list.map((s) => s.hours).reduce((a, b) => a + b) / list.length;
    final avgQ =
        list.map((s) => s.quality).reduce((a, b) => a + b) / list.length;
    final last = all.last;

    final buf = StringBuffer()
      ..writeln('Revisé ${list.length} noche(s):')
      ..writeln('• Promedio: ${avg.toStringAsFixed(1)} h (meta ${goal.toStringAsFixed(1)} h)')
      ..writeln('• Calidad media: ${avgQ.toStringAsFixed(1)} / 5')
      ..writeln('• Última noche: ${Fmt.duration(last.duration)}, de ${Fmt.time(last.start)} a ${Fmt.time(last.end)}')
      ..writeln();

    if (avg < goal - 1) {
      buf.write('Estás durmiendo bastante menos que tu meta. Prueba adelantar la hora de acostarte 15 minutos cada noche hasta acercarte.');
    } else if (avg < goal) {
      buf.write('Estás cerca de tu meta. Un horario fijo de acostarte te ayudaría a ganar ese tramo que falta.');
    } else {
      buf.write('¡Bien! Estás cumpliendo tu meta de horas.');
    }
    if (avgQ < 3) {
      buf.write(' Tu calidad percibida es baja: revisa temperatura, luz y ruido de tu pieza, y evita pantallas antes de dormir.');
    }
    return buf.toString();
  }

  static bool _has(String m, List<String> keys) => keys.any(m.contains);

  static String _normalize(String s) {
    const from = 'áéíóúüñ';
    const to = 'aeiouun';
    var r = s.toLowerCase();
    for (var i = 0; i < from.length; i++) {
      r = r.replaceAll(from[i], to[i]);
    }
    return '$r ';
  }
}
