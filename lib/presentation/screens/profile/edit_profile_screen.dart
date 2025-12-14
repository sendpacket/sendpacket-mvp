import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/textfield.dart';

class EditProfileScreen extends StatefulWidget {
  final bool isDarkMode;
  final Map<String, dynamic>? initialData;

  const EditProfileScreen({
    super.key,
    required this.isDarkMode,
    this.initialData,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSaving = false;

  bool _firstNameError = false;
  bool _lastNameError = false;
  bool _passwordError = false;
  bool _passwordsMatch = true;
  bool _isPasswordStrong = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    if (widget.initialData != null) {
      _firstNameController.text = widget.initialData!['firstName'] ?? '';
      _lastNameController.text = widget.initialData!['lastName'] ?? '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validatePassword(String password) {
    if (password.isEmpty) return true; // Mot de passe optionnel
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }

  void _validatePasswordsMatch() {
    if (_passwordController.text.isEmpty &&
        _confirmPasswordController.text.isEmpty) {
      setState(() {
        _passwordsMatch = true;
      });
      return;
    }
    setState(() {
      _passwordsMatch =
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  Future<void> _saveProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      _showErrorDialog("Aucun utilisateur connecté");
      return;
    }

    // Validation
    setState(() {
      _firstNameError = _firstNameController.text.trim().isEmpty;
      _lastNameError = _lastNameController.text.trim().isEmpty;
      _passwordError = false;
    });

    // Validation du mot de passe si fourni
    if (_passwordController.text.isNotEmpty ||
        _confirmPasswordController.text.isNotEmpty) {
      setState(() {
        _isPasswordStrong = _validatePassword(_passwordController.text);
        _passwordError = !_isPasswordStrong;
      });
      _validatePasswordsMatch();

      if (!_isPasswordStrong || !_passwordsMatch) {
        return;
      }
    }

    if (_firstNameError || _lastNameError) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Mettre à jour Firestore avec firstName et lastName
      final updateData = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(user.uid).update(updateData);

      // Mettre à jour le mot de passe si fourni
      if (_passwordController.text.isNotEmpty) {
        await user.updatePassword(_passwordController.text.trim());
      }

      if (!mounted) return;

      // Retourner true pour indiquer que les données ont été modifiées
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profil mis à jour avec succès"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      String errorMessage = "Erreur lors de la sauvegarde";
      if (e is FirebaseAuthException) {
        if (e.code == 'weak-password') {
          errorMessage = "Le mot de passe est trop faible";
        } else if (e.code == 'requires-recent-login') {
          errorMessage =
              "Veuillez vous reconnecter pour changer le mot de passe";
        } else {
          errorMessage = "Erreur d'authentification: ${e.message}";
        }
      } else {
        errorMessage = "Erreur: ${e.toString()}";
      }

      _showErrorDialog(errorMessage);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Erreur"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.grey[700]!;
    final backgroundColor = widget.isDarkMode ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0.5,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          "Modifier le profil",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Champ Prénom
            CustomTextField(
              hint: "Entrez votre prénom",
              label: "Prénom",
              controller: _firstNameController,
              onChanged: (_) {
                setState(() {
                  _firstNameError = false;
                });
              },
            ),
            if (_firstNameError)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  "Le prénom est requis",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

            const SizedBox(height: 20),

            // Champ Nom
            CustomTextField(
              hint: "Entrez votre nom",
              label: "Nom",
              controller: _lastNameController,
              onChanged: (_) {
                setState(() {
                  _lastNameError = false;
                });
              },
            ),
            if (_lastNameError)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  "Le nom est requis",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

            const SizedBox(height: 30),

            // Section Mot de passe
            Text(
              "Changer le mot de passe (optionnel)",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Laissez vide si vous ne souhaitez pas changer votre mot de passe",
              style: TextStyle(fontSize: 12, color: subTextColor),
            ),

            const SizedBox(height: 20),

            // Champ Nouveau mot de passe
            CustomTextField(
              hint: "Nouveau mot de passe",
              label: "Nouveau mot de passe",
              controller: _passwordController,
              isPassword: true,
              obscureText: _obscurePassword,
              obscureToggle: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              onChanged: (_) {
                setState(() {
                  _isPasswordStrong = _validatePassword(
                    _passwordController.text,
                  );
                  _passwordError =
                      _passwordController.text.isNotEmpty && !_isPasswordStrong;
                });
                _validatePasswordsMatch();
              },
            ),
            if (_passwordError)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  "8 caractères min, majuscule, minuscule, chiffre et symbole",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

            const SizedBox(height: 20),

            // Champ Confirmation mot de passe
            CustomTextField(
              hint: "Confirmez le nouveau mot de passe",
              label: "Confirmation",
              controller: _confirmPasswordController,
              isPassword: true,
              obscureText: _obscureConfirmPassword,
              obscureToggle: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
              onChanged: (_) {
                _validatePasswordsMatch();
              },
            ),
            if (!_passwordsMatch && _confirmPasswordController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  "Les mots de passe ne correspondent pas",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

            const SizedBox(height: 40),

            // Bouton de sauvegarde
            Center(
              child: _isSaving
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3A7FEA),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Enregistrer",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
