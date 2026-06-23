import 'dart:math' show pi, sin, cos, exp, Random;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

/// Sintetiza e reproduz o som da roleta em tempo real, sem arquivos de áudio externos.
///
/// Replica o comportamento do Web Audio API do PKB.html original:
///   1. Ruído branco → filtro passa-baixa (varredura 420→820→300 Hz) → passa-banda (560 Hz, Q=0.6)
///      → envelope de ganho: fade-in em 1,1s, hold, fade-out nos últimos 2,2s.
///   2. Carrilhão de chegada: dois senos em 587,33 Hz e 880 Hz, 0,09s de diferença.
///
/// O som é gerado como PCM 16-bit mono, empacotado em WAV RIFF e reproduzido
/// via [audioplayers] usando [BytesSource] (sem I/O de disco).
class SpinAudio {
  final AudioPlayer _player = AudioPlayer();

  /// Gera e reproduz o som completo da animação de spin.
  ///
  /// [durationSeconds] deve corresponder à duração da animação da roda.
  Future<void> play(double durationSeconds) async {
    final bytes = await _buildWavAsync(durationSeconds);
    await _player.play(BytesSource(bytes));
  }

  /// Libera o player de áudio ao descartar o widget pai.
  void dispose() => _player.dispose();

  // ── Síntese de áudio ──────────────────────────────────────────────────────

  static const int _sr = 44100; // taxa de amostragem em Hz

  static Future<Uint8List> _buildWavAsync(double dur) async {
    return _buildWav(dur);
  }

  /// Constrói o buffer PCM completo com vento + carrilhão e retorna como WAV.
  static Uint8List _buildWav(double dur) {
    final totalSec = dur + 1.5; // espaço extra para o carrilhão decair
    final n = (totalSec * _sr).ceil();
    final buf = Float64List(n);
    final rng = Random();

    // ── 1. Som de vento ───────────────────────────────────────────────────
    // Cadeia: ruído branco → passa-baixa (varredura) → passa-banda fixo → ganho
    final lp = _BiquadFilter();
    final bp = _BiquadFilter();
    bp.setBandpass(560.0, _sr.toDouble(), 0.6);

    // Atualiza os coeficientes do passa-baixa a cada 256 amostras (~172×/s)
    // para suavidade sem custo de trigonometria por amostra.
    const updateEvery = 256;
    final spinSamples = (dur * _sr).round();

    for (int i = 0; i < spinSamples; i++) {
      final t = i / _sr;

      if (i % updateEvery == 0) {
        // Varredura da frequência de corte: 420 Hz → 820 Hz (1,4s) → 300 Hz (fim)
        double cutHz;
        if (t < 1.4) {
          cutHz = 420 + (820 - 420) * (t / 1.4);
        } else {
          final frac = (t - 1.4) / (dur - 1.4).clamp(0.001, dur);
          cutHz = 820 + (300 - 820) * frac;
        }
        lp.setLowpass(cutHz.clamp(20.0, 20000.0), _sr.toDouble(), 0.707);
      }

      // Envelope de ganho: fade-in → sustain → fade-out nos últimos 2,2s
      double gain;
      if (t < 1.1) {
        gain = 0.0001 + (0.08 - 0.0001) * (t / 1.1);
      } else if (t < dur - 2.2) {
        gain = 0.08;
      } else {
        gain = 0.0001 + (0.08 - 0.0001) * ((dur - t) / 2.2);
      }

      final noise = rng.nextDouble() * 2 - 1;
      buf[i] = bp.process(lp.process(noise)) * gain.clamp(0.0001, 0.08);
    }

    // ── 2. Carrilhão de chegada ───────────────────────────────────────────
    // Dois senos (587,33 Hz e 880 Hz) com ataque rápido e decaimento suave.
    const chimeFreqs = [587.33, 880.0];
    final chimeBase = (dur * _sr).round();
    for (int fi = 0; fi < chimeFreqs.length; fi++) {
      final freq = chimeFreqs[fi];
      final start = chimeBase + (fi * 0.09 * _sr).round();
      final chimeLen = (1.25 * _sr).round();
      for (int j = 0; j < chimeLen && start + j < n; j++) {
        final t = j / _sr;
        final attack = (t / 0.05).clamp(0.0, 1.0);
        final decay = exp(-t * 3.0);
        buf[start + j] =
            (buf[start + j] + sin(2 * pi * freq * t) * attack * decay * 0.08)
                .clamp(-1.0, 1.0);
      }
    }

    return _toWav(buf);
  }

  /// Empacota amostras Float64 em um arquivo WAV RIFF mono 16-bit PCM.
  static Uint8List _toWav(Float64List samples) {
    final pcm = Int16List(samples.length);
    for (int i = 0; i < samples.length; i++) {
      pcm[i] = (samples[i].clamp(-1.0, 1.0) * 32767).round();
    }
    final dataBytes = pcm.length * 2;
    final out = Uint8List(44 + dataBytes);
    final bd = ByteData.view(out.buffer);

    // Cabeçalho RIFF
    out.setRange(0, 4, [0x52, 0x49, 0x46, 0x46]); // "RIFF"
    bd.setUint32(4, 36 + dataBytes, Endian.little);
    out.setRange(8, 12, [0x57, 0x41, 0x56, 0x45]); // "WAVE"
    out.setRange(12, 16, [0x66, 0x6D, 0x74, 0x20]); // "fmt "
    bd.setUint32(16, 16, Endian.little);             // tamanho do chunk fmt
    bd.setUint16(20, 1, Endian.little);              // PCM
    bd.setUint16(22, 1, Endian.little);              // mono
    bd.setUint32(24, _sr, Endian.little);            // taxa de amostragem
    bd.setUint32(28, _sr * 2, Endian.little);        // byte rate
    bd.setUint16(32, 2, Endian.little);              // block align
    bd.setUint16(34, 16, Endian.little);             // bits por amostra
    out.setRange(36, 40, [0x64, 0x61, 0x74, 0x61]); // "data"
    bd.setUint32(40, dataBytes, Endian.little);

    for (int i = 0; i < pcm.length; i++) {
      bd.setInt16(44 + i * 2, pcm[i], Endian.little);
    }
    return out;
  }
}

/// Filtro biquad de dois polos, com suporte a modos passa-baixa e passa-banda.
///
/// Implementa a forma direta II transposta (DF2T), padrão do Web Audio API,
/// o que garante comportamento idêntico ao original em JavaScript.
class _BiquadFilter {
  double _b0 = 1, _b1 = 0, _b2 = 0, _a1 = 0, _a2 = 0;
  double _x1 = 0, _x2 = 0, _y1 = 0, _y2 = 0;

  /// Processa uma única amostra e retorna a saída filtrada.
  double process(double x) {
    final y = _b0 * x + _b1 * _x1 + _b2 * _x2 - _a1 * _y1 - _a2 * _y2;
    _x2 = _x1; _x1 = x;
    _y2 = _y1; _y1 = y;
    return y;
  }

  /// Recalcula os coeficientes para filtro passa-baixa Butterworth.
  ///
  /// [freq] frequência de corte em Hz, [sr] taxa de amostragem, [Q] fator de qualidade.
  void setLowpass(double freq, double sr, double Q) {
    final w0 = 2 * pi * freq / sr;
    final alpha = sin(w0) / (2 * Q);
    final c = cos(w0);
    final a0 = 1 + alpha;
    _b0 = (1 - c) / 2 / a0;
    _b1 = (1 - c) / a0;
    _b2 = (1 - c) / 2 / a0;
    _a1 = -2 * c / a0;
    _a2 = (1 - alpha) / a0;
  }

  /// Recalcula os coeficientes para filtro passa-banda.
  ///
  /// Q baixo (0,6) resulta em banda larga e som "aéreo" de vento.
  void setBandpass(double freq, double sr, double Q) {
    final w0 = 2 * pi * freq / sr;
    final alpha = sin(w0) / (2 * Q);
    final c = cos(w0);
    final a0 = 1 + alpha;
    _b0 = (sin(w0) / 2) / a0;
    _b1 = 0;
    _b2 = -(sin(w0) / 2) / a0;
    _a1 = -2 * c / a0;
    _a2 = (1 - alpha) / a0;
  }
}
