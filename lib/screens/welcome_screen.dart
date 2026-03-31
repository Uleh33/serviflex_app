import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:serviflex_app/mocks/html_mock.dart' if (dart.library.html) 'dart:html' as html;
import 'client_home_screen.dart';
import 'prof_dashboard_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = false;

  Future<void> _signInAnonymously() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInAnonymously();
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ClientHomeScreen()));
    } catch (e) { 
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _downloadAPK() {
    if (kIsWeb) {
      // Abre el archivo APK para descarga. 
      // Recuerda colocar el archivo app-release.apk en la carpeta 'web/' del proyecto.
      html.window.open('app-release.apk', '_blank');
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
          gradient: LinearGradient(
            begin: Alignment.topCenter, 
            end: Alignment.bottomCenter, 
            colors: [Color(0xFF27B150), Color(0xFF1E843D)]
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Icon(Icons.handyman_rounded, size: 80, color: Colors.white),
            const SizedBox(height: 10),
            const Text('TODO LISTO', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 4)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Técnicos verificados a un clic para solucionar tus problemas del hogar.', 
                textAlign: TextAlign.center, 
                style: TextStyle(color: Colors.white70, fontSize: 16)
              ),
            ),
            const Spacer(),
            if (_isLoading) 
              const CircularProgressIndicator(color: Colors.white)
            else 
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    _buildWelcomeButton('NECESITO UN TÉCNICO', oliveGreen, goldColor, () {
                      _signInAnonymously();
                    }),
                    const SizedBox(height: 20),
                    _buildWelcomeButton('SOY PROFESIONAL', Colors.white, oliveGreen, () {
                      _showSpecialtyDialog(context);
                    }),
                    
                    if (kIsWeb) ...[
                      const SizedBox(height: 25),
                      TextButton.icon(
                        onPressed: _downloadAPK,
                        icon: const Icon(Icons.android, color: Colors.white70),
                        label: const Text(
                          'DESCARGAR APP (APK) PARA ANDROID',
                          style: TextStyle(
                            color: Colors.white70, 
                            fontSize: 12, 
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ]
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
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text('¿Cuál es tu especialidad?'), 
        content: Column(
          mainAxisSize: MainAxisSize.min, 
          children: cats.map((c) => ListTile(
            leading: const Icon(Icons.star_border, color: Color(0xFF3D5300)),
            title: Text(c), 
            onTap: () { 
              Navigator.pop(context); 
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfDashboardScreen(specialty: c))); 
            }
          )).toList()
        )
      )
    );
  }

  Widget _buildWelcomeButton(String text, Color bg, Color tc, VoidCallback tap) {
    return SizedBox(
      width: double.infinity, 
      height: 60, 
      child: ElevatedButton(
        onPressed: tap, 
        style: ElevatedButton.styleFrom(
          backgroundColor: bg, 
          foregroundColor: tc, 
          elevation: 5, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
        ), 
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
      )
    );
  }
}
