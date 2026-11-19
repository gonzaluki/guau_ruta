import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationService {
  Future<Position> obtenerPosicionActual() async {
    //primero hay que preguntarse si el gps está activo
    final gpsActivo = await Geolocator.isLocationServiceEnabled();
    if (!gpsActivo) {
      throw Exception('El GPS está apagado. Actívalo para continuar.');
    }
    // tengo hay que checar si tiene permiso de ubicación
    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

    if (permiso == LocationPermission.deniedForever) {
      throw Exception(
          'Permiso bloqueado. Actívalo en Ajustes > Apps > GuauRuta > Permisos.');
    }
    if (permiso == LocationPermission.denied) {
      throw Exception('Permiso de ubicación denegado.');
    }
    //y tercero, se leen las coordenadas actuales
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings:
        const LocationSettings(accuracy: LocationAccuracy.high), //acurraccy high para que estén bien precisas las coordenadas
      );
    } catch (e) {
      throw Exception('No se pudo obtener tu ubicación.');
    }
  }
  // abrirGoogleMaps(): pues abre Google Maps  apuntando a las coordenadas guardadas.
  Future<void> abrirGoogleMaps(double lat, double lng) async {
    try {
      final uri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
      final abierto =
      await launchUrl(uri, mode: LaunchMode.externalApplication); //externalApplication es porque abre fuera de la app
      if (!abierto) throw Exception('No se pudo abrir Google Maps.');
    } catch (e) {
      throw Exception('No se pudo abrir Google Maps.');
    }
  }
}