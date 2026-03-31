import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../screens/client_home_screen.dart';
import '../screens/prof_dashboard_screen.dart';
import '../screens/my_requests_screen.dart';
import '../screens/welcome_screen.dart';

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
              
              // Solución definitiva para google_sign_in 7.x
              // No creamos una instancia con (), usamos la fábrica que maneja el singleton internamente.
              try {
                final GoogleSignIn googleSignIn = GoogleSignIn();
                await googleSignIn.signOut();
              } catch (e) {
                debugPrint("Error al cerrar sesión con Google: $e");
              }
              
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
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfDashboardScreen(specialty: cat)));
            },
          )).toList(),
        ),
      ),
    );
  }
}
