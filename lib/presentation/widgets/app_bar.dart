import 'dart:ui';
import 'package:flutter/material.dart';

import '../screens/settings/settings_screen.dart';
import '../screens/auth/login_screen.dart';
class FloatingBottomBar extends StatelessWidget {
  final bool isDarkMode;
  final bool isAuthenticated;

  const FloatingBottomBar({
    super.key,
    required this.isDarkMode,
    this.isAuthenticated = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color pillColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.black.withValues(alpha: 0.03);

    final Color borderColor = Colors.white.withValues(
      alpha: isDarkMode ? 0.12 : 0.18,
    );

    return Positioned(
      left: 16,
      right: 16,
      bottom: 18,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            decoration: BoxDecoration(
              color: pillColor,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: isDarkMode ? 0.4 : 0.15,
                  ),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildItem(
                  icon: Icons.sell,
                  label: "Vendre",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LoginScreen(),
                      ),
                    );
                  },
                  isDarkMode: isDarkMode,
                  onTap: () {
                    // plus tard: page Favoris
                  },
                ),

                // Bouton +
                isAuthenticated
                    ? GestureDetector(
                  onTap: () {
                    // plus tard: création d’annonce
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kPrimaryBlue,
                      boxShadow: [
                        BoxShadow(
                          color: kPrimaryBlue.withValues(alpha: 0.5),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                )
                    : const SizedBox(width: 56),

                _BottomItem(
                  icon: Icons.person_outline,
                  label: "Profil",
                  isDarkMode: isDarkMode,
                  onTap: () {
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
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _BottomItem({
    required this.icon,
    required this.label,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor =
    isDarkMode ? Colors.white : Colors.black87;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: iconColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
