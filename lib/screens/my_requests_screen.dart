import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/app_drawer.dart';
import 'chat_screen.dart';

class MyRequestsScreen extends StatelessWidget {
  const MyRequestsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Solicitudes')),
      drawer: const AppDrawer(currentMode: 'Cliente'),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('pedidos').where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid).orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(30.0), child: Text('Aún no has solicitado servicios. ¡Tus solicitudes aparecerán aquí!', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey))));
          
          return ListView.builder(padding: const EdgeInsets.all(15), itemCount: docs.length, itemBuilder: (context, index) {
            final req = docs[index].data() as Map<String, dynamic>;
            final reqId = docs[index].id;
            final status = req['status'];

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              color: status == 'En Proceso' ? Colors.blue.shade50 : (status == 'Completado' || status == 'Calificado' ? Colors.green.shade50 : null),
              child: ExpansionTile(
                leading: CircleAvatar(backgroundColor: _getStatusColor(status), child: Icon(_getStatusIcon(status), color: Colors.white, size: 20)),
                title: Text("${req['category']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Estado: $status \n${req['district'] ?? ''}"),
                children: [
                  if (status == 'Pendiente') _buildOffersSection(reqId)
                  else ListTile(
                    leading: const Icon(Icons.verified, color: Colors.blue),
                    title: Text('Experto: ${req['nombreTecnico']}'), 
                    subtitle: const Text('Técnico Verificado ✅'),
                    trailing: ElevatedButton.icon(
                      icon: const Icon(Icons.chat),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(pedidoId: reqId, partnerName: req['nombreTecnico'], tecnicoId: req['tecnicoId'], isClient: true, currentStatus: status))), 
                      label: const Text('CHAT'),
                    ),
                  )
                ],
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildOffersSection(String reqId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('ofertas').where('pedidoId', isEqualTo: reqId).snapshots(),
      builder: (context, oSnap) {
        if (!oSnap.hasData) return const LinearProgressIndicator();
        final offers = oSnap.data!.docs;
        if (offers.isEmpty) return const Padding(padding: EdgeInsets.all(20), child: Column(children: [CircularProgressIndicator(strokeWidth: 2), SizedBox(height: 10), Text('Buscando técnicos cercanos...', style: TextStyle(fontStyle: FontStyle.italic))]));
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Text('Propuestas recibidas:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
            ...offers.map((o) {
              final off = o.data() as Map<String, dynamic>;
              return ListTile(
                isThreeLine: true,
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Row(children: [
                  Text(off['nombreTecnico'] ?? 'Técnico', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 5),
                  const Icon(Icons.verified, size: 14, color: Colors.blue),
                  const Spacer(),
                  Text("S/ ${off['precio']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF27B150), fontSize: 18)),
                ]),
                subtitle: Text("⭐ ${off['ratingTecnico'] ?? 'Nuevo'} | ${off['trabajosTecnico'] ?? 0} trabajos\nLlega en: ${off['tiempo']}\n\"${off['mensaje']}\""),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  onPressed: () async {
                    await FirebaseFirestore.instance.collection('pedidos').doc(reqId).update({'status': 'En Proceso', 'tecnicoId': off['tecnicoId'], 'nombreTecnico': off['nombreTecnico']});
                  }, 
                  child: const Text('ELEGIR')
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Pendiente': return Colors.orange;
      case 'En Proceso': return Colors.blue;
      case 'Completado': return Colors.green;
      case 'Calificado': return Colors.grey;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'Pendiente': return Icons.hourglass_empty;
      case 'En Proceso': return Icons.engineering;
      case 'Completado': return Icons.check;
      case 'Calificado': return Icons.star;
      default: return Icons.info;
    }
  }
}
