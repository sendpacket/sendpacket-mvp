import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final bool isDarkMode;

  const SettingsScreen({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black;

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
          _buildSectionTitle("Compte", textColor),

          _buildMenuItem(
            icon: Icons.person,
            label: "Modifier mon profil",
            textColor: textColor,
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.assignment,
            label: "Mes annonces",
            textColor: textColor,
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.verified_user,
            label: "Vérifier mon compte",
            textColor: textColor,
            onTap: () {

            },
          ),

          const SizedBox(height: 20),
          _buildSectionTitle("Application", textColor),

          _buildMenuItem(
            icon: Icons.lock,
            label: "Confidentialité",
            textColor: textColor,
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.info,
            label: "À propos",
            textColor: textColor,
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.policy,
            label: "Policy & Conditions",
            textColor: textColor,
            onTap: () {},
          ),

          const SizedBox(height: 20),
          _buildSectionTitle("Support", textColor),

          _buildMenuItem(
            icon: Icons.help_outline,
            label: "Centre d’aide",
            textColor: textColor,
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
          color: color.withValues(alpha: 0.7),
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
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(label, style: TextStyle(color: textColor)),
      trailing: Icon(Icons.chevron_right, color: textColor),
      onTap: onTap,
    );
  }
}
