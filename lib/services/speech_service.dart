import 'package:speech_to_text/speech_to_text.dart';


class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _inicializado = false;

  void Function()? _alTerminar;

  bool get estaEscuchando => _speech.isListening;

  Future<void> _inicializar() async {
    if (_inicializado) return;
    try {
      _inicializado = await _speech.initialize(
        onStatus: (estado) {
          if (estado == 'done' || estado == 'notListening') {
            _alTerminar?.call();
          }
        },
      );
    } catch (e) {
      _inicializado = false;
    }
    if (!_inicializado) {
      throw Exception(
          'No se pudo activar el micrófono. Revisa el permiso o que el dispositivo tenga reconocimiento de voz.');
    }
  }

  Future<void> escuchar(void Function(String texto) onTexto,
      {void Function()? alTerminar}) async {
    _alTerminar = alTerminar;
    await _inicializar();
    try {
      await _speech.listen(
        localeId: 'es_MX',
        onResult: (resultado) => onTexto(resultado.recognizedWords),
      );
    } catch (e) {
      throw Exception('Ocurrió un error al escuchar tu voz.');
    }
  }

  Future<void> detener() async {
    try {
      await _speech.stop();
    } catch (e) {
      throw Exception('No se pudo detener el micrófono.');
    }
  }
}