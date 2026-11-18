import 'dart:convert';

class Traslado {
  final int? id;
  final String nombreMascota;
  final String tipoTraslado;
  final String indicaciones;
  final String rutaImagen;
  final double latitud;
  final double longitud;
  final String fecha;

  Traslado({
    this.id,
    required this.nombreMascota,
    required this.tipoTraslado,
    required this.indicaciones,
    required this.rutaImagen,
    required this.latitud,
    required this.longitud,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombreMascota': nombreMascota,
      'tipoTraslado': tipoTraslado,
      'indicaciones': indicaciones,
      'rutaImagen': rutaImagen,
      'latitud': latitud,
      'longitud': longitud,
      'fecha': fecha,
    };
  }

  factory Traslado.fromMap(Map<String, dynamic> map) {
    return Traslado(
      id: map['id'] as int?,
      nombreMascota: map['nombreMascota'] as String,
      tipoTraslado: map['tipoTraslado'] as String,
      indicaciones: map['indicaciones'] as String,
      rutaImagen: map['rutaImagen'] as String,
      latitud: (map['latitud'] as num).toDouble(),
      longitud: (map['longitud'] as num).toDouble(),
      fecha: map['fecha'] as String,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Traslado.fromJson(String fuente) =>
      Traslado.fromMap(jsonDecode(fuente) as Map<String, dynamic>);
}