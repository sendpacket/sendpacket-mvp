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

  bool _emailError = false;
  bool _passwordError = false;
  bool _emailFormatError = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return regex.hasMatch(email);
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
              onChanged: (_) {
                setState(() {
                  _emailError = false;
                  _emailFormatError = false;
                });
              },
            ),
            if (_emailError)
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  "Email requis. Veuillez le remplir.",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            if (_emailFormatError)
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  "Format d’email invalide",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
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
              onChanged: (_) {
                setState(() {
                  _passwordError = false;
                });
              },
            ),
            if (_passwordError)
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  "Mot de passe requis. Veuillez le remplir.",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
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
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
    );
  }

  Future<void> _showErrorDialog(String message) async {
    if (!mounted) return;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Connexion échouée"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _emailError = _email.text.trim().isEmpty;
      _passwordError = _password.text.trim().isEmpty;
      _emailFormatError =
          _email.text.isNotEmpty && !_isValidEmail(_email.text.trim());
    });

    if (_emailError || _passwordError || _emailFormatError) return;

    try {
      final user = await _auth.loginUserWithEmailAndPassword(
        _email.text.trim(),
        _password.text.trim(),
      );

      if (user != null) {
        log("Utilisateur connecté avec succès");

        if (!mounted) return;

        _email.clear();
        _password.clear();

        goToHome(context);
      } else {
        _showErrorDialog("Email ou mot de passe incorrect.");
      }
    } catch (e) {
      _showErrorDialog("Email ou mot de passe incorrect.");
    }
  }
}
