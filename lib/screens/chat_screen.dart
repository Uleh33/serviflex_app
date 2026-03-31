import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatelessWidget {
  final String pedidoId; 
  final String partnerName; 
  final String? tecnicoId; 
  final bool isClient; 
  final String currentStatus;
  
  const ChatScreen({
    super.key, 
    required this.pedidoId, 
    required this.partnerName, 
    this.tecnicoId, 
    required this.isClient, 
    required this.currentStatus
  });

  void _showRatingDialog(BuildContext context) {
    int selectedStars = 5;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('¡Servicio Completado!'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('¿Cómo calificarías la atención de tu técnico?'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, 
              children: List.generate(5, (index) => IconButton(
                icon: Icon(index < selectedStars ? Icons.star : Icons.star_border, color: Colors.amber, size: 30),
                onPressed: () => setState(() => selectedStars = index + 1),
              )),
            ),
          ]),
          actions: [ElevatedButton(onPressed: () async {
            if (tecnicoId != null) {
              final profRef = FirebaseFirestore.instance.collection('perfiles').doc(tecnicoId);
              await FirebaseFirestore.instance.runTransaction((tx) async {
                final snap = await tx.get(profRef);
                double ratingValue = selectedStars.toDouble();
                if (!snap.exists) {
                  tx.set(profRef, {'rating': ratingValue, 'trabajos': 1, 'sumaRating': ratingValue});
                } else {
                  double currentSum = (snap.data()!['sumaRating'] ?? 0.0).toDouble();
                  int currentJobs = snap.data()!['trabajos'] ?? 0;
                  double newSum = currentSum + ratingValue;
                  int newJobs = currentJobs + 1;
                  tx.update(profRef, {'trabajos': newJobs, 'sumaRating': newSum, 'rating': newSum / newJobs});
                }
              });
            }
            await FirebaseFirestore.instance.collection('pedidos').doc(pedidoId).update({'status': 'Calificado'});
            if (context.mounted) {
              Navigator.pop(context); 
              Navigator.pop(context);
            }
          }, child: const Text('ENVIAR CALIFICACIÓN'))],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final msgC = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text(partnerName), 
        actions: [
          if (isClient && currentStatus == 'En Proceso') Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.red.shade50),
              onPressed: () async {
                bool? confirm = await showDialog(context: context, builder: (context) => AlertDialog(title: const Text('¿Terminar servicio?'), content: const Text('Confirma si el técnico ya terminó el trabajo.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('NO')), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('SÍ, TERMINÓ'))]));
                if (confirm == true) {
                  await FirebaseFirestore.instance.collection('pedidos').doc(pedidoId).update({'status': 'Completado'});
                }
              }, 
              child: const Text('TERMINAR', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
            ),
          ),
          if (isClient && currentStatus == 'Completado') Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(onPressed: () => _showRatingDialog(context), child: const Text('CALIFICAR')),
          )
        ]
      ),
      body: Column(children: [
        if (currentStatus == 'Completado' && isClient) Container(width: double.infinity, color: Colors.orange.shade100, padding: const EdgeInsets.all(12), child: const Row(children: [Icon(Icons.info, color: Colors.orange), SizedBox(width: 10), Expanded(child: Text('Servicio terminado. Por favor califica al experto para cerrar la solicitud.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)))]))
        else if (currentStatus == 'En Proceso') Container(width: double.infinity, color: Colors.blue.shade50, padding: const EdgeInsets.all(8), child: const Text('💡 Coordinen detalles del servicio por aquí.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.blue))),
        
        Expanded(child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('pedidos').doc(pedidoId).collection('mensajes').orderBy('timestamp', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final msgs = snapshot.data!.docs;
            return ListView.builder(reverse: true, itemCount: msgs.length, itemBuilder: (context, index) {
              final m = msgs[index].data() as Map<String, dynamic>;
              final isMe = m['senderId'] == FirebaseAuth.instance.currentUser?.uid;
              return Container(alignment: isMe ? Alignment.centerRight : Alignment.centerLeft, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), child: Card(elevation: 1, color: isMe ? const Color(0xFF27B150) : Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12).copyWith(bottomRight: isMe ? Radius.zero : null, bottomLeft: !isMe ? Radius.zero : null)), child: Padding(padding: const EdgeInsets.all(12), child: Text(m['texto'] ?? '', style: TextStyle(color: isMe ? Colors.white : Colors.black87)))));
            });
          },
        )),
        if (currentStatus != 'Calificado') Padding(padding: const EdgeInsets.all(10), child: Row(children: [Expanded(child: TextField(controller: msgC, decoration: InputDecoration(hintText: 'Escribe un mensaje...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)), contentPadding: const EdgeInsets.symmetric(horizontal: 20)))), const SizedBox(width: 8), CircleAvatar(backgroundColor: const Color(0xFF27B150), child: IconButton(onPressed: () async {
          if (msgC.text.trim().isEmpty) return;
          await FirebaseFirestore.instance.collection('pedidos').doc(pedidoId).collection('mensajes').add({'texto': msgC.text, 'senderId': FirebaseAuth.instance.currentUser?.uid, 'timestamp': FieldValue.serverTimestamp()});
          msgC.clear();
        }, icon: const Icon(Icons.send, color: Colors.white, size: 20)))]))
      ]),
    );
  }
}
