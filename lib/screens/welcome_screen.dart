import 'package:flutter/material.dart';
import 'client_home_screen.dart';
import 'prof_dashboard_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color oliveGreen = Color(0xFF3D5300);
    const Color goldColor = Color(0xFFFFD700);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF27B150), Color(0xFF1E843D)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 1000),
                  tween: Tween<double>(begin: 0, end: 1),
                  curve: Curves.easeOutBack,
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: Transform.scale(scale: value, child: child),
                    );
                  },
                  child: const Column(
                    children: [
                      Icon(Icons.handyman_rounded, size: 80, color: Colors.white),
                      SizedBox(height: 10),
                      Text('SERVIFLEX', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 4)),
                      Text('Tu solución a un click', style: TextStyle(fontSize: 16, color: Colors.white70, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
                const Spacer(),
                _buildMainButton(
                  text: 'SOY CLIENTE',
                  bgColor: oliveGreen,
                  textColor: goldColor,
                  borderColor: goldColor,
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ClientHomeScreen())),
                ),
                const SizedBox(height: 20),
                _buildMainButton(
                  text: 'SOY PROFESIONAL',
                  bgColor: Colors.white,
                  textColor: oliveGreen,
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfDashboardScreen())),
                ),
                
                // --- BOTONES DE LOGIN SOCIAL ---
                const SizedBox(height: 40),
                const Text('O continúa con', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialIcon(Icons.g_mobiledata, Colors.red, "Google"),
                    const SizedBox(width: 25),
                    _socialIcon(Icons.phone_android, Colors.white, "SMS"),
                    const SizedBox(width: 25),
                    _socialIcon(Icons.email, Colors.white, "Email"),
                  ],
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon, Color color, String label) {
    return Column(
      children: [
        Container(
          width: 50, height: 50,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)]),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  Widget _buildMainButton({required String text, required Color bgColor, required Color textColor, Color? borderColor, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity, height: 65,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor, foregroundColor: textColor,
          side: borderColor != null ? BorderSide(color: borderColor, width: 2) : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 8,
        ),
        child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
