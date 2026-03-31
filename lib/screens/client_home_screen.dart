import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import 'service_request_screen.dart';

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    const Color oliveGreen = Color(0xFF3D5300);
    
    // Lista de categorías actualizada según pedido del usuario
    final List<Map<String, dynamic>> categories = [
      {'name': 'Comida', 'icon': Icons.restaurant, 'color': Colors.orange},
      {'name': 'Perfumes', 'icon': Icons.opacity, 'color': Colors.pink},
      {'name': 'Masajes', 'icon': Icons.spa, 'color': Colors.teal},
      {'name': 'Psicología', 'icon': Icons.psychology, 'color': Colors.indigo},
      {'name': 'Suplementos', 'icon': Icons.fitness_center, 'color': Colors.green},
      {'name': 'Mecánica', 'icon': Icons.car_repair, 'color': Colors.red},
      {'name': 'Plomería', 'icon': Icons.plumbing, 'color': Colors.blue},
      {'name': 'Electricidad', 'icon': Icons.bolt, 'color': Colors.amber},
      {'name': 'Limpieza', 'icon': Icons.cleaning_services, 'color': Colors.cyan},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Listo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
        backgroundColor: oliveGreen, 
        iconTheme: const IconThemeData(color: Colors.white)
      ),
      drawer: const AppDrawer(currentMode: 'Cliente'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text('¿Qué necesitas hoy?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 15), 
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                childAspectRatio: 1.2, 
                crossAxisSpacing: 10, 
                mainAxisSpacing: 10
              ), 
              itemCount: categories.length, 
              itemBuilder: (context, index) {
                final cat = categories[index];
                return Card(
                  elevation: 2, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), 
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15), 
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ServiceRequestScreen(categoryName: cat['name']))), 
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, 
                      children: [
                        Icon(cat['icon'], size: 40, color: cat['color']), 
                        const SizedBox(height: 8), 
                        Text(cat['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))
                      ]
                    )
                  )
                );
              }
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.verified_user, color: oliveGreen, size: 20),
                  SizedBox(width: 8),
                  Text('Especialistas verificados cerca', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                children: [
                  _buildNearbyTech('Juan M.', 'Mecánico', '4.9'),
                  _buildNearbyTech('Pedro R.', 'Plomero', '4.8'),
                  _buildNearbyTech('Luis G.', 'Electricista', '5.0'),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyTech(String name, String job, String rating) {
    return Card(
      margin: const EdgeInsets.only(right: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(job, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text('⭐ $rating', style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
