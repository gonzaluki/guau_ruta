import 'dart:convert';
// Todos los campos son "final": una vez creado el objeto no cambian (objeto inmutable, más seguro y fácil de entender).
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

  // SQLite no entiende objetos de Dart, solo Maps. Las claves deben llamarse igual que las columnas de la tabla 'traslados'.

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

  // fromMap(): hace lo contrario que toMap(). Recibe un Map y construye un objeto Traslado.

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
  // Se lee como "num" y se convierte a double porque SQLite podría devolver un entero cuando la coordenada no tiene decimales.
  String toJson() => jsonEncode(toMap());

  factory Traslado.fromJson(String fuente) =>
      Traslado.fromMap(jsonDecode(fuente) as Map<String, dynamic>);
}