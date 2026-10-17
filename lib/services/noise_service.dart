import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

enum NoiseType { white, pink, brown, rain, ocean, fan }

class NoiseInfo {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  const NoiseInfo(this.name, this.description, this.icon, this.color);
}

const noiseInfo = <NoiseType, NoiseInfo>{
  NoiseType.white: NoiseInfo('Ruido blanco', 'Tapa voces y tráfico',
      Icons.graphic_eq, Color(0xFF0A84FF)),
  NoiseType.pink: NoiseInfo('Ruido rosa', 'Suave como lluvia fina',
      Icons.blur_on, Color(0xFFE0578A)),
  NoiseType.brown: NoiseInfo('Ruido marrón', 'Grave y profundo',
      Icons.waves, Color(0xFFB07A4F)),
  NoiseType.rain: NoiseInfo('Lluvia', 'Gotas sobre el techo',
      Icons.water_drop_outlined, Color(0xFF2BB3A6)),
  NoiseType.ocean: NoiseInfo('Mar', 'Olas lentas y lejanas',
      Icons.beach_access_outlined, Color(0xFF4F5BFF)),
  NoiseType.fan: NoiseInfo('Ventilador', 'Zumbido constante',
      Icons.air, Color(0xFF7B5CFF)),
};

/// Genera ruidos en WAV (sin archivos de audio externos) y los reproduce en
/// bucle. Permite mezclar varios sonidos a la vez.
class NoiseService {
  NoiseService._();
  static final NoiseService instance = NoiseService._();

  final Map<NoiseType, AudioPlayer> _players = {};
  final Map<NoiseType, double> volumes = {};
  final ValueNotifier<Set<NoiseType>> playing =
      ValueNotifier<Set<NoiseType>>(<NoiseType>{});
  final ValueNotifier<DateTime?> stopAt = ValueNotifier<DateTime?>(null);
  Timer? _sleepTimer;

  Future<void> init() async {
    try {
      // Permite que varios sonidos suenen a la vez sin quitarse el foco.
      await AudioPlayer.global.setAudioContext(AudioContext(
        android: AudioContextAndroid(audioFocus: AndroidAudioFocus.none),
      ));
    } catch (e) {
      debugPrint('No se pudo configurar el contexto de audio: $e');
    }
  }

  bool isPlaying(NoiseType t) => playing.value.contains(t);

  double volumeOf(NoiseType t) => volumes[t] ?? 0.7;

  Future<void> toggle(NoiseType t) async {
    if (isPlaying(t)) {
      await stop(t);
    } else {
      await play(t);
    }
  }

  Future<void> play(NoiseType t) async {
    if (isPlaying(t)) return;
    final path = await _ensureFile(t);
    final player = _players.putIfAbsent(t, () => AudioPlayer());
    await player.setReleaseMode(ReleaseMode.loop);
    await player.setVolume(volumeOf(t));
    await player.play(DeviceFileSource(path));
    playing.value = {...playing.value, t};
  }

  Future<void> stop(NoiseType t) async {
    await _players[t]?.stop();
    final next = {...playing.value}..remove(t);
    playing.value = next;
    if (next.isEmpty) _cancelTimer();
  }

  Future<void> stopAll() async {
    for (final t in playing.value.toList()) {
      await _players[t]?.stop();
    }
    playing.value = <NoiseType>{};
    _cancelTimer();
  }

  Future<void> setVolume(NoiseType t, double v) async {
    volumes[t] = v;
    await _players[t]?.setVolume(v);
  }

  void setSleepTimer(Duration? d) {
    _cancelTimer();
    if (d == null) return;
    stopAt.value = DateTime.now().add(d);
    _sleepTimer = Timer(d, () => stopAll());
  }

  void _cancelTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    stopAt.value = null;
  }

  // ---------------- Generación de audio ----------------

  Future<String> _ensureFile(NoiseType t) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/nutrysleep_${t.name}_v1.wav');
    if (!await file.exists()) {
      await file.writeAsBytes(_generateWav(t), flush: true);
    }
    return file.path;
  }

  static const int _sampleRate = 22050;
  static const int _seconds = 10;

  Uint8List _generateWav(NoiseType type) {
    const n = _sampleRate * _seconds;
    const fade = _sampleRate ~/ 4; // fundido para que el bucle no se note
    final raw = _synth(type, n + fade);

    // Crossfade del final sobre el inicio.
    final samples = Float64List(n);
    for (var i = 0; i < n; i++) {
      if (i < fade) {
        final a = i / fade;
        samples[i] = raw[i] * a + raw[n + i] * (1 - a);
      } else {
        samples[i] = raw[i];
      }
    }

    // Normalizar.
    var peak = 0.0;
    for (final s in samples) {
      if (s.abs() > peak) peak = s.abs();
    }
    final gain = peak > 0 ? 0.85 / peak : 1.0;

    final data = ByteData(44 + n * 2);
    void str(int offset, String s) {
      for (var i = 0; i < s.length; i++) {
        data.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    str(0, 'RIFF');
    data.setUint32(4, 36 + n * 2, Endian.little);
    str(8, 'WAVE');
    str(12, 'fmt ');
    data.setUint32(16, 16, Endian.little);
    data.setUint16(20, 1, Endian.little); // PCM
    data.setUint16(22, 1, Endian.little); // mono
    data.setUint32(24, _sampleRate, Endian.little);
    data.setUint32(28, _sampleRate * 2, Endian.little);
    data.setUint16(32, 2, Endian.little);
    data.setUint16(34, 16, Endian.little);
    str(36, 'data');
    data.setUint32(40, n * 2, Endian.little);

    for (var i = 0; i < n; i++) {
      final v = (samples[i] * gain * 32767).round().clamp(-32768, 32767).toInt();
      data.setInt16(44 + i * 2, v, Endian.little);
    }
    return data.buffer.asUint8List();
  }

  Float64List _synth(NoiseType type, int length) {
    final rnd = Random(42 + type.index);
    final out = Float64List(length);
    double white() => rnd.nextDouble() * 2 - 1;

    // Estado para ruido rosa (Paul Kellet) y marrón.
    var b0 = 0.0, b1 = 0.0, b2 = 0.0, b3 = 0.0, b4 = 0.0, b5 = 0.0, b6 = 0.0;
    double pink() {
      final w = white();
      b0 = 0.99886 * b0 + w * 0.0555179;
      b1 = 0.99332 * b1 + w * 0.0750759;
      b2 = 0.96900 * b2 + w * 0.1538520;
      b3 = 0.86650 * b3 + w * 0.3104856;
      b4 = 0.55000 * b4 + w * 0.5329522;
      b5 = -0.7616 * b5 - w * 0.0168980;
      final p = b0 + b1 + b2 + b3 + b4 + b5 + b6 + w * 0.5362;
      b6 = w * 0.115926;
      return p * 0.11;
    }

    var brownState = 0.0;
    double brown() {
      brownState = (brownState + 0.02 * white()) / 1.02;
      return brownState * 3.5;
    }

    var drop = 0.0;
    var lowState = 0.0;

    for (var i = 0; i < length; i++) {
      final t = i / _sampleRate;
      switch (type) {
        case NoiseType.white:
          out[i] = white() * 0.5;
          break;
        case NoiseType.pink:
          out[i] = pink();
          break;
        case NoiseType.brown:
          out[i] = brown();
          break;
        case NoiseType.rain:
          if (rnd.nextDouble() < 0.0025) drop = 0.6 + rnd.nextDouble() * 0.4;
          drop *= 0.985;
          out[i] = pink() * 0.7 + white() * drop * 0.5;
          break;
        case NoiseType.ocean:
          // Olas: ruido marrón modulado por una envolvente lenta.
          final wave = 0.5 + 0.5 * sin(2 * pi * t / _seconds * 2 - pi / 2);
          out[i] = brown() * (0.25 + 0.75 * wave * wave);
          break;
        case NoiseType.fan:
          lowState = lowState * 0.92 + white() * 0.08;
          out[i] = lowState * 2.0 + sin(2 * pi * 90 * t) * 0.04;
          break;
      }
    }
    return out;
  }
}
