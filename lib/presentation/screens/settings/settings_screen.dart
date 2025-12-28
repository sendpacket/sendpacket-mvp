import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/verification/verify_identity_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/profile/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatelessWidget {
  final bool isDarkMode;

  const SettingsScreen({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = textColor.withAlpha((0.7 * 255).toInt());
    final iconColor = textColor;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          "Paramètres",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          _buildSectionTitle("Compte", secondaryTextColor),

          if (user != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.blueAccent,
                        child: Text(
                          (user.displayName != null &&
                                  user.displayName!.isNotEmpty)
                              ? user.displayName![0].toUpperCase()
                              : user.email![0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    user.displayName ?? "Utilisateur",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // --------------------------
          // Visible SEULEMENT si connecté
          // --------------------------
          if (user != null)
            _buildMenuItem(
              icon: Icons.person,
              label: "Mon profil",
              textColor: textColor,
              iconColor: iconColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(isDarkMode: isDarkMode),
                  ),
                );
              },
            ),

          if (user != null)
            _buildMenuItem(
              icon: Icons.assignment,
              label: "Mes annonces",
              textColor: textColor,
              iconColor: iconColor,
              onTap: () {},
            ),

          if (user != null)
            _buildMenuItem(
              icon: Icons.verified_user,
              label: "Vérifier mon compte",
              textColor: textColor,
              iconColor: iconColor,
              onTap: () async {
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser == null) return;

                final snapshot = await FirebaseFirestore.instance
                    .collection("kycRequests")
                    .where("uid", isEqualTo: currentUser.uid)
                    .orderBy("submittedAt", descending: true)
                    .limit(1)
                    .get();

                if (!context.mounted) return;

                if (snapshot.docs.isNotEmpty) {
                  final data = snapshot.docs.first.data();
                  final status = data["status"];

                  if (status == "approved") {
                    _showInfoPopup(
                      context,
                      isDarkMode,
                      title: "Compte déjà vérifié",
                      message:
                          "Votre compte est déjà vérifié. Aucune autre action n'est requise.",
                    );
                    return;
                  }

                  if (status == "pending") {
                    _showInfoPopup(
                      context,
                      isDarkMode,
                      title: "Vérification en cours",
                      message:
                          "Votre demande est actuellement en cours de traitement.",
                    );
                    return;
                  }
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        VerifyIdentityScreen(isDarkMode: isDarkMode),
                  ),
                );
              },
            ),

          // --------------------------
          // Visible SEULEMENT si NON connecté
          // --------------------------
          if (user == null)
            _buildMenuItem(
              icon: Icons.login,
              label: "Se connecter",
              textColor: textColor,
              iconColor: iconColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),

          // --------------------------
          // Déconnexion — visible seulement si connecté
          // --------------------------
          if (user != null)
            _buildMenuItem(
              icon: Icons.logout,
              label: "Se déconnecter",
              textColor: textColor,
              iconColor: iconColor,
              onTap: () => _showLogoutDialog(context, isDarkMode),
            ),

          const SizedBox(height: 20),

          // ------------------------------------------------------------------
          _buildSectionTitle("Application", textColor),
          _buildMenuItem(
            icon: Icons.lock,
            label: "Confidentialité",
            textColor: textColor,
            iconColor: iconColor,
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.info,
            label: "À propos",
            textColor: textColor,
            iconColor: iconColor,
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.policy,
            label: "Policy & Conditions",
            textColor: textColor,
            iconColor: iconColor,
            onTap: () {},
          ),

          const SizedBox(height: 20),
          _buildSectionTitle("Support", textColor),
          _buildMenuItem(
            icon: Icons.help_outline,
            label: "Centre d'aide",
            textColor: textColor,
            iconColor: iconColor,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(
        title,
        style: TextStyle(
          color: color.withAlpha((0.7 * 255).toInt()),
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color textColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(label, style: TextStyle(color: textColor)),
      trailing: Icon(
        Icons.chevron_right,
        color: iconColor.withValues(alpha: 0.5),
      ),
      onTap: onTap,
    );
  }

  void _showInfoPopup(
    BuildContext context,
    bool isDarkMode, {
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 48, color: Colors.blueAccent),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode
                        ? Colors.white70
                        : Colors.black.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, bool isDarkMode) {
    final bgColor = isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 48),
                    const Text(
                      "Déconnexion",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: textColor),
                      onPressed: () =>
                          Navigator.of(context, rootNavigator: true).pop(),
                    ),
                  ],
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Voulez-vous vraiment vous déconnecter ?",
                    style: TextStyle(fontSize: 16, color: textColor),
                    textAlign: TextAlign.center,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                        ),
                        onPressed: () =>
                            Navigator.of(context, rootNavigator: true).pop(),
                        child: const Text(
                          "Annuler",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomeScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          "Se déconnecter",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
