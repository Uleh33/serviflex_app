import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_options.dart';

// Especialidad seleccionada para filtrar el panel profesional
String? professionalSpecialty;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
  } catch (e) {
    debugPrint("Firebase ya estaba listo.");
  }
  runApp(const TodoListoApp());
}

class TodoListoApp extends StatelessWidget {
  const TodoListoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo Listo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF27B150)),
        fontFamily: 'Roboto',
      ),
      home: FirebaseAuth.instance.currentUser != null ? const ClientHomeScreen() : const WelcomeScreen(),
    );
  }
}

// --- MENÚ LATERAL ---
class AppDrawer extends StatelessWidget {
  final String currentMode;
  const AppDrawer({super.key, required this.currentMode});

  @override
  Widget build(BuildContext context) {
    const Color oliveGreen = Color(0xFF3D5300);
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: oliveGreen),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null ? const Icon(Icons.person, size: 45, color: oliveGreen) : null,
            ),
            accountName: Text(user?.displayName ?? 'Usuario Invitado', style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(user?.email ?? 'soporte@todolisto.app'),
          ),
          ListTile(
            leading: const Icon(Icons.swap_horiz, color: oliveGreen),
            title: Text(currentMode == 'Cliente' ? 'Cambiar a Modo Profesional' : 'Cambiar a Modo Cliente'),
            onTap: () {
              Navigator.pop(context);
              if (currentMode == 'Cliente') {
                _showSpecialtyDialog(context);
              } else {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ClientHomeScreen()));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: oliveGreen),
            title: const Text('Mis Pedidos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyRequestsScreen()));
            },
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const WelcomeScreen()), (route) => false);
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showSpecialtyDialog(BuildContext context) {
    final List<String> categories = ['Mecánica', 'Plomería', 'Electricidad', 'Enfermería', 'Limpieza'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cuál es tu especialidad?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: categories.map((cat) => ListTile(
            leading: const Icon(Icons.star_outline, color: Color(0xFF3D5300)),
            title: Text(cat),
            onTap: () {
              professionalSpecialty = cat;
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfDashboardScreen()));
            },
          )).toList(),
        ),
      ),
    );
  }
}

// --- PANTALLA BIENVENIDA ---
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = false;
  Future<void> _signInWithGoogle() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: '494243542565-cdd79d13074bdaa73271cc.apps.googleusercontent.com',
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return; 
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ClientHomeScreen()));
    } catch (e) { 
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color oliveGreen = Color(0xFF3D5300);
    const Color goldColor = Color(0xFFFFD700);
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF27B150), Color(0xFF1E843D)]),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Icon(Icons.handyman_rounded, size: 80, color: Colors.white),
            const SizedBox(height: 10),
            const Text('TODO LISTO', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 4)),
            const Spacer(),
            if (_isLoading) const CircularProgressIndicator(color: Colors.white)
            else Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  _buildWelcomeButton('INGRESAR COMO CLIENTE', oliveGreen, goldColor, () {
                    if (FirebaseAuth.instance.currentUser == null) {
                      _signInWithGoogle();
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ClientHomeScreen()));
                    }
                  }),
                  const SizedBox(height: 20),
                  _buildWelcomeButton('MODO PROFESIONAL', Colors.white, oliveGreen, () {
                    _showSpecialtyDialog(context);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  void _showSpecialtyDialog(BuildContext context) {
    final List<String> cats = ['Mecánica', 'Plomería', 'Electricidad', 'Enfermería', 'Limpieza'];
    showDialog(context: context, builder: (context) => AlertDialog(title: const Text('Especialidad'), content: Column(mainAxisSize: MainAxisSize.min, children: cats.map((c) => ListTile(title: Text(c), onTap: () { professionalSpecialty = c; Navigator.pop(context); Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfDashboardScreen())); })).toList())));
  }

  Widget _buildWelcomeButton(String text, Color bg, Color tc, VoidCallback tap) {
    return SizedBox(width: double.infinity, height: 60, child: ElevatedButton(onPressed: tap, style: ElevatedButton.styleFrom(backgroundColor: bg, foregroundColor: tc, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold))));
  }
}

// --- HOME CLIENTE ---
class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    const Color oliveGreen = Color(0xFF3D5300);
    final List<Map<String, dynamic>> categories = [
      {'name': 'Mecánica', 'icon': Icons.build, 'color': Colors.red},
      {'name': 'Plomería', 'icon': Icons.plumbing, 'color': Colors.blue},
      {'name': 'Electricidad', 'icon': Icons.bolt, 'color': Colors.amber},
      {'name': 'Limpieza', 'icon': Icons.cleaning_services, 'color': Colors.cyan},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Todo Listo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: oliveGreen, iconTheme: const IconThemeData(color: Colors.white)),
      drawer: const AppDrawer(currentMode: 'Cliente'),
      body: GridView.builder(padding: const EdgeInsets.all(15), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.1, crossAxisSpacing: 12, mainAxisSpacing: 12), itemCount: categories.length, itemBuilder: (context, index) {
        final cat = categories[index];
        return Card(elevation: 4, child: InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ServiceRequestScreen(categoryName: cat['name']))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(cat['icon'], size: 40, color: cat['color']), const SizedBox(height: 10), Text(cat['name'], style: const TextStyle(fontWeight: FontWeight.bold))])));
      }),
    );
  }
}

// --- SOLICITUD ---
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

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    try {
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Foto adjuntada'), backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text('Ayuda en: ${widget.categoryName}')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Tu Ubicación', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          height: 150, width: double.infinity,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade300)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: _currentP == null 
              ? const Center(child: CircularProgressIndicator()) 
              : GoogleMap(
                  initialCameraPosition: CameraPosition(target: _currentP!, zoom: 15),
                  markers: {Marker(markerId: const MarkerId('curr'), position: _currentP!)},
                  myLocationEnabled: true,
                ),
          ),
        ),
        const SizedBox(height: 20),
        TextField(controller: _dist, decoration: const InputDecoration(labelText: 'Distrito / Referencia', prefixIcon: Icon(Icons.location_on))),
        const SizedBox(height: 15),
        TextField(controller: _model, decoration: const InputDecoration(labelText: 'Modelo / Equipo', hintText: 'Ej: Terios 2005 / Refri LG')),
        const SizedBox(height: 15),
        TextField(controller: _desc, maxLines: 3, decoration: const InputDecoration(labelText: 'Describe el problema', hintText: 'Iba manejando y...')),
        const SizedBox(height: 15),
        Row(
          children: [
            IconButton(onPressed: _takePhoto, icon: const Icon(Icons.camera_alt, color: Color(0xFF27B150))),
            const Text('Foto'),
            const SizedBox(width: 20),
            IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎤 Grabando contexto...'))), icon: const Icon(Icons.mic, color: Colors.red)),
            const Text('Audio'),
          ],
        ),
        const SizedBox(height: 30),
        SizedBox(width: double.infinity, height: 60, child: ElevatedButton(onPressed: _saving ? null : () async {
          if (_desc.text.length < 5 || _dist.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completa ubicación y descripción'), backgroundColor: Colors.orange));
            return;
          }
          setState(() => _saving = true);
          try {
            await FirebaseFirestore.instance.collection('pedidos').add({
              'category': widget.categoryName, 'district': _dist.text, 'model': _model.text, 'description': _desc.text, 'status': 'Pendiente',
              'userId': FirebaseAuth.instance.currentUser?.uid, 'userName': FirebaseAuth.instance.currentUser?.displayName, 'timestamp': FieldValue.serverTimestamp(),
              'lat': _currentP?.latitude, 'lng': _currentP?.longitude,
            });
            if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyRequestsScreen()));
          } catch (e) {
            if (mounted) setState(() => _saving = false);
          }
        }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27B150), foregroundColor: Colors.white), child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('SOLICITAR DIAGNÓSTICO')))
      ])),
    );
  }
}

// --- MIS PEDIDOS (CLIENTE) ---
class MyRequestsScreen extends StatelessWidget {
  const MyRequestsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Pedidos')),
      drawer: const AppDrawer(currentMode: 'Cliente'),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('pedidos').where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid).orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No tienes pedidos activos.'));
          return ListView.builder(padding: const EdgeInsets.all(15), itemCount: docs.length, itemBuilder: (context, index) {
            final req = docs[index].data() as Map<String, dynamic>;
            final reqId = docs[index].id;
            final status = req['status'];

            return Card(
              color: status == 'En Proceso' ? Colors.blue.shade50 : (status == 'Completado' || status == 'Calificado' ? Colors.green.shade50 : null),
              child: ExpansionTile(
                title: Text("${req['category']} - $status", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(req['district'] ?? ''),
                children: [
                  if (status == 'Pendiente') StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('ofertas').where('pedidoId', isEqualTo: reqId).snapshots(),
                    builder: (context, oSnap) {
                      if (!oSnap.hasData) return const Text('Buscando técnicos...');
                      final offers = oSnap.data!.docs;
                      if (offers.isEmpty) return const Padding(padding: EdgeInsets.all(15), child: Text('Esperando respuestas...'));
                      return Column(children: offers.map((o) {
                        final off = o.data() as Map<String, dynamic>;
                        return ListTile(
                          title: Row(children: [
                            Text("⭐ ${off['ratingTecnico'] ?? 'Nuevo'}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                            const Spacer(),
                            Text("S/ ${off['precio']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                          ]),
                          subtitle: Text("Trabajos: ${off['trabajosTecnico'] ?? 0} \nLlega en: ${off['tiempo']}\n${off['mensaje']}"),
                          trailing: ElevatedButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance.collection('pedidos').doc(reqId).update({'status': 'En Proceso', 'tecnicoId': off['tecnicoId'], 'nombreTecnico': off['nombreTecnico']});
                            }, 
                            child: const Text('ELEGIR')
                          ),
                        );
                      }).toList());
                    },
                  ) else ListTile(
                    title: Text('Experto: ${req['nombreTecnico']}'), 
                    trailing: ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(pedidoId: reqId, partnerName: req['nombreTecnico'], tecnicoId: req['tecnicoId'], isClient: true, currentStatus: status))), 
                      child: const Text('CHAT'),
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
}

// --- PANEL PROFESIONAL ---
class ProfDashboardScreen extends StatelessWidget {
  const ProfDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('TodoListo: $professionalSpecialty')),
      drawer: const AppDrawer(currentMode: 'Profesional'),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('pedidos').where('category', isEqualTo: professionalSpecialty).where('status', isNotEqualTo: 'Calificado').orderBy('status').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return Center(child: Text('No hay pedidos de $professionalSpecialty.'));
          return ListView.builder(padding: const EdgeInsets.all(15), itemCount: docs.length, itemBuilder: (context, index) {
            final req = docs[index].data() as Map<String, dynamic>;
            final reqId = docs[index].id;
            final isTaken = req['status'] == 'En Proceso' || req['status'] == 'Completado';
            if (isTaken && req['tecnicoId'] != FirebaseAuth.instance.currentUser?.uid) return const SizedBox.shrink();
            
            return Card(color: isTaken ? Colors.green.shade50 : null, child: ExpansionTile(
              title: Text(req['district'] ?? ''),
              subtitle: Text("Modelo: ${req['model']} - ${req['status']}"),
              children: [
                Padding(padding: const EdgeInsets.all(15), child: Column(children: [
                  Text(req['description'] ?? ''),
                  const SizedBox(height: 15),
                  if (!isTaken) ElevatedButton(onPressed: () => _sendOffer(context, reqId), child: const Text('ENVIAR SOLUCIÓN'))
                  else ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(pedidoId: reqId, partnerName: req['userName'] ?? 'Cliente', tecnicoId: FirebaseAuth.instance.currentUser!.uid, isClient: false, currentStatus: req['status']))), child: const Text('IR AL CHAT'))
                ])),
              ],
            ));
          });
        },
      ),
    );
  }

  void _sendOffer(BuildContext context, String id) async {
    final pC = TextEditingController(); final tC = TextEditingController(); final mC = TextEditingController();
    final profSnap = await FirebaseFirestore.instance.collection('perfiles').doc(FirebaseAuth.instance.currentUser?.uid).get();
    final profData = profSnap.data() ?? {};
    
    showDialog(context: context, builder: (context) => AlertDialog(title: const Text('Tu Oferta'), content: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: pC, decoration: const InputDecoration(labelText: 'Precio (S/)'), keyboardType: TextInputType.number),
      TextField(controller: tC, decoration: const InputDecoration(labelText: 'Tiempo de llegada')),
      TextField(controller: mC, decoration: const InputDecoration(labelText: 'Mensaje al cliente')),
    ]), actions: [ElevatedButton(onPressed: () async {
      await FirebaseFirestore.instance.collection('ofertas').add({
        'pedidoId': id, 'precio': pC.text, 'tiempo': tC.text, 'mensaje': mC.text,
        'tecnicoId': FirebaseAuth.instance.currentUser?.uid, 
        'nombreTecnico': FirebaseAuth.instance.currentUser?.displayName,
        'ratingTecnico': profData['rating']?.toStringAsFixed(1) ?? 'Nuevo',
        'trabajosTecnico': profData['trabajos'] ?? 0,
        'timestamp': FieldValue.serverTimestamp()
      });
      Navigator.pop(context);
    }, child: const Text('ENVIAR'))]));
  }
}

// --- CHAT + RATING + COMPLETION ---
class ChatScreen extends StatelessWidget {
  final String pedidoId; final String partnerName; final String? tecnicoId; final bool isClient; final String currentStatus;
  const ChatScreen({super.key, required this.pedidoId, required this.partnerName, this.tecnicoId, required this.isClient, required this.currentStatus});

  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('¡TodoListo!'),
        content: const Column(mainAxisSize: MainAxisSize.min, children: [
          Text('¿Cómo calificarías la ayuda?'),
          SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.star, color: Colors.amber), Icon(Icons.star, color: Colors.amber), Icon(Icons.star, color: Colors.amber), Icon(Icons.star, color: Colors.amber), Icon(Icons.star, color: Colors.amber)]),
        ]),
        actions: [ElevatedButton(onPressed: () async {
          if (tecnicoId != null) {
            final profRef = FirebaseFirestore.instance.collection('perfiles').doc(tecnicoId);
            await FirebaseFirestore.instance.runTransaction((tx) async {
              final snap = await tx.get(profRef);
              double newRating = 5.0;
              if (!snap.exists) {
                tx.set(profRef, {'rating': newRating, 'trabajos': 1, 'sumaRating': newRating});
              } else {
                double currentSum = (snap.data()!['sumaRating'] ?? 0.0).toDouble();
                int currentJobs = snap.data()!['trabajos'] ?? 0;
                double newSum = currentSum + newRating;
                int newJobs = currentJobs + 1;
                tx.update(profRef, {'trabajos': newJobs, 'sumaRating': newSum, 'rating': newSum / newJobs});
              }
            });
          }
          await FirebaseFirestore.instance.collection('pedidos').doc(pedidoId).update({'status': 'Calificado'});
          Navigator.pop(context); Navigator.pop(context);
        }, child: const Text('CALIFICAR'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final msgC = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: Text('Chat con $partnerName'), actions: [
        if (isClient && currentStatus == 'En Proceso') TextButton(onPressed: () async {
          await FirebaseFirestore.instance.collection('pedidos').doc(pedidoId).update({'status': 'Completado'});
        }, child: const Text('TERMINAR', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        if (isClient && currentStatus == 'Completado') ElevatedButton(onPressed: () => _showRatingDialog(context), child: const Text('CALIFICAR'))
      ]),
      body: Column(children: [
        if (currentStatus == 'Completado' && isClient) Container(width: double.infinity, color: Colors.orange.shade100, padding: const EdgeInsets.all(10), child: const Text('Servicio terminado. ¡Califica al experto!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
        Expanded(child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('pedidos').doc(pedidoId).collection('mensajes').orderBy('timestamp', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final msgs = snapshot.data!.docs;
            return ListView.builder(reverse: true, itemCount: msgs.length, itemBuilder: (context, index) {
              final m = msgs[index].data() as Map<String, dynamic>;
              final isMe = m['senderId'] == FirebaseAuth.instance.currentUser?.uid;
              return Container(alignment: isMe ? Alignment.centerRight : Alignment.centerLeft, padding: const EdgeInsets.all(10), child: Card(color: isMe ? const Color(0xFF27B150) : Colors.white, child: Padding(padding: const EdgeInsets.all(10), child: Text(m['texto'] ?? '', style: TextStyle(color: isMe ? Colors.white : Colors.black)))));
            });
          },
        )),
        if (currentStatus != 'Calificado') Padding(padding: const EdgeInsets.all(10), child: Row(children: [Expanded(child: TextField(controller: msgC, decoration: const InputDecoration(hintText: 'Escribe un mensaje...'))), IconButton(onPressed: () async {
          if (msgC.text.isEmpty) return;
          await FirebaseFirestore.instance.collection('pedidos').doc(pedidoId).collection('mensajes').add({'texto': msgC.text, 'senderId': FirebaseAuth.instance.currentUser?.uid, 'timestamp': FieldValue.serverTimestamp()});
          msgC.clear();
        }, icon: const Icon(Icons.send, color: Color(0xFF27B150)))]))
      ]),
    );
  }
}
