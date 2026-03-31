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
      appBar: AppBar(
        title: Text('Panel: $specialty'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => {}, // StreamBuilder lo hace automático
          )
        ],
      ),
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
            final currentUserId = FirebaseAuth.instance.currentUser?.uid;

            if (isTaken && req['tecnicoId'] != currentUserId) return const SizedBox.shrink();
            
            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 15),
              color: isTaken ? Colors.green.shade50 : null, 
              child: ExpansionTile(
                leading: Icon(isTaken ? Icons.engineering : Icons.pending_actions, color: isTaken ? Colors.green : Colors.orange),
                title: Text(req['district'] ?? 'Ubicación no especificada', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Cliente: ${req['userName']} - ${req['status']}"),
                children: [
                  Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Problema reportado:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 5),
                    Text(req['description'] ?? '', style: const TextStyle(fontSize: 16)),
                    if (req['model'] != null && req['model'].toString().isNotEmpty) ...[
                      const SizedBox(height: 10), 
                      Text("Equipo: ${req['model']}", style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey))
                    ],
                    const SizedBox(height: 20),
                    if (!isTaken) Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.send_rounded), 
                          onPressed: () => _sendOffer(context, reqId), 
                          label: const Text('ENVIAR PROPUESTA'),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27B150), foregroundColor: Colors.white),
                        ),
                      ],
                    )
                    else if (currentUserId != null) ElevatedButton.icon(
                      icon: const Icon(Icons.chat), 
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(pedidoId: reqId, partnerName: req['userName'] ?? 'Cliente', tecnicoId: currentUserId, isClient: false, currentStatus: req['status']))), 
                      label: const Text('IR AL CHAT'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                    )
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
      title: const Text('Tu Propuesta Ganadora'), 
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Oferta rápida:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [50, 100, 150].map((monto) => ActionChip(
              label: Text('S/ $monto'),
              onPressed: () => pC.text = monto.toString(),
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
            )).toList(),
          ),
          const SizedBox(height: 15),
          TextField(controller: pC, decoration: const InputDecoration(labelText: '¿Cuánto cobrarás? (S/)', prefixText: 'S/ ', border: OutlineInputBorder()), keyboardType: TextInputType.number),
          const SizedBox(height: 10),
          TextField(controller: tC, decoration: const InputDecoration(labelText: '¿En cuánto tiempo terminas?', hintText: 'Ej: 15 días', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: mC, decoration: const InputDecoration(labelText: 'Mensaje de confianza', hintText: 'Ej: Tengo 10 años de experiencia...', border: OutlineInputBorder()), maxLines: 2),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade200)),
            child: const Row(children: [Icon(Icons.info_outline, size: 16, color: Colors.orange), SizedBox(width: 8), Expanded(child: Text('Recuerda: comisión del 10% para la plataforma.', style: TextStyle(fontSize: 11)))]),
          )
        ]),
      ), 
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
        ElevatedButton(
          onPressed: () async {
            if (pC.text.isEmpty || tC.text.isEmpty) return;
            await FirebaseFirestore.instance.collection('ofertas').add({
              'pedidoId': id, 
              'precio': pC.text, 
              'tiempo': tC.text, 
              'mensaje': mC.text,
              'tecnicoId': FirebaseAuth.instance.currentUser?.uid, 
              'nombreTecnico': FirebaseAuth.instance.currentUser?.displayName ?? 'Técnico Especialista',
              'ratingTecnico': profData['rating']?.toStringAsFixed(1) ?? 'Nuevo',
              'trabajosTecnico': profData['trabajos'] ?? 0,
              'timestamp': FieldValue.serverTimestamp()
            });
            if (context.mounted) Navigator.pop(context);
          }, 
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27B150), foregroundColor: Colors.white), 
          child: const Text('ENVIAR OFERTA')
        )
      ],
    ));
  }
}
