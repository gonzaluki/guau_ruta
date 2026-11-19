import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CameraService {
  // Objeto del paquete image_picker que abre la cámara o la galería.
  final ImagePicker _picker = ImagePicker();

  Future<String?> tomarFoto() => _obtenerFoto(ImageSource.camera);

  Future<String?> elegirDeGaleria() => _obtenerFoto(ImageSource.gallery);

  Future<String?> _obtenerFoto(ImageSource origen) async {
    try {
      // Abre la cámara o galería
      final XFile? foto = await _picker.pickImage(
        source: origen,
        imageQuality: 70,
      );
      if (foto == null) return null;
      
      final carpeta = await getApplicationDocumentsDirectory();
      // Nombre único usando los milisegundos actuales, para que dos fotos nunca se llamen igual.
      final nombre = 'mascota_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final destino = p.join(carpeta.path, nombre);
      await File(foto.path).copy(destino);
      // Esta ruta es la que se guarda en SQLite (campo rutaImagen)
      return destino;
    } catch (e) {
      throw Exception(
          'No se pudo obtener la foto. Revisa los permisos de cámara/galería.');
    }
  }
}