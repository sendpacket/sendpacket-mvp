import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color kPrimaryBlue = Color(0xFF3A7FEA);
const Color kDarkCard = Color(0xFF111727);

class ConfirmDeleteSheet extends StatelessWidget {
  final bool isDark;
  final String docId;

  const ConfirmDeleteSheet({
    super.key,
    required this.isDark,
    required this.docId,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? kDarkCard : Colors.white;
    final text = isDark ? Colors.white : Colors.black87;
    final secondary = isDark ? Colors.white70 : Colors.grey[700]!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Colors.redAccent, size: 56),
          const SizedBox(height: 12),
          Text(
            "Supprimer l'annonce ?",
            style: TextStyle(
              color: text,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Cette action est définitive.",
            style: TextStyle(color: secondary),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text("Annuler"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection("AnnonceCollection")
                        .doc(docId)
                        .delete();
                    Navigator.pop(context);
                  },
                  child: const Text("Supprimer"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
