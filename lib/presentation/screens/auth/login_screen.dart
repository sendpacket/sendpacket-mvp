import 'dart:developer';
import 'package:flutter/material.dart';
import '../../screens/auth/auth_service.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../widgets/button.dart';
import '../../widgets/textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const Spacer(),
            const Text(
              "Connexion",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 50),
            CustomTextField(
              hint: "Entrez votre Email",
              label: "Email",
              controller: _email,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Entrez votre Mot de passe",
              label: "Mot de passe",
              controller: _password,
              isPassword: true,
              obscureText: _obscurePassword,
              obscureToggle: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            const SizedBox(height: 30),
            CustomButton(
              label: "Se connecter",
              onPressed: _login,
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Vous avez un compte existant? "),
                InkWell(
                  onTap: () => goToSignup(context),
                  child: const Text(
                    "S'inscrire",
                    style: TextStyle(color: Colors.red),
                  ),
                )
              ],
            ),
            const Spacer()
          ],
        ),
      ),
    );
  }

  void goToSignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignupScreen()),
    );
  }

  void goToHome(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Future<void> _showErrorDialog(String message) async {
    if (!mounted) return;
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Connexion échouée"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  Future<void> _login() async {
    try {
      final user = await _auth.loginUserWithEmailAndPassword(
        _email.text.trim(),
        _password.text.trim(),
      );

      if (user != null) {
        log("Utilisateur connecté avec succès");

        if (!mounted) return;

        // Vider les champs après connexion réussie
        _email.clear();
        _password.clear();

        goToHome(context);
      } else {
        _showErrorDialog("Email ou Mot de passe incorrect.");
      }
    } catch (e) {
      _showErrorDialog("Une erreur est survenue: $e");
    }
  }
}
