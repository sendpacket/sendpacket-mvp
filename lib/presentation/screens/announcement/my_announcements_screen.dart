import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/my_announcement_card.dart';
import '../../widgets/my_annoucement_bottom_sheet.dart';
import '../../widgets/confirm_delete_sheet.dart';

const Color kPrimaryBlue = Color(0xFF3A7FEA);
const Color kDarkBackground = Color(0xFF050816);
const Color kLightBackground = Color(0xFFF7F9FC);
const Color kDarkCard = Color(0xFF111727);

class MyAnnouncementsScreen extends StatefulWidget {
  final bool isDarkMode;

  const MyAnnouncementsScreen({super.key, required this.isDarkMode});

  @override
  State<MyAnnouncementsScreen> createState() => _MyAnnouncementsScreenState();
}

class _MyAnnouncementsScreenState extends State<MyAnnouncementsScreen> {
  // Theme helpers
  bool get _isDark => widget.isDarkMode;
  Color get _bg => _isDark ? kDarkBackground : kLightBackground;
  Color get _card => _isDark ? kDarkCard : Colors.white;
  Color get _primaryText => _isDark ? Colors.white : Colors.black87;
  Color? get _secondaryText => _isDark ? Colors.white70 : Colors.grey[700];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _isDark ? kDarkBackground : Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: _isDark ? Colors.white : Colors.black87,
        ),
        title: Text(
          "Mes annonces",
          style: TextStyle(
            color: _primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _buildEmptyState(
        icon: Icons.login,
        title: "Non connecté",
        message: "Connectez-vous pour voir vos annonces.",
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection("AnnonceCollection")
          .where("ownerId", isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        // Handle error state
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        // Handle empty state
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.inbox,
            title: "Aucune annonce",
            message: "Créez votre première annonce pour commencer.",
          );
        }

        // Parse and sort announcements
        final announcements = _sortAnnouncements(snapshot.data!.docs);

        // Build list
        return _buildAnnouncementsList(announcements);
      },
    );
  }

  List<Map<String, dynamic>> _sortAnnouncements(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final announcements = docs.map((doc) {
      final data = doc.data();
      final isExpired = _isExpired(data['expiresAt']?.toString());

      return {
        'docId': doc.id,
        'isExpired': isExpired,
        'data': data,
      };
    }).toList();

    announcements.sort((a, b) {
      // First: active before expired
      final aExpired = a['isExpired'] as bool;
      final bExpired = b['isExpired'] as bool;
      if (aExpired != bExpired) {
        return aExpired ? 1 : -1;
      }

      // Second: most recent first (by createdAt)
      final aData = a['data'] as Map<String, dynamic>;
      final bData = b['data'] as Map<String, dynamic>;
      final dateA = _parseSimpleDate(aData['createdAt']?.toString());
      final dateB = _parseSimpleDate(bData['createdAt']?.toString());

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;

      return dateB.compareTo(dateA); // Most recent first
    });

    return announcements;
  }

  DateTime? _parseSimpleDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    final parts = dateStr.split('-');
    if (parts.length != 3) return null;
    try {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  bool _isExpired(String? expiresAtStr) {
    final expiresAt = _parseSimpleDate(expiresAtStr);
    if (expiresAt == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return expiresAt.isBefore(today);
  }

  Widget _buildAnnouncementsList(List<Map<String, dynamic>> announcements) {
    return RefreshIndicator(
      color: kPrimaryBlue,
      onRefresh: () async {
        // StreamBuilder auto-refreshes, just show visual feedback
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          final item = announcements[index];
          final docId = item['docId'] as String;
          final isExpired = item['isExpired'] as bool;
          final data = item['data'] as Map<String, dynamic>;

          return MyAnnouncementCard(
            isDark: _isDark,
            data: data,
            isExpired: isExpired,
            onTap: () => _showAnnouncementDetails(docId, data, isExpired),
          );
        },
      ),
    );
  }

  void _showAnnouncementDetails(
    String docId,
    Map<String, dynamic> data,
    bool isExpired,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MyAnnouncementBottomSheet(
        isDark: _isDark,
        data: data,
        isExpired: isExpired,
        onEditPrice: () {
          _showEditPriceDialog(docId, data);
        },
        onEditWeight: () {
          _showEditWeightDialog(docId, data);
        },
        onEditExpiration: () {
          _showEditExpirationDialog(docId, data);
        },
        onEditDescription: () {
          _showEditDescriptionDialog(docId, data);
        },
        onDelete: () {
          Navigator.pop(context);
          _showDeleteConfirmation(docId);
        },
      ),
    );
  }

  Future<void> _showEditPriceDialog(
      String docId, Map<String, dynamic> data) async {
    final controller = TextEditingController(
      text: (data['price'] ?? '').toString(),
    );

    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text("Modifier le prix", style: TextStyle(color: _primaryText)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          style: TextStyle(color: _primaryText),
          decoration: InputDecoration(
            filled: true,
            fillColor: _isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.grey.shade100,
            labelText: "Prix (\$/kg)",
            labelStyle: TextStyle(color: _secondaryText),
            prefixIcon: const Icon(Icons.attach_money, color: kPrimaryBlue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: kPrimaryBlue),
            ),
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    controller.dispose();
                    Navigator.pop(ctx);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Annuler",
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    final newPrice = num.tryParse(
                        controller.text.trim().replaceAll(',', '.'));

                    if (newPrice == null || newPrice <= 0) {
                      _showSnack("Prix invalide");
                      return;
                    }

                    // Close the edit dialog first
                    controller.dispose();
                    Navigator.pop(ctx);

                    // Then show confirmation
                    final confirmed = await _showConfirmationDialog(
                      "Voulez-vous vraiment modifier le prix à $newPrice \$/kg ?"
                    );

                    if (!confirmed) return;

                    // Update and notify
                    await _updateField(docId, 'price', newPrice);
                    if (mounted) {
                      _showSnack("Prix mis à jour");
                    }
                  },
                  child: const Text(
                    "Enregistrer",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }

  Future<void> _showEditWeightDialog(
      String docId, Map<String, dynamic> data) async {
    final currentWeight =
        int.tryParse((data['poidsDisponible'] ?? '10').toString()) ?? 10;
    double selectedWeight = currentWeight.toDouble();

    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: _card,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title:
              Text("Modifier le poids", style: TextStyle(color: _primaryText)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${selectedWeight.round()} Kg",
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryBlue,
                ),
              ),
              const SizedBox(height: 20),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: kPrimaryBlue,
                  inactiveTrackColor: kPrimaryBlue.withValues(alpha: 0.25),
                  thumbColor: kPrimaryBlue,
                  overlayColor: kPrimaryBlue.withValues(alpha: 0.15),
                  trackHeight: 4,
                ),
                child: Slider(
                  min: 1,
                  max: 100,
                  divisions: 99,
                  value: selectedWeight,
                  label: "${selectedWeight.round()} Kg",
                  onChanged: (value) {
                    setDialogState(() => selectedWeight = value);
                  },
                ),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Annuler",
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      final weightValue = selectedWeight.round();

                      // Close the edit dialog first
                      Navigator.pop(ctx);

                      // Then show confirmation
                      final confirmed = await _showConfirmationDialog(
                        "Voulez-vous vraiment modifier le poids à $weightValue Kg ?"
                      );

                      if (!confirmed) return;

                      // Update and notify
                      await _updateField(docId, 'poidsDisponible', weightValue);
                      if (mounted) {
                        _showSnack("Poids mis à jour");
                      }
                    },
                    child: const Text(
                      "Enregistrer",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditExpirationDialog(
      String docId, Map<String, dynamic> data) async {
    final currentExpiration = _parseSimpleDate(data['expiresAt']?.toString());
    final dateVoyage = _parseSimpleDate(data['dateVoyage']?.toString());

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // If current expiration is in the past, use today as initial date
    final initialDate = (currentExpiration != null && currentExpiration.isBefore(today))
        ? today
        : (currentExpiration ?? today);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: dateVoyage ?? DateTime(now.year + 3),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: _isDark
                ? const ColorScheme.dark(
                    primary: kPrimaryBlue,
                    onPrimary: Colors.white,
                    surface: kDarkCard,
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: kPrimaryBlue,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black87,
                  ),
            dialogTheme: DialogThemeData(
              backgroundColor: _isDark ? kDarkCard : Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Validate: expiration must be <= dateVoyage
      if (dateVoyage != null && picked.isAfter(dateVoyage)) {
        _showSnack("L'expiration doit être ≤ date de voyage");
        return;
      }

      final formattedDate = _formatDate(picked);

      final confirmed = await _showConfirmationDialog(
        "Voulez-vous vraiment modifier la date d'expiration à $formattedDate ?"
      );

      if (!confirmed) return;

      await _updateField(docId, 'expiresAt', formattedDate);
      _showSnack("Date d'expiration mise à jour");
    }
  }

  String _formatDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year.toString();
    return "$day-$month-$year";
  }

  Future<void> _showEditDescriptionDialog(
      String docId, Map<String, dynamic> data) async {
    final controller = TextEditingController(
      text: (data['description'] ?? '').toString(),
    );

    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text("Modifier la description",
            style: TextStyle(color: _primaryText)),
        content: TextField(
          controller: controller,
          maxLines: 6,
          autofocus: true,
          style: TextStyle(color: _primaryText),
          decoration: InputDecoration(
            filled: true,
            fillColor: _isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.grey.shade100,
            labelText: "Description",
            alignLabelWithHint: true,
            labelStyle: TextStyle(color: _secondaryText),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: kPrimaryBlue),
            ),
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    controller.dispose();
                    Navigator.pop(ctx);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Annuler",
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    final newDescription = controller.text.trim();

                    // Close the edit dialog first
                    controller.dispose();
                    Navigator.pop(ctx);

                    // Then show confirmation
                    final confirmed = await _showConfirmationDialog(
                      "Voulez-vous vraiment modifier la description ?"
                    );

                    if (!confirmed) return;

                    // Update and notify
                    await _updateField(
                        docId, 'description', newDescription.isEmpty ? '' : newDescription);
                    if (mounted) {
                      _showSnack("Description mise à jour");
                    }
                  },
                  child: const Text(
                    "Enregistrer",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(String docId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => ConfirmDeleteSheet(
        isDark: _isDark,
        docId: docId,
      ),
    );
  }

  Future<bool> _showConfirmationDialog(String message) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: AlertDialog(
          backgroundColor: _card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: kPrimaryBlue, size: 24),
              const SizedBox(width: 12),
              Text(
                "Confirmation",
                style: TextStyle(color: _primaryText, fontSize: 18),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(color: _primaryText, fontSize: 15),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Annuler",
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text(
                      "Confirmer",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ) ?? false;
  }

  Future<void> _updateField(String docId, String field, dynamic value) async {
    try {
      await FirebaseFirestore.instance
          .collection("AnnonceCollection")
          .doc(docId)
          .update({field: value});
    } catch (e) {
      _showSnack("Erreur lors de la mise à jour: $e");
      debugPrint("Update error: $e");
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(kPrimaryBlue),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
          const SizedBox(height: 16),
          Text(
            "Erreur de chargement",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              "Impossible de charger vos annonces. Vérifiez votre connexion.",
              textAlign: TextAlign.center,
              style: TextStyle(color: _secondaryText),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text("Réessayer",
                style: TextStyle(color: Colors.white)),
            onPressed: () => setState(() {}), // Trigger rebuild
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: _secondaryText),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _primaryText,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: _secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: _isDark ? kDarkCard : Colors.grey.shade900,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
