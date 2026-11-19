import 'package:speech_to_text/speech_to_text.dart';


class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _inicializado = false;

  void Function()? _alTerminar;
  // Getter: dice si en este momento el micrófono está escuchando.
  bool get estaEscuchando => _speech.isListening;

  Future<void> _inicializar() async {
    if (_inicializado) return;
    try {
      _inicializado = await _speech.initialize(
      // Cuando pasa a 'done' o 'notListening' el dictado ya terminó así que hay que avisar a la pantalla que se apague el ícono
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
  // onTexto: callback que recibe el texto cada vez que hay palabras nuevas
  // alTerminar: callback  para saber cuándo paró
  Future<void> escuchar(void Function(String texto) onTexto,
      {void Function()? alTerminar}) async {
    _alTerminar = alTerminar;
    await _inicializar(); // Primero asegura permiso y motor listo
    try {
      await _speech.listen(
        localeId: 'es_MX',
        onResult: (resultado) => onTexto(resultado.recognizedWords), // recognizedWords es lo reconocido hasta el momento
      );
    } catch (e) {
      throw Exception('Ocurrió un error al escuchar tu voz.');
    }
  }

  // detener(): para el dictado cuando el usuario vuelve a pulsar el micrófono.
  Future<void> detener() async {
    try {
      await _speech.stop();
    } catch (e) {
      throw Exception('No se pudo detener el micrófono.');
    }
  }
}