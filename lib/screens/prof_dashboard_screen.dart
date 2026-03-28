import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../main.dart'; // To access globalRequests

class ProfDashboardScreen extends StatelessWidget {
  const ProfDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    const Color oliveGreen = Color(0xFF3D5300);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Trabajo', style: TextStyle(color: Colors.white)), 
        backgroundColor: oliveGreen, 
        iconTheme: const IconThemeData(color: Colors.white)
      ),
      drawer: const AppDrawer(currentMode: 'Profesional'),
      body: globalRequests.isEmpty
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.engineering, size: 60, color: Colors.grey), Text('No hay solicitudes nuevas en Lima.')]))
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: globalRequests.length,
              itemBuilder: (context, index) {
                final req = globalRequests[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(req['category']!.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: oliveGreen)),
                          Text(req['isHourly'] == true ? 'S/ Hora' : 'S/ 50.00', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 18)),
                        ]),
                        const SizedBox(height: 10),
                        Text('📍 Distrito: ${req['district']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text(req['description']!),
                        const Divider(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Trabajo aceptado! El cliente recibirá una notificación.')));
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: oliveGreen, foregroundColor: Colors.white),
                            child: const Text('TOMAR TRABAJO'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
