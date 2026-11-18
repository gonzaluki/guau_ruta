import 'package:flutter/material.dart';
import 'screens/detail_screen.dart';
import 'screens/form_screen.dart';
import 'screens/home_screen.dart';

// ============================================================
// PUNTO DE ENTRADA
// SOLID - SRP: main.dart solo configura la app y sus rutas.
// SOLID - OCP: para agregar una pantalla nueva basta con añadir
// una ruta al mapa, sin modificar las pantallas existentes.
// ============================================================
void main() {
  runApp(const GuauRutaApp());
}

class GuauRutaApp extends StatelessWidget {
  const GuauRutaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GuauRuta',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      // Rutas nombradas: se navega con Navigator.pushNamed(context, '/ruta')
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/formulario': (context) => const FormScreen(),
        '/detalle': (context) => const DetailScreen(),
      },
    );
  }
}