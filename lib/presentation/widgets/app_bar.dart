import 'dart:ui';
import 'package:flutter/material.dart';

import '../screens/settings/settings_screen.dart';
import '../screens/auth/login_screen.dart';

const Color kPrimaryBlue = Color(0xFF3A7FEA);

class FloatingBottomBar extends StatelessWidget {
  final bool isDarkMode;
  final bool isAuthenticated;

  const FloatingBottomBar({
    super.key,
    required this.isDarkMode,
    required this.isAuthenticated,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = isDarkMode
        ? const Color(0xCC0B1220)
        : Colors.white.withValues(alpha: 0.95);

    final Color iconColor = isDarkMode ? Colors.white : Colors.black87;
    final Color textColor =
    isDarkMode ? Colors.white70 : Colors.grey[700]!;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 30,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildNavItem(
              context: context,
              icon: Icons.favorite_border,
              label: 'Favoris',
              iconColor: iconColor,
              textColor: textColor,
              onTap: () {
                // TODO: favoris page
              },
            ),
            const Spacer(),
            _buildCenterButton(context),
            const Spacer(),
            _buildNavItem(
              context: context,
              icon: Icons.person_outline,
              label: 'Profil',
              iconColor: iconColor,
              textColor: textColor,
              onTap: () {
                // Ouverture directe de l'écran de paramètres
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(
                      isDarkMode: isDarkMode,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isAuthenticated) {
          // Route nommée déjà existante pour le login
          Navigator.pushNamed(context, '/login');
          return;
        }

        Navigator.pushNamed(context, '/create-annonce');
      },
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [
              kPrimaryBlue,
              Color(0xFF2652B5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: kPrimaryBlue.withValues(alpha: 0.55),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
