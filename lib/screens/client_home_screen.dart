import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../main.dart'; // To access globalRequests
import 'service_request_screen.dart';
import 'my_requests_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> categories = [
    {'name': 'Plomería', 'icon': Icons.plumbing, 'color': Colors.blue},
    {'name': 'Electricidad', 'icon': Icons.bolt, 'color': Colors.amber},
    {'name': 'Limpieza', 'icon': Icons.cleaning_services, 'color': Colors.cyan},
    {'name': 'Carpintería', 'icon': Icons.carpenter, 'color': Colors.orange},
    {'name': 'Jardinería', 'icon': Icons.yard, 'color': Colors.green},
    {'name': 'Pintura', 'icon': Icons.format_paint, 'color': Colors.purple},
    {'name': 'Vidriería', 'icon': Icons.window, 'color': Colors.lightBlue},
    {'name': 'Cerrajería', 'icon': Icons.vpn_key, 'color': Colors.blueGrey},
    {'name': 'Enfermería', 'icon': Icons.medical_services, 'color': Colors.redAccent, 'isHourly': true},
    {'name': 'Cuidadora', 'icon': Icons.volunteer_activism, 'color': Colors.pinkAccent, 'isHourly': true},
    {'name': 'Lavandería', 'icon': Icons.local_laundry_service, 'color': Colors.indigo},
    {'name': 'Computación', 'icon': Icons.laptop_mac, 'color': Colors.black87},
    {'name': 'Gasfitero', 'icon': Icons.fire_hydrant_alt, 'color': Colors.deepOrange},
    {'name': 'Aire Acond.', 'icon': Icons.ac_unit, 'color': Colors.blue},
    {'name': 'Albañilería', 'icon': Icons.foundation, 'color': Colors.brown},
    {'name': 'Fumigación', 'icon': Icons.bug_report, 'color': Colors.green},
    {'name': 'Mecánica', 'icon': Icons.build, 'color': Colors.red},
    {'name': 'Psicología', 'icon': Icons.psychology, 'color': Colors.teal, 'isHourly': true},
  ];

  @override
  void initState() {
    super.initState();
    // Ordenar alfabéticamente al iniciar
    categories.sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color oliveGreen = Color(0xFF3D5300);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Serviflex Lima', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: oliveGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const AppDrawer(currentMode: 'Cliente'),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                color: oliveGreen.withValues(alpha: 0.05),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '¿Qué servicio buscas?',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
              ),
              Expanded(
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true, // Hacer visible la barra de desplazamiento
                  thickness: 8,
                  radius: const Radius.circular(10),
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(15),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) => _buildCategoryCard(context, categories[index]),
                  ),
                ),
              ),
              // --- SECCIÓN DE SEGURIDAD ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                color: Colors.white,
                child: ListTile(
                  leading: const Icon(Icons.security, color: Colors.green, size: 30),
                  title: const Text("Técnicos Verificados", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Seguridad 24/7 para tu hogar"),
                  trailing: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Sistema de Reportes"),
                          content: const Text(
                              "En Serviflex, todos los técnicos pasan por un filtro de antecedentes. Si tienes algún problema, puedes reportarlo de inmediato y nuestro equipo de seguridad intervendrá."),
                          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Entendido"))],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    child: const Text("Saber más"),
                  ),
                ),
              ),
            ],
          ),
          if (globalRequests.isNotEmpty)
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: FloatingActionButton.extended(
                backgroundColor: const Color(0xFF27B150),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyRequestsScreen())),
                label: Text('Tienes ${globalRequests.length} pedido(s) activo(s)',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                icon: const Icon(Icons.sync, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> cat) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ServiceRequestScreen(categoryName: cat['name'], isHourly: cat['isHourly'] ?? false))),
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(cat['icon'], size: 40, color: cat['color']),
            const SizedBox(height: 10),
            Text(cat['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (cat['isHourly'] == true) const Text('(Por hora)', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
