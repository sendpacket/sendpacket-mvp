import 'package:flutter/material.dart';

const Color kPrimaryBlue = Color(0xFF3A7FEA);
const Color kDarkCard = Color(0xFF111727);
const Color kDarkSurface = Color(0xFF161D2D);

class MyAnnouncementBottomSheet extends StatelessWidget {
  final bool isDark;
  final Map<String, dynamic> data;
  final bool isExpired;

  // Callbacks (émission d’intentions)
  final VoidCallback onEditPrice;
  final VoidCallback onEditWeight;
  final VoidCallback onEditExpiration;
  final VoidCallback onEditDescription;
  final VoidCallback onDelete;

  const MyAnnouncementBottomSheet({
    super.key,
    required this.isDark,
    required this.data,
    required this.isExpired,
    required this.onEditPrice,
    required this.onEditWeight,
    required this.onEditExpiration,
    required this.onEditDescription,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? kDarkCard : Colors.white;
    final surface = isDark ? kDarkSurface : const Color(0xFFF7F9FC);
    final text = isDark ? Colors.white : Colors.black87;
    final border = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.08);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.65,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Text(
                  "Gestion de l’annonce",
                  style: TextStyle(
                    color: text,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _statusBadge(isExpired),
              ],
            ),

            const SizedBox(height: 24),

            // GRID – cartes interactives
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
              ),
              children: [
                _lockedCard(
                  icon: Icons.place,
                  label: "Trajet",
                  value:
                  "${data['departVille']} → ${data['arriveeVille']}",
                  text: text,
                  bg: surface,
                  border: border,
                ),
                _lockedCard(
                  icon: Icons.flight_takeoff,
                  label: "Voyage",
                  value: data['dateVoyage'],
                  text: text,
                  bg: surface,
                  border: border,
                ),
                _editableCard(
                  icon: Icons.event_busy,
                  label: "Expiration",
                  value: data['expiresAt'],
                  text: text,
                  bg: surface,
                  border: border,
                  enabled: true,
                  onEdit: onEditExpiration,
                ),
                _editableCard(
                  icon: Icons.scale,
                  label: "Poids",
                  value: "${data['poidsDisponible']} Kg",
                  text: text,
                  bg: surface,
                  border: border,
                  enabled: !isExpired,
                  onEdit: onEditWeight,
                ),
                _editableCard(
                  icon: Icons.attach_money,
                  label: "Prix",
                  value: "${data['price']} \$/kg",
                  text: text,
                  bg: surface,
                  border: border,
                  enabled: !isExpired,
                  onEdit: onEditPrice,
                ),
                _lockedCard(
                  icon: Icons.phone,
                  label: "Contact",
                  value: data['numeroTel'],
                  text: text,
                  bg: surface,
                  border: border,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description (full width)
            if ((data['description'] ?? '').toString().isNotEmpty)
              _editableCard(
                icon: Icons.notes,
                label: "Description",
                value: data['description'],
                text: text,
                bg: surface,
                border: border,
                fullWidth: true,
                enabled: !isExpired,
                onEdit: onEditDescription,
              ),

            const SizedBox(height: 28),

            // Delete action
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                label: const Text(
                  "Supprimer l’annonce",
                  style: TextStyle(color: Colors.redAccent),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: onDelete,
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ================= COMPONENTS =================

  Widget _editableCard({
    required IconData icon,
    required String label,
    required String value,
    required Color text,
    required Color bg,
    required Color border,
    required VoidCallback onEdit,
    bool enabled = true,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: kPrimaryBlue, size: 22),
              const Spacer(),
              if (enabled)
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: kPrimaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: TextStyle(
              color: text,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: fullWidth ? 4 : 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: text,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _lockedCard({
    required IconData icon,
    required String label,
    required String value,
    required Color text,
    required Color bg,
    required Color border,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey, size: 22),
          const SizedBox(height: 14),
          Text(
            label,
            style: TextStyle(
              color: text,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: text,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(bool isExpired) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isExpired
            ? Colors.orange.withValues(alpha: 0.15)
            : Colors.green.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isExpired ? "Expirée" : "Active",
        style: TextStyle(
          color: isExpired ? Colors.orange : Colors.green,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
