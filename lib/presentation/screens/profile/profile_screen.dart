import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool isDarkMode;

  const ProfileScreen({super.key, required this.isDarkMode});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (mounted) {
        setState(() {
          _userData = doc.data();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final Color backgroundColor = widget.isDarkMode
        ? Colors.black
        : Colors.white;
    final Color textColor = widget.isDarkMode ? Colors.white : Colors.black;
    final Color secondaryTextColor = widget.isDarkMode
        ? Colors.white70
        : Colors.grey;
    final Color iconColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final Color appBarColor = widget.isDarkMode ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          "Mon profil",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: iconColor),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(
                    isDarkMode: widget.isDarkMode,
                    initialData: _userData,
                  ),
                ),
              );
              if (result == true) {
                _loadUserData();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: secondaryTextColor),
                  const SizedBox(height: 16),
                  Text(
                    "Vous n'êtes pas connecté",
                    style: TextStyle(color: textColor, fontSize: 18),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadUserData,
              color: Colors.blueAccent,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Avatar et nom
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.blueAccent,
                            backgroundImage:
                                _userData?['profileImage'] != null &&
                                    _userData!['profileImage']
                                        .toString()
                                        .isNotEmpty
                                ? NetworkImage(_userData!['profileImage'])
                                : null,
                            child:
                                _userData?['profileImage'] == null ||
                                    _userData!['profileImage']
                                        .toString()
                                        .isEmpty
                                ? Text(
                                    _getInitials(),
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditProfileScreen(
                                      isDarkMode: widget.isDarkMode,
                                      initialData: _userData,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  _loadUserData();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: backgroundColor,
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _getDisplayName(),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.email ?? "",
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Informations du profil
                      _buildInfoCard(
                        icon: Icons.person,
                        label: "Prénom",
                        value: _userData?['firstName'] ?? "Non renseigné",
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        iconColor: iconColor,
                        backgroundColor: backgroundColor,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        icon: Icons.person_outline,
                        label: "Nom",
                        value: _userData?['lastName'] ?? "Non renseigné",
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        iconColor: iconColor,
                        backgroundColor: backgroundColor,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        icon: Icons.phone,
                        label: "Téléphone",
                        value: _userData?['phone'] ?? "Non renseigné",
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        iconColor: iconColor,
                        backgroundColor: backgroundColor,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        icon: Icons.email,
                        label: "Email",
                        value: user.email ?? "Non renseigné",
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        iconColor: iconColor,
                        backgroundColor: backgroundColor,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        icon: Icons.calendar_today,
                        label: "Date d'inscription",
                        value: _userData?['joinDate'] != null
                            ? _formatDate(_userData!['joinDate'])
                            : "Non renseigné",
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        iconColor: iconColor,
                        backgroundColor: backgroundColor,
                      ),
                      const SizedBox(height: 32),
                      // Bouton modifier
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditProfileScreen(
                                  isDarkMode: widget.isDarkMode,
                                  initialData: _userData,
                                ),
                              ),
                            );
                            if (result == true) {
                              _loadUserData();
                            }
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text(
                            "Modifier mon profil",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color textColor,
    required Color secondaryTextColor,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials() {
    final firstName = _userData?['firstName'] ?? '';
    final lastName = _userData?['lastName'] ?? '';
    final user = _auth.currentUser;

    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    } else if (firstName.isNotEmpty) {
      return firstName[0].toUpperCase();
    } else if (lastName.isNotEmpty) {
      return lastName[0].toUpperCase();
    } else if (user?.email != null && user!.email!.isNotEmpty) {
      return user.email![0].toUpperCase();
    }
    return '?';
  }

  String _getDisplayName() {
    final firstName = _userData?['firstName'] ?? '';
    final lastName = _userData?['lastName'] ?? '';
    final user = _auth.currentUser;

    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      return firstName;
    } else if (lastName.isNotEmpty) {
      return lastName;
    } else if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!;
    } else if (user?.email != null && user!.email!.isNotEmpty) {
      return user.email!.split('@')[0];
    }
    return 'Utilisateur';
  }

  String _formatDate(dynamic date) {
    if (date == null) return "Non renseigné";

    try {
      DateTime dateTime;
      if (date is Timestamp) {
        dateTime = date.toDate();
      } else if (date is DateTime) {
        dateTime = date;
      } else {
        return "Non renseigné";
      }

      return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    } catch (e) {
      return "Non renseigné";
    }
  }
}
