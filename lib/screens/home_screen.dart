import 'dart:io';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/traslado_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  //createState crea el objeto que va a guardar el estado en la pantalla
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filtro = 'Todos'; //veterinario o familiar
  late Future<List<Traslado>> _futuroTraslados;

  // initState(): se ejecuta UNA vez al crear la pantalla. Aquí se lanza la primera carga de datos.
  @override
  void initState() {
    super.initState();
    _futuroTraslados = _cargarTraslados();
  }

  //aquí pide a la base de datos los traslados existentes del tipo seleccionado
  Future<List<Traslado>> _cargarTraslados() async {
    try {
      if (_filtro == 'Todos') {
        return await DatabaseHelper.instancia.obtenerTraslados();
      }
      return await DatabaseHelper.instancia
          .obtenerTrasladosPorCategoria(_filtro);
    } catch (e) {
      //"mounted" confirma que la pantalla sigue existiendo antes de usar el context; evita errores si el usuario ya salió de ella.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
      return [];
    }
  }

  void _cambiarFiltro(String nuevoFiltro) {
    // setState() avisa a Flutter que algo cambió y debe redibujar la pantalla
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
  // _opcionDrawer(): construye una opción del menú lateral.
  // "selected" resalta la opción que coincide con el filtro actual.
  Widget _opcionDrawer(String titulo, IconData icono) {
    return ListTile(
      leading: Icon(icono),
      title: Text(titulo),
      selected: _filtro == titulo,
      onTap: () => _cambiarFiltro(titulo),
    );
  }
  // build() dibuja la pantalla y Flutter lo vuelve a llamar cada vez que se ejecuta setState()
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('GuauRuta - $_filtro')),
      //menú lateral
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
          //1: sigue cargando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          //2. terminó de cargar
          final traslados = snapshot.data ?? [];
          if (traslados.isEmpty) {
            return const Center(child: Text('No hay traslados registrados.'));
          }
          //3. si hay datos pone la lista
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
        // El tag debe ser ÚNICO por registro (por eso usa el id) y debe ser igual en el Hero de DetailScreen para que Flutter los relacione.
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