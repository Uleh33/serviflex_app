import 'package:flutter/material.dart';
import '../screens/welcome_screen.dart';
import '../screens/client_home_screen.dart';
import '../screens/prof_dashboard_screen.dart';
import '../screens/my_requests_screen.dart';

class AppDrawer extends StatelessWidget {
  final String currentMode;
  const AppDrawer({super.key, required this.currentMode});

  @override
  Widget build(BuildContext context) {
    const Color oliveGreen = Color(0xFF3D5300);
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: oliveGreen),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 45, color: oliveGreen),
            ),
            accountName: const Text('Alejandro Pérez', style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: const Text('alejandro@serviflex.com'),
          ),
          ListTile(
            leading: const Icon(Icons.swap_horiz, color: oliveGreen),
            title: Text(currentMode == 'Cliente' ? 'Cambiar a Modo Profesional' : 'Cambiar a Modo Cliente'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => 
                currentMode == 'Cliente' ? const ProfDashboardScreen() : const ClientHomeScreen()
              ));
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión'),
            onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const WelcomeScreen()), (route) => false),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
