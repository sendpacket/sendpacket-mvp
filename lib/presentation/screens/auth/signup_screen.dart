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

  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  bool _isEmailValid = true;
  bool _isPasswordStrong = true;
  bool _passwordsMatch = true;

  bool _firstNameEmpty = false;
  bool _lastNameEmpty = false;
  bool _emailEmpty = false;
  bool _passwordEmpty = false;
  bool _confirmPasswordEmpty = false;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();

    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) {
        _validateEmail();
      }
    });

    _passwordFocus.addListener(() {
      if (!_passwordFocus.hasFocus) {
        _validatePassword();
      }
    });

    _confirmPasswordFocus.addListener(() {
      if (!_confirmPasswordFocus.hasFocus) {
        _validatePasswordsMatch();
      }
    });

    _firstName.addListener(() {
      if (_firstNameEmpty && _firstName.text.isNotEmpty) {
        setState(() {
          _firstNameEmpty = false;
        });
      }
    });
    _lastName.addListener(() {
      if (_lastNameEmpty && _lastName.text.isNotEmpty) {
        setState(() {
          _lastNameEmpty = false;
        });
      }
    });
    _email.addListener(() {
      if (_emailEmpty && _email.text.isNotEmpty) {
        setState(() {
          _emailEmpty = false;
        });
      }
    });
    _password.addListener(() {
      if (_passwordEmpty && _password.text.isNotEmpty) {
        setState(() {
          _passwordEmpty = false;
        });
      }
    });
    _confirmPassword.addListener(() {
      if (_confirmPasswordEmpty && _confirmPassword.text.isNotEmpty) {
        setState(() {
          _confirmPasswordEmpty = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
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
      setState(() {
        _isEmailValid = true;
      });
      return;
    }
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    setState(() {
      _isEmailValid = regex.hasMatch(_email.text.trim());
    });
  }

  void _validatePassword() {
    if (_password.text.isEmpty) {
      setState(() {
        _isPasswordStrong = true;
      });
      return;
    }
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$');
    setState(() {
      _isPasswordStrong = regex.hasMatch(_password.text);
    });
    _validatePasswordsMatch();
  }

  void _validatePasswordsMatch() {
    if (_confirmPassword.text.isEmpty) {
      setState(() {
        _passwordsMatch = true;
      });
      return;
    }
    setState(() {
      _passwordsMatch = _password.text == _confirmPassword.text;
    });
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
              hint: "Entrez vos prénoms",
              label: "Prénom(s)",
              controller: _firstName,
            ),
            if (_firstNameEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  "Le prénom est requis",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Entrez votre nom",
              label: "Nom",
              controller: _lastName,
            ),
            if (_lastNameEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  "Le nom est requis",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Entrez votre Email",
              label: "Email",
              controller: _email,
              focusNode: _emailFocus,
              onChanged: (_) => _validateEmail(),
            ),
            if (_emailEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  "L'email est requis",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            if (!_isEmailValid)
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
            if (_passwordEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  "Le mot de passe est requis",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            if (!_isPasswordStrong)
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  "8 caractères min, majuscule, minuscule, chiffre et symbole",
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
            if (_confirmPasswordEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  "La confirmation du mot de passe est requise",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            if (!_passwordsMatch)
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  "Les mots de passe ne correspondent pas",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 30),
            CustomButton(label: "S'inscrire", onPressed: _signup),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Vous avez déjà un compte ? "),
                InkWell(
                  onTap: () => goToLogin(context),
                  child: const Text("Connexion", style: TextStyle(color: Colors.red)),
                ),
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
    if (!mounted) {
      return;
    }
    await showDialog(
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
    setState(() {
      _firstNameEmpty = _firstName.text.trim().isEmpty;
      _lastNameEmpty = _lastName.text.trim().isEmpty;
      _emailEmpty = _email.text.trim().isEmpty;
      _passwordEmpty = _password.text.isEmpty;
      _confirmPasswordEmpty = _confirmPassword.text.isEmpty;
    });

    _validateEmail();
    _validatePassword();
    _validatePasswordsMatch();

    if (_firstNameEmpty ||
        _lastNameEmpty ||
        _emailEmpty ||
        _passwordEmpty ||
        _confirmPasswordEmpty ||
        !_isEmailValid ||
        !_isPasswordStrong ||
        !_passwordsMatch) {
      return;
    }

    final user = await _auth.createUserWithEmailAndPassword(
      _email.text.trim(),
      _password.text.trim(),
    );

    if (user != null) {
      log("Utilisateur créé avec succès");
      if (!mounted) {
        return;
      }
      _showSuccessDialog();
    }
  }
}
