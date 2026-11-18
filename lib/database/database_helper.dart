import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/traslado_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instancia = DatabaseHelper._interno();
  DatabaseHelper._interno();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _inicializarBD();
    return _database!;
  }

  Future<Database> _inicializarBD() async {
    try {
      final carpeta = await getDatabasesPath();
      final ruta = join(carpeta, 'guauruta.db');

      return await openDatabase(
        ruta,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE traslados (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nombreMascota TEXT NOT NULL,
              tipoTraslado TEXT NOT NULL,
              indicaciones TEXT NOT NULL,
              rutaImagen TEXT NOT NULL,
              latitud REAL NOT NULL,
              longitud REAL NOT NULL,
              fecha TEXT NOT NULL
            )
          ''');
        },
      );
    } catch (e) {
      throw Exception('No se pudo abrir la base de datos.');
    }
  }

  Future<int> insertarTraslado(Traslado traslado) async {
    try {
      final db = await database;
      return await db.insert('traslados', traslado.toMap());
    } catch (e) {
      throw Exception('No se pudo guardar el traslado.');
    }
  }

  Future<List<Traslado>> obtenerTraslados() async {
    try {
      final db = await database;
      final filas = await db.query('traslados', orderBy: 'id DESC');
      return filas.map((fila) => Traslado.fromMap(fila)).toList();
    } catch (e) {
      throw Exception('No se pudieron leer los traslados.');
    }
  }

  Future<List<Traslado>> obtenerTrasladosPorCategoria(String categoria) async {
    try {
      final db = await database;
      final filas = await db.query(
        'traslados',
        where: 'tipoTraslado = ?',
        whereArgs: [categoria],
        orderBy: 'id DESC',
      );
      return filas.map((fila) => Traslado.fromMap(fila)).toList();
    } catch (e) {
      throw Exception('No se pudo filtrar los traslados.');
    }
  }
}