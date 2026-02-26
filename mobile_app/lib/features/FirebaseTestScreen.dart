import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  // Controladores para los campos de texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _status = "Esperando acción...";
  Map<String, dynamic>? _userData;

  // 1. FUNCIÓN DE LOGIN
  Future<void> _loginTest() async {
    setState(() => _status = "Intentando login...");
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      setState(
        () => _status = "✅ Login exitoso: ${userCredential.user?.email}",
      );

      // Si el login funciona, intentamos traer los datos de Firestore automáticamente
      _fetchUserData(userCredential.user!.uid);
    } catch (e) {
      setState(() => _status = "❌ Error Auth: $e");
    }
  }

  // 2. FUNCIÓN DE LECTURA DE FIRESTORE
  Future<void> _fetchUserData(String uid) async {
    try {
      // IMPORTANTE: Asegúrate de que tu colección se llame 'usuarios' en la consola
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();

      if (doc.exists) {
        setState(() {
          _userData = doc.data() as Map<String, dynamic>;
          _status += "\n✅ Datos de Firestore cargados.";
        });
      } else {
        setState(
          () =>
              _status += "\n❓ No existe documento para este UID en Firestore.",
        );
      }
    } catch (e) {
      setState(() => _status += "\n❌ Error Firestore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RutexGo - Test Firebase"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Prueba de Conexión RutexGo",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Campos de texto
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email del Turista",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Contraseña",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _loginTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Probar Login y Firestore"),
              ),

              const Divider(height: 40),

              // Panel de Estado
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Estado:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_status),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Panel de Datos del Usuario
              if (_userData != null) ...[
                const Text(
                  "Datos del Perfil (Firestore):",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.deepPurple),
                    title: Text(
                      "Nombre: ${_userData!['nombre'] ?? 'Sin nombre'}",
                    ),
                    subtitle: Text("Puntos: ${_userData!['puntos'] ?? '0'}"),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
