import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/app_drawer.dart';
import 'chat_screen.dart';

class ProfDashboardScreen extends StatelessWidget {
  final String specialty;
  const ProfDashboardScreen({super.key, required this.specialty});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Panel: $specialty')),
      drawer: const AppDrawer(currentMode: 'Profesional'),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('pedidos')
            .where('category', isEqualTo: specialty)
            .where('status', isNotEqualTo: 'Calificado')
            .orderBy('status')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return Center(child: Padding(padding: const EdgeInsets.all(30.0), child: Text('No hay pedidos de $specialty en este momento. ¡Te avisaremos!', textAlign: TextAlign.center)));
          
          return ListView.builder(padding: const EdgeInsets.all(15), itemCount: docs.length, itemBuilder: (context, index) {
            final req = docs[index].data() as Map<String, dynamic>;
            final reqId = docs[index].id;
            final isTaken = req['status'] == 'En Proceso' || req['status'] == 'Completado';
            
            // Si está tomado por otro técnico, no mostrarlo
            if (isTaken && req['tecnicoId'] != FirebaseAuth.instance.currentUser?.uid) return const SizedBox.shrink();
            
            return Card(
              elevation: 3,
              color: isTaken ? Colors.green.shade50 : null, 
              child: ExpansionTile(
                title: Text(req['district'] ?? 'Ubicación no especificada', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Cliente: ${req['userName']} - ${req['status']}"),
                children: [
                  Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Descripción del problema:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(req['description'] ?? ''),
                    if (req['model'] != null && req['model'].toString().isNotEmpty) ...[const SizedBox(height: 10), Text("Equipo: ${req['model']}", style: const TextStyle(fontStyle: FontStyle.italic))],
                    const SizedBox(height: 15),
                    if (!isTaken) Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(icon: const Icon(Icons.send), onPressed: () => _sendOffer(context, reqId), label: const Text('ENVIAR PROPUESTA')),
                      ],
                    )
                    else ElevatedButton.icon(icon: const Icon(Icons.chat), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(pedidoId: reqId, partnerName: req['userName'] ?? 'Cliente', tecnicoId: FirebaseAuth.instance.currentUser!.uid, isClient: false, currentStatus: req['status']))), label: const Text('IR AL CHAT'))
                  ])),
                ],
              ),
            );
          });
        },
      ),
    );
  }

  void _sendOffer(BuildContext context, String id) async {
    final pC = TextEditingController(); 
    final tC = TextEditingController(); 
    final mC = TextEditingController();
    
    final profSnap = await FirebaseFirestore.instance.collection('perfiles').doc(FirebaseAuth.instance.currentUser?.uid).get();
    final profData = profSnap.data() ?? {};
    
    if (!context.mounted) return;

    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text('Enviar mi Propuesta'), 
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Define tus condiciones para este trabajo:', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 15),
          TextField(controller: pC, decoration: const InputDecoration(labelText: 'Precio sugerido (S/)', prefixText: 'S/ ', border: OutlineInputBorder()), keyboardType: TextInputType.number),
          const SizedBox(height: 10),
          TextField(controller: tC, decoration: const InputDecoration(labelText: '¿En cuánto tiempo llegas?', hintText: 'Ej: 20 min', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: mC, decoration: const InputDecoration(labelText: 'Mensaje al cliente', hintText: 'Ej: Soy experto en esto...', border: OutlineInputBorder()), maxLines: 2),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8)),
            child: const Row(children: [Icon(Icons.info_outline, size: 16, color: Colors.amber), SizedBox(width: 8), Expanded(child: Text('Se aplicará una comisión del 10% sobre el servicio final.', style: TextStyle(fontSize: 11)))]),
          )
        ]),
      ), 
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
        ElevatedButton(onPressed: () async {
          if (pC.text.isEmpty || tC.text.isEmpty) return;
          await FirebaseFirestore.instance.collection('ofertas').add({
            'pedidoId': id, 
            'precio': pC.text, 
            'tiempo': tC.text, 
            'mensaje': mC.text,
            'tecnicoId': FirebaseAuth.instance.currentUser?.uid, 
            'nombreTecnico': FirebaseAuth.instance.currentUser?.displayName ?? 'Técnico',
            'ratingTecnico': profData['rating']?.toStringAsFixed(1) ?? 'Nuevo',
            'trabajosTecnico': profData['trabajos'] ?? 0,
            'timestamp': FieldValue.serverTimestamp()
          });
          if (context.mounted) Navigator.pop(context);
        }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27B150), foregroundColor: Colors.white), child: const Text('ENVIAR'))
      ],
    ));
  }
}
