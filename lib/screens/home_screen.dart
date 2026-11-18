import 'dart:io';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/traslado_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filtro = 'Todos';
  late Future<List<Traslado>> _futuroTraslados;

  @override
  void initState() {
    super.initState();
    _futuroTraslados = _cargarTraslados();
  }

  Future<List<Traslado>> _cargarTraslados() async {
    try {
      if (_filtro == 'Todos') {
        return await DatabaseHelper.instancia.obtenerTraslados();
      }
      return await DatabaseHelper.instancia
          .obtenerTrasladosPorCategoria(_filtro);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
      return [];
    }
  }

  void _cambiarFiltro(String nuevoFiltro) {
    setState(() {
      _filtro = nuevoFiltro;
      _futuroTraslados = _cargarTraslados();
    });
    Navigator.pop(context);
  }

  Future<void> _irAFormulario() async {
    final guardado = await Navigator.pushNamed(context, '/formulario');
    if (guardado == true) {
      setState(() {
        _futuroTraslados = _cargarTraslados();
      });
    }
  }

  Widget _opcionDrawer(String titulo, IconData icono) {
    return ListTile(
      leading: Icon(icono),
      title: Text(titulo),
      selected: _filtro == titulo,
      onTap: () => _cambiarFiltro(titulo),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('GuauRuta - $_filtro')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text('🐾 GuauRuta',
                    style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
            ),
            _opcionDrawer('Todos', Icons.list),
            _opcionDrawer('Veterinario', Icons.local_hospital),
            _opcionDrawer('Familiar', Icons.family_restroom),
          ],
        ),
      ),
      body: FutureBuilder<List<Traslado>>(
        future: _futuroTraslados,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final traslados = snapshot.data ?? [];
          if (traslados.isEmpty) {
            return const Center(child: Text('No hay traslados registrados.'));
          }
          return ListView.builder(
            itemCount: traslados.length,
            itemBuilder: (context, i) => _tarjeta(traslados[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _irAFormulario,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _tarjeta(Traslado t) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Hero(
          tag: 'foto_${t.id}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: t.rutaImagen.isNotEmpty
                ? Image.file(File(t.rutaImagen),
                width: 56, height: 56, fit: BoxFit.cover)
                : Container(
              width: 56,
              height: 56,
              color: Colors.teal.shade100,
              child: const Icon(Icons.pets),
            ),
          ),
        ),
        title: Text(t.nombreMascota),
        subtitle: Text('${t.tipoTraslado} • ${t.fecha.substring(0, 10)}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(context, '/detalle', arguments: t),
      ),
    );
  }
}