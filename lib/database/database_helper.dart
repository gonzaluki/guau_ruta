import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/traslado_model.dart';

class DatabaseHelper {
  // PATRÓN SINGLETON: garantiza UNA sola instancia de esta clase en toda la app, así no se abren varias conexiones a la base de datos.
  static final DatabaseHelper instancia = DatabaseHelper._interno();
  DatabaseHelper._interno();

  static Database? _database;

  // GETTER "database": devuelve la conexión.
  Future<Database> get database async {
    _database ??= await _inicializarBD();
    return _database!; // ! asegura que ya no es null
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
      // db.insert recibe el nombre de la tabla y un Map con los valores
      return await db.insert('traslados', traslado.toMap());
    } catch (e) {
      throw Exception('No se pudo guardar el traslado.');
    }
  }

  //pues aquí muestra todos los Traslado
  Future<List<Traslado>> obtenerTraslados() async {
    try {
      final db = await database;
      final filas = await db.query('traslados', orderBy: 'id DESC');
      return filas.map((fila) => Traslado.fromMap(fila)).toList();
    } catch (e) {
      throw Exception('No se pudieron leer los traslados.');
    }
  } //devuelve una lista de Traslados del más reciente al más antiguo


  //aquí devuelve los traslados dependiendo si son veterinario o familiar
  Future<List<Traslado>> obtenerTrasladosPorCategoria(String categoria) async {
    try {
      final db = await database;
      final filas = await db.query(
        'traslados',
        where: 'tipoTraslado = ?', //El "?" se reemplaza por el valor de whereArgs. Esto evita inyección SQL (nunca se concatena texto directo en la consulta).
        whereArgs: [categoria],
        orderBy: 'id DESC',
      );
      return filas.map((fila) => Traslado.fromMap(fila)).toList();
    } catch (e) {
      throw Exception('No se pudo filtrar los traslados.');
    }
  }
}