import 'package:flutter/material.dart';

const Color kPrimaryBlue = Color(0xFF3A7FEA);
const Color kDarkCard = Color(0xFF111727);

class MyAnnouncementCard extends StatelessWidget {
  final bool isDark;
  final Map<String, dynamic> data;
  final bool isExpired;
  final VoidCallback onTap;

  const MyAnnouncementCard({
    super.key,
    required this.isDark,
    required this.data,
    required this.isExpired,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryText = isDark ? Colors.white : Colors.black87;
    final Color secondaryText = isDark ? Colors.white70 : Colors.grey[700]!;

    final String departPays = (data['departPays'] ?? '').toString();
    final String departVille = (data['departVille'] ?? '').toString();
    final String arriveePays = (data['arriveePays'] ?? '').toString();
    final String arriveeVille = (data['arriveeVille'] ?? '').toString();

    final int poids = int.tryParse((data['poidsDisponible'] ?? 0).toString()) ?? 0;

    // ton Firestore stocke price dans 'price'
    final num price = num.tryParse((data['price'] ?? 0).toString()) ?? 0;
    final String priceLabel = (price % 1 == 0)
        ? "${price.toInt()}\$/kg"
        : "${price.toStringAsFixed(1)}\$/kg";

    final String voyage = (data['dateVoyage'] ?? '--').toString();

    return Opacity(
      opacity: isExpired ? 0.72 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
              colors: [
                Color(0xFF111727),
                Color(0xFF0B0F1F),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            color: isDark ? null : Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: isExpired
                ? Border.all(color: Colors.grey.withOpacity(0.25))
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.42 : 0.08),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------- TOP RIGHT ICONS + EXPIRED BADGE ----------
              Row(
                children: [
                  if (isExpired)
                    _chip(
                      icon: Icons.timer_outlined,
                      label: "Expirée",
                      isDark: isDark,
                      color: Colors.grey,
                    ),
                ],
              ),

              const SizedBox(height: 10),

              // --------- TRAJET (pays + villes) + LUGGAGE LINE ----------
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Départ
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          departPays,
                          style: const TextStyle(
                            color: kPrimaryBlue,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          departVille,
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 13,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  _luggageLine(weightKg: poids, isDark: isDark),

                  const SizedBox(width: 10),

                  // Destination
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          arriveePays,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: kPrimaryBlue,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          arriveeVille,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 13,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // --------- DATE + PRIX (badge) ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _metaBlock(
                    title: voyage,
                    subtitle: "Voyage",
                    isDark: isDark,
                  ),
                  _priceBadge(priceLabel, isDark),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- WIDGETS UI HELPERS ----------

  Widget _priceBadge(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: kPrimaryBlue.withOpacity(isDark ? 0.14 : 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: kPrimaryBlue.withOpacity(isDark ? 0.28 : 0.18),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: kPrimaryBlue,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _metaBlock({
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    final secondaryText = isDark ? Colors.white70 : Colors.grey[700]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: kPrimaryBlue,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(color: secondaryText, fontSize: 12),
        ),
      ],
    );
  }

  Widget _luggageLine({required int weightKg, required bool isDark}) {
    final lineColor = Colors.grey.withOpacity(isDark ? 0.45 : 0.35);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dot(),
            const SizedBox(width: 6),
            _segmentLine(lineColor),
            const SizedBox(width: 6),
            const Icon(Icons.luggage, color: kPrimaryBlue, size: 20),
            const SizedBox(width: 6),
            _segmentLine(lineColor),
            const SizedBox(width: 6),
            _dot(),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "${weightKg}Kg disponibles",
          style: const TextStyle(
            color: kPrimaryBlue,
            fontWeight: FontWeight.w700,
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }

  Widget _dot() {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: kPrimaryBlue,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _segmentLine(Color c) {
    return Container(width: 26, height: 1, color: c);
  }

  Widget _chip({
    required IconData icon,
    required String label,
    required bool isDark,
    required Color color,
  }) {
    final bg = color.withOpacity(isDark ? 0.18 : 0.12);
    final border = color.withOpacity(isDark ? 0.28 : 0.20);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
