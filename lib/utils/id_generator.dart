import 'dart:math';

final Random _random = Random();

/// Genera un identificador único corto sin dependencias externas.
String newId() {
  final time = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  final noise = _random.nextInt(1 << 30).toRadixString(36);
  return '$time$noise';
}

/// Busca un valor de enum por nombre con respaldo seguro.
T enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}
