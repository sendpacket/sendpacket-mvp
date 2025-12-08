import 'dart:developer';
import 'package:flutter/material.dart';
import '../../screens/auth/auth_service.dart';
import '../../screens/auth/login_screen.dart';
import '../../widgets/button.dart';
import '../../widgets/textfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _auth = AuthService();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  bool _isEmailValid = true;
  bool _isPasswordStrong = true;
  bool _passwordsMatch = true;

  bool _emailBlurred = false;
  bool _passwordBlurred = false;
  bool _confirmPasswordBlurred = false;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();

    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) {
        _emailBlurred = true;
        _validateEmail();
      }
    });

    _passwordFocus.addListener(() {
      if (!_passwordFocus.hasFocus) {
        _passwordBlurred = true;
        _validatePassword();
      }
    });

    _confirmPasswordFocus.addListener(() {
      if (!_confirmPasswordFocus.hasFocus) {
        _confirmPasswordBlurred = true;
        _validatePasswordsMatch();
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _validateEmail() {
    if (_email.text.isEmpty) {
      setState(() => _isEmailValid = true);
      return;
    }
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    setState(() => _isEmailValid = regex.hasMatch(_email.text));
  }

  void _validatePassword() {
    if (_password.text.isEmpty) {
      setState(() => _isPasswordStrong = true);
      return;
    }
    final regex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$',
    );
    setState(() => _isPasswordStrong = regex.hasMatch(_password.text));
    _validatePasswordsMatch();
  }

  void _validatePasswordsMatch() {
    if (_confirmPassword.text.isEmpty) {
      setState(() => _passwordsMatch = true);
      return;
    }
    setState(() => _passwordsMatch = _password.text == _confirmPassword.text);
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
              "S'inscrire",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 50),

            CustomTextField(
              hint: "Entrez votre Nom complet",
              label: "Nom complet",
              controller: _name,
            ),
            const SizedBox(height: 20),

            CustomTextField(
              hint: "Entrez votre Email",
              label: "Email",
              controller: _email,
              focusNode: _emailFocus,
              onChanged: (_) => _validateEmail(),
            ),
            if (_emailBlurred && !_isEmailValid)
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
              isPassword: true,
              controller: _password,
              focusNode: _passwordFocus,
              obscureText: _obscurePassword,
              obscureToggle: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              onChanged: (_) => _validatePassword(),
            ),
            if (_passwordBlurred && !_isPasswordStrong)
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  "Mot de passe faible",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

            const SizedBox(height: 20),

            CustomTextField(
              hint: "Confirmez votre Mot de passe",
              label: "Confirmation du mot de passe",
              isPassword: true,
              controller: _confirmPassword,
              focusNode: _confirmPasswordFocus,
              obscureText: _obscureConfirmPassword,
              obscureToggle: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
              onChanged: (_) => _validatePasswordsMatch(),
            ),
            if (_confirmPasswordBlurred && !_passwordsMatch)
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  "Les mots de passe ne sont pas conformes",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

            const SizedBox(height: 30),

            CustomButton(
              label: "S'inscrire",
              onPressed: _signup,
            ),

            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Vous avez déjà un compte? "),
                InkWell(
                  onTap: () => goToLogin(context),
                  child: const Text(
                    "Connexion",
                    style: TextStyle(color: Colors.red),
                  ),
                )
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  void goToLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  Future<void> _showSuccessDialog() async {
    if (!mounted) return;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Succès"),
        content: const Text("Votre compte a été créé avec succès."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              goToLogin(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _signup() async {
    _validateEmail();
    _validatePassword();
    _validatePasswordsMatch();

    if (!_isEmailValid || !_isPasswordStrong || !_passwordsMatch) return;

    final user = await _auth.createUserWithEmailAndPassword(
      _email.text.trim(),
      _password.text.trim(),
    );

    if (user != null) {
      log("Utilisateur créé avec succès");
      if (!mounted) return;
      _showSuccessDialog();
    }
  }
}
