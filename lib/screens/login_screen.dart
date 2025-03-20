import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _getFCMToken(); // Llamamos a la función que obtiene el token
    _setupFirebaseListeners(); // Configuramos la escucha de mensajes
  }

  /// 🔹 Obtiene el Token de Firebase Cloud Messaging (FCM)
  void _getFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print("🔥 FCM Token: $token");
  }

  /// 🔹 Escucha mensajes de Firebase cuando la app está abierta o en segundo plano
  void _setupFirebaseListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 Notificación recibida en primer plano:");
      print("Título: ${message.notification?.title}");
      print("Cuerpo: ${message.notification?.body}");
      _mostrarDialogo(message.notification?.title, message.notification?.body);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📲 Notificación abierta por el usuario:");
      print("Título: ${message.notification?.title}");
      print("Cuerpo: ${message.notification?.body}");
      _mostrarDialogo(message.notification?.title, message.notification?.body);
    });
  }

  /// 🔹 Muestra un diálogo cuando llega una notificación
  void _mostrarDialogo(String? titulo, String? cuerpo) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(titulo ?? "Notificación"),
            content: Text(cuerpo ?? "No hay contenido"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cerrar"),
              ),
            ],
          ),
    );
  }

  void signIn() async {
    if (!_formKey.currentState!.validate()) return;
    User? user = await _auth.signIn(
      emailController.text,
      passwordController.text,
    );
    if (user == null) {
      setState(() => errorMessage = "Error al iniciar sesión");
    } else {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void register() async {
    if (!_formKey.currentState!.validate()) return;
    User? user = await _auth.register(
      emailController.text,
      passwordController.text,
    );
    if (user == null) {
      setState(() => errorMessage = "Error al registrarse");
    } else {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void resetPassword() async {
    if (emailController.text.isEmpty) {
      setState(() => errorMessage = "Por favor, ingresa tu correo");
      return;
    }
    await _auth.resetPassword(emailController.text);
    setState(() => errorMessage = "Correo de recuperación enviado");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Iniciar Sesión", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Correo Electrónico",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email, color: Colors.deepPurple),
                ),
                validator:
                    (value) =>
                        (value == null || !value.contains('@'))
                            ? 'Ingresa un correo válido'
                            : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock, color: Colors.deepPurple),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.deepPurple,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator:
                    (value) =>
                        (value == null || value.length < 6)
                            ? 'Mínimo 6 caracteres'
                            : null,
              ),
              SizedBox(height: 20),
              if (errorMessage != null)
                Text(errorMessage!, style: TextStyle(color: Colors.red)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  "Iniciar Sesión",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  "Registrarse",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 15),
              TextButton(
                onPressed: resetPassword,
                child: Text(
                  "¿Olvidaste tu contraseña?",
                  style: TextStyle(color: Colors.deepPurple),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
