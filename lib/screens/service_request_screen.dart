import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'my_requests_screen.dart';

class ServiceRequestScreen extends StatefulWidget {
  final String categoryName;
  const ServiceRequestScreen({super.key, required this.categoryName});
  @override
  State<ServiceRequestScreen> createState() => _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends State<ServiceRequestScreen> {
  final TextEditingController _desc = TextEditingController();
  final TextEditingController _model = TextEditingController();
  final TextEditingController _dist = TextEditingController();
  bool _saving = false;
  LatLng? _currentP;
  bool _photoAttached = false;
  
  // Audio Recording Simulation States
  bool _isRecording = false;
  bool _audioRecorded = false;
  int _recordSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      Position position = await Geolocator.getCurrentPosition();
      if (mounted) setState(() => _currentP = LatLng(position.latitude, position.longitude));
    } catch (e) {
      debugPrint("GPS error: $e");
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null && mounted) {
      setState(() => _photoAttached = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ ¡Excelente! Foto adjuntada con éxito.'), 
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        )
      );
    }
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _audioRecorded = false;
      _recordSeconds = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordSeconds++;
      });
    });
  }

  void _stopRecording() {
    _timer?.cancel();
    setState(() {
      _isRecording = false;
      _audioRecorded = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Tu audio ha sido guardado correctamente.'), 
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      )
    );
  }

  void _deleteAudio() {
    setState(() {
      _audioRecorded = false;
      _recordSeconds = 0;
    });
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Ayuda en: ${widget.categoryName}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            // Guía inicial (UX Mamá)
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF27B150)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Para ayudarte mejor, dinos dónde estás y qué necesitas. ¡Es muy fácil!',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF27B150), size: 20),
                const SizedBox(width: 8),
                const Text('¿Dónde te encuentras?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Text(
              'Usamos tu ubicación para enviarte al técnico más cercano y ahorrar tiempo.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Container(
              height: 150, width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15), 
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: _currentP == null 
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.map_outlined, size: 40, color: Colors.grey),
                        const SizedBox(height: 8),
                        const Text('Buscando señal GPS...', style: TextStyle(color: Colors.grey)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Si no carga, no te preocupes, escribe tu distrito abajo.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, color: Colors.orange),
                          ),
                        ),
                        TextButton(onPressed: _getLocation, child: const Text('Reintentar GPS'))
                      ],
                    ) 
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(target: _currentP!, zoom: 15),
                      markers: {Marker(markerId: const MarkerId('curr'), position: _currentP!)},
                      myLocationEnabled: true,
                    ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Campos obligatorios vs opcionales (UX Padrastro/Lilith)
            TextField(
              controller: _dist, 
              decoration: const InputDecoration(
                labelText: 'Distrito / Referencia *', 
                hintText: 'Ej: Altura cuadra 10 Av. Larco', 
                helperText: '* Campo obligatorio para que el técnico llegue.',
                prefixIcon: Icon(Icons.map_outlined)
              )
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _model, 
              decoration: const InputDecoration(
                labelText: 'Modelo / Equipo (Opcional)', 
                hintText: 'Ej: Toyota Yaris 2018 / Refri Samsung', 
                prefixIcon: Icon(Icons.info_outline)
              )
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _desc, 
              maxLines: 4, 
              decoration: const InputDecoration(
                labelText: 'Describe el problema *', 
                hintText: 'Cuéntanos qué sucede con tus propias palabras...', 
                alignLabelWithHint: true,
                helperText: '* Explícanos lo que sientes que falla.'
              )
            ),
            const SizedBox(height: 25),

            const Text('Adjuntar fotos o audio (Opcional)', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('Esto ayuda a los expertos a darte un mejor precio.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAttachButton(
                  icon: Icons.camera_alt, 
                  label: 'Foto', 
                  color: Colors.green, 
                  isDone: _photoAttached,
                  onTap: _takePhoto
                ),
                if (!_isRecording && !_audioRecorded)
                  _buildAttachButton(
                    icon: Icons.mic, 
                    label: 'Audio', 
                    color: Colors.red, 
                    isDone: false,
                    onTap: _startRecording
                  )
                else if (_isRecording)
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _stopRecording,
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.red.withValues(alpha: 0.1),
                          child: const Icon(Icons.stop, color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(_formatDuration(_recordSeconds), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  )
                else if (_audioRecorded)
                  Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.green.withValues(alpha: 0.1),
                            child: const Icon(Icons.play_arrow, color: Colors.green),
                          ),
                          IconButton(onPressed: _deleteAudio, icon: const Icon(Icons.delete, color: Colors.grey, size: 20)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text('Listo (${_formatDuration(_recordSeconds)})', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity, 
              height: 60, 
              child: ElevatedButton(
                onPressed: _saving ? null : _submitRequest, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27B150), 
                  foregroundColor: Colors.white, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ), 
                child: _saving 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('ENVIAR SOLICITUD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
              )
            ),
            const SizedBox(height: 20),
          ]
        )
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (_desc.text.trim().length < 5 || _dist.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Por favor, completa los campos marcados con *'), 
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        )
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('pedidos').add({
        'category': widget.categoryName, 
        'district': _dist.text, 
        'model': _model.text, 
        'description': _desc.text, 
        'status': 'Pendiente',
        'userId': FirebaseAuth.instance.currentUser?.uid, 
        'userName': FirebaseAuth.instance.currentUser?.displayName ?? 'Cliente Anónimo', 
        'timestamp': FieldValue.serverTimestamp(),
        'lat': _currentP?.latitude, 
        'lng': _currentP?.longitude,
        'hasPhoto': _photoAttached, 
        'hasAudio': _audioRecorded,
        'audioDuration': _recordSeconds,
      });
      if (!mounted) return;
      
      // Diálogo de confirmación cálido (UX Mamá)
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Icon(Icons.check_circle, color: Color(0xFF27B150), size: 60),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¡Todo Listo!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Tu pedido ha sido enviado con éxito. Pronto recibirás propuestas de expertos verificados.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyRequestsScreen()));
                },
                child: const Text('VER MIS PEDIDOS'),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    }
  }

  Widget _buildAttachButton({required IconData icon, required String label, required Color color, required bool isDone, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: isDone ? Colors.green.withValues(alpha: 0.1) : color.withValues(alpha: 0.1),
            child: Icon(isDone ? Icons.check_circle : icon, color: isDone ? Colors.green : color),
          ),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(color: isDone ? Colors.green : Colors.black87, fontWeight: isDone ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
