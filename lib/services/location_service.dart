import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationService {
  Future<Position> obtenerPosicionActual() async {
    final gpsActivo = await Geolocator.isLocationServiceEnabled();
    if (!gpsActivo) {
      throw Exception('El GPS está apagado. Actívalo para continuar.');
    }

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

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings:
        const LocationSettings(accuracy: LocationAccuracy.high),
      );
    } catch (e) {
      throw Exception('No se pudo obtener tu ubicación.');
    }
  }

  Future<void> abrirGoogleMaps(double lat, double lng) async {
    try {
      final uri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
      final abierto =
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!abierto) throw Exception('No se pudo abrir Google Maps.');
    } catch (e) {
      throw Exception('No se pudo abrir Google Maps.');
    }
  }
}