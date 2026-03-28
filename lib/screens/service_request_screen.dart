import 'package:flutter/material.dart';
import '../main.dart'; // To access globalRequests
import 'my_requests_screen.dart';

class ServiceRequestScreen extends StatefulWidget {
  final String categoryName;
  final bool isHourly;
  const ServiceRequestScreen({super.key, required this.categoryName, this.isHourly = false});
  @override
  State<ServiceRequestScreen> createState() => _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends State<ServiceRequestScreen> {
  String? selectedDistrict;
  final TextEditingController _descController = TextEditingController();
  final List<String> districts = ['Miraflores', 'San Isidro', 'Surco', 'La Molina', 'San Borja', 'Los Olivos'];

  @override
  Widget build(BuildContext context) {
    const Color oliveGreen = Color(0xFF3D5300);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text('Pedido: ${widget.categoryName}', style: const TextStyle(color: Colors.white)), backgroundColor: oliveGreen, iconTheme: const IconThemeData(color: Colors.white)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ubicación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.location_on)),
              hint: const Text('Selecciona distrito'),
              items: districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (v) => setState(() => selectedDistrict = v),
            ),
            const SizedBox(height: 25),
            Text(widget.isHourly ? 'Detalle del cuidado (mín. 15 letras)' : 'Descripción del problema', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _descController,
              maxLines: 4, maxLength: 200,
              decoration: InputDecoration(
                hintText: widget.isHourly ? 'Ej: Necesito acompañamiento para adulto mayor 4 horas...' : 'Mínimo 15 caracteres...', 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            if (widget.isHourly)
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: const Row(children: [Icon(Icons.info_outline, size: 16, color: Colors.blue), SizedBox(width: 10), Expanded(child: Text('Nota: Este servicio se tarifa por hora trabajada.', style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold)))]),
              ),
            const SizedBox(height: 10),
            const Row(children: [Icon(Icons.verified_user, size: 16, color: Colors.green), SizedBox(width: 5), Text('Pedido visto por profesionales certificados', style: TextStyle(fontSize: 11, color: Colors.grey))]),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 60,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedDistrict == null || _descController.text.length < 15) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, completa distrito y descripción (mín. 15 letras)'), backgroundColor: Colors.orange));
                    return;
                  }
                  globalRequests.add({'category': widget.categoryName, 'district': selectedDistrict!, 'description': _descController.text, 'status': 'Pendiente', 'isHourly': widget.isHourly});
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyRequestsScreen()));
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27B150), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('PUBLICAR SOLICITUD', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
