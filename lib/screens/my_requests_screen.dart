import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../main.dart'; // To access globalRequests

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});
  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  void _showRatingDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Cómo fue el servicio?', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Column(mainAxisSize: MainAxisSize.min, children: [Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.star, color: Colors.amber, size: 30),Icon(Icons.star, color: Colors.amber, size: 30),Icon(Icons.star, color: Colors.amber, size: 30),Icon(Icons.star, color: Colors.amber, size: 30),Icon(Icons.star, color: Colors.amber, size: 30)]), SizedBox(height: 15), TextField(decoration: InputDecoration(hintText: 'Comentario opcional...', border: OutlineInputBorder()))]),
        actions: [ElevatedButton(onPressed: () { setState(() => globalRequests.removeAt(index)); Navigator.pop(context); }, child: const Text('ENVIAR OPINIÓN'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color oliveGreen = Color(0xFF3D5300);
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Pedidos', style: TextStyle(color: Colors.white)), backgroundColor: oliveGreen, iconTheme: const IconThemeData(color: Colors.white)),
      drawer: const AppDrawer(currentMode: 'Cliente'),
      body: globalRequests.isEmpty
          ? const Center(child: Text('No tienes pedidos activos.'))
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: globalRequests.length,
              itemBuilder: (context, index) {
                final req = globalRequests[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    title: Text(req['category']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('📍 ${req['district']}\n${req['description']}${req['isHourly'] == true ? '\n(Tarifa por hora)' : ''}'),
                    trailing: TextButton(onPressed: () => _showRatingDialog(index), child: const Text('CALIFICAR', style: TextStyle(color: Colors.green))),
                  ),
                );
              },
            ),
    );
  }
}
