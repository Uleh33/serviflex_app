import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/welcome_screen.dart';

// --- BASE DE DATOS SIMULADA (Pronto será Firestore) ---
List<Map<String, dynamic>> globalRequests = [];

void main() async {
  // 1. Asegura que los widgets de Flutter estén listos
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Inicializa Firebase (Esto fallará hasta que hagamos el paso de la consola)
  // await Firebase.initializeApp(); 

  runApp(const ServiflexApp());
}

class ServiflexApp extends StatelessWidget {
  const ServiflexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Serviflex',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF27B150)),
        fontFamily: 'Roboto',
      ),
      home: const WelcomeScreen(),
    );
  }
}
