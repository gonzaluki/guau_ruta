import 'dart:io';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/traslado_model.dart';
import '../services/camera_service.dart';
import '../services/location_service.dart';
import '../services/speech_service.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}
// Los controllers leen y escriben el texto de un TextField.
class _FormScreenState extends State<FormScreen> {
  final _nombreController = TextEditingController();
  final _indicacionesController = TextEditingController();

  final _camaraService = CameraService();
  final _vozService = SpeechService();
  final _ubicacionService = LocationService();

  String _tipoTraslado = 'Veterinario';
  String _rutaImagen = '';
  bool _escuchando = false;
  bool _guardando = false;

  // dispose Libera los controllers para no dejar memoria ocupada sin necesidad.
  @override
  void dispose() {
    _nombreController.dispose();
    _indicacionesController.dispose();
    super.dispose();
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }
  //_limpiar solo es para que se vea más bonito el texto porque quita la palabra Exception que ni al caso
  String _limpiar(Object e) => e.toString().replaceAll('Exception: ', '');

  //aquí buscas la foto en la galería o la tomas directamente
  Future<void> _obtenerFoto(bool usarCamara) async {
    try {
      final ruta = usarCamara
          ? await _camaraService.tomarFoto()
          : await _camaraService.elegirDeGaleria();
      if (ruta != null && mounted) setState(() => _rutaImagen = ruta);
    } catch (e) {
      _mostrarMensaje(_limpiar(e));
    }
  }

  //Si está escuchando lo detiene, si no, empieza a escribir.
  Future<void> _alternarDictado() async {
    try {
      if (_escuchando) {
        await _vozService.detener();
        if (mounted) setState(() => _escuchando = false);
      } else {
        setState(() => _escuchando = true);
        await _vozService.escuchar(
            // primero recibe el texto dictado y lo escribe en el TextEditingController
              (texto) {
            if (mounted) {
              setState(() => _indicacionesController.text = texto);
            }
          },
          //luego si el dictado se detiene solo apaga el micrófono
          alTerminar: () {
            if (mounted) setState(() => _escuchando = false);
          },
        );
      }
    } catch (e) {
      if (mounted) setState(() => _escuchando = false);
      _mostrarMensaje(_limpiar(e));
    }
  }

  Future<void> _guardar() async {
    //el trim es para evitar campos vaciós
    if (_nombreController.text.trim().isEmpty) {
      _mostrarMensaje('Escribe el nombre de la mascota.');
      return;
    }
    if (_indicacionesController.text.trim().isEmpty) {
      _mostrarMensaje('Escribe o dicta las indicaciones de cuidado.');
      return;
    }

    setState(() => _guardando = true);
    try {
      // Captura automática de las coordenadas al guardar
      final posicion = await _ubicacionService.obtenerPosicionActual();

      //guarda el objeto
      final traslado = Traslado(
        nombreMascota: _nombreController.text.trim(),
        tipoTraslado: _tipoTraslado,
        indicaciones: _indicacionesController.text.trim(),
        rutaImagen: _rutaImagen,
        latitud: posicion.latitude,
        longitud: posicion.longitude,
        fecha: DateTime.now().toIso8601String(),
      );

      await DatabaseHelper.instancia.insertarTraslado(traslado);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) { //los errores se muestran aquí
      _mostrarMensaje(_limpiar(e));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo traslado')),
      //permite hacer scroll
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //vista previa de la foto
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _rutaImagen.isEmpty
                    ? const Icon(Icons.pets, size: 80, color: Colors.teal)
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(_rutaImagen), fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 8),
            //aquí buscas cómo poner la foto
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _obtenerFoto(true),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Cámara'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _obtenerFoto(false),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galería'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            //aquí pones el nombre de la mascota
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la mascota',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            //aquí pones el tipo de traslado
            const Text('Tipo de traslado'),
            DropdownButton<String>(
              value: _tipoTraslado,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'Veterinario', child: Text('Veterinario')),
                DropdownMenuItem(value: 'Familiar', child: Text('Familiar')),
              ],
              onChanged: (valor) => setState(() => _tipoTraslado = valor!),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _indicacionesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Indicaciones de cuidado',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _alternarDictado,
                  //el ícono cambia depende si el dictado está encendido o apagado
                  icon: Icon(
                    _escuchando ? Icons.mic : Icons.mic_none,
                    color: _escuchando ? Colors.red : Colors.teal,
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            //botón de guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save),
                label: Text(_guardando ? 'Guardando...' : 'Guardar traslado'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}