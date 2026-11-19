import 'dart:io';
import 'package:flutter/material.dart';
import '../models/traslado_model.dart';
import '../services/location_service.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});
  // se usa context.mounted para comprobar que la pantalla sigue viva
  Future<void> _abrirMapa(BuildContext context, Traslado t) async {
    try {
      await LocationService().abrirGoogleMaps(t.latitud, t.longitud);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Recupera el Traslado que HomeScreen envió en "arguments" al navegar con pushNamed
    final traslado = ModalRoute.of(context)!.settings.arguments as Traslado;

    return Scaffold(
      appBar: AppBar(title: Text(traslado.nombreMascota)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // hero con el mismo tag que usó la tarjeta en HomeScreen ('foto_$id').
            Center(
              child: Hero(
                tag: 'foto_${traslado.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: traslado.rutaImagen.isNotEmpty
                      ? Image.file(File(traslado.rutaImagen),
                      width: 280, height: 280, fit: BoxFit.cover)
                      : Container(
                    width: 280,
                    height: 280,
                    color: Colors.teal.shade100,
                    child: const Icon(Icons.pets, size: 100),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Tipo de traslado: ${traslado.tipoTraslado}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
                'Fecha: ${traslado.fecha.substring(0, 16).replaceAll('T', ' ')}'),
            const SizedBox(height: 16),
            const Text('Indicaciones de cuidado:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(traslado.indicaciones),
            const SizedBox(height: 16),
            const Text('Ubicación registrada:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Latitud: ${traslado.latitud.toStringAsFixed(6)}'),
            Text('Longitud: ${traslado.longitud.toStringAsFixed(6)}'),
            const SizedBox(height: 20),
            //botón que abre google maps con las coordenadas guardadas
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _abrirMapa(context, traslado),
                icon: const Icon(Icons.map),
                label: const Text('Abrir en Google Maps'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}