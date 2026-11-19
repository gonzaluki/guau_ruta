import 'package:flutter/material.dart';
import 'screens/detail_screen.dart';
import 'screens/form_screen.dart';
import 'screens/home_screen.dart';


void main() {
  runApp(const GuauRutaApp());
}
// Widget raíz de la aplicación. Es StatelessWidget porque no guarda estado.
class GuauRutaApp extends StatelessWidget {
  const GuauRutaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp configura la app completa: título, tema y navegación.
    return MaterialApp(
      title: 'GuauRuta',
      debugShowCheckedModeBanner: false, // Quita la cinta roja "DEBUG"
      theme: ThemeData( // Genera toda la paleta de colores a partir de un color base.
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      // Rutas nombradas: se navega con Navigator.pushNamed(context, '/ruta')
      initialRoute: '/', // Pantalla con la que arranca la app
      routes: {
        '/': (context) => const HomeScreen(), // Lista principal
        '/formulario': (context) => const FormScreen(), // Crear traslado
        '/detalle': (context) => const DetailScreen(), // Ver un traslado
      },
    );
  }
}