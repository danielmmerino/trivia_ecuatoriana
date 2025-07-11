import 'package:flutter/material.dart';
import 'category_random_screen.dart';

/// Pantalla de inicio de sesión con opciones para autenticarse
/// mediante redes sociales o continuar como invitado.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _onLoginComplete(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const CategoryRandomScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.mail_outline),
              label: const Text('Registrarse con Google'),
              onPressed: () => _onLoginComplete(context),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.facebook),
              label: const Text('Registrarse con Facebook'),
              onPressed: () => _onLoginComplete(context),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.person_outline),
              label: const Text('Continuar como invitado'),
              onPressed: () => _onLoginComplete(context),
            ),
          ],
        ),
      ),
    );
  }
}
