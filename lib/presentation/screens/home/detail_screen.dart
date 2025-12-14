import 'dart:developer';
import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isDarkMode;

  const DetailScreen({super.key, required this.item, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    // Lecture des champs "plats"
    final String departCity = (item['depart_city'] ?? '') as String;
    final String departCountry = (item['depart_country'] ?? '') as String;
    final String destinationCity = (item['destination_city'] ?? '') as String;
    final String destinationCountry =
        (item['destination_country'] ?? '') as String;
    final String weight = (item['weight'] ?? '') as String;

    // les champs pour les dates (labels déjà formatés)
    final String departureDate = (item['departure_date_label'] ?? '') as String;
    final String arrivalDate = (item['arrival_date_label'] ?? '') as String;

    // nom & prix : déjà préparés côté HomeScreen (avec fallback)
    final String carrierName = (item['carrier_name'] ?? '') as String;
    final String carrierImage = (item['carrier_image'] ?? '') as String;
    final String price = (item['price'] ?? '') as String;

    // Données "brutes" venant directement de Firestore
    final Map<String, dynamic> raw =
        (item['raw_data'] ?? <String, dynamic>{}) as Map<String, dynamic>;

    final String lastBookingDate = (raw['expiresAt'] ?? '') as String;
    final String description = (raw['description'] ?? '') as String;

    // Téléphone & WhatsApp
    final String phone = (item['raw_numero_tel'] ?? raw['numeroTel'] ?? '')
        .toString();
    final bool hasWhatsApp = (raw['whatsapp'] ?? false) == true;

    // Couleurs selon thème
    final Color backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color subTextColor = isDarkMode
        ? Colors.white70
        : (Colors.grey[800]!);

    Widget infoRow(IconData icon, String title, String subtitle) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.blueAccent, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: subTextColor, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: textColor),
        title: Text("Détails", style: TextStyle(color: textColor)),
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Villes
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.redAccent,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "$departCity ($departCountry) → "
                            "$destinationCity ($destinationCountry)",
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Départ
                    infoRow(
                      Icons.airplanemode_active,
                      "Départ",
                      "Date : $departureDate",
                    ),

                    // Arrivée
                    infoRow(Icons.flag, "Arrivée", "Date : $arrivalDate"),

                    // Dernier délai réservation (à partir de expiresAt)
                    if (lastBookingDate.isNotEmpty)
                      infoRow(
                        Icons.timer,
                        "Dernier délai de réservation",
                        lastBookingDate,
                      ),

                    // Poids disponible
                    if (weight.isNotEmpty)
                      infoRow(Icons.line_weight, "Poids disponible", weight),

                    // Description
                    if (description.isNotEmpty)
                      infoRow(
                        Icons.description_outlined,
                        "Description",
                        description,
                      ),

                    const SizedBox(height: 24),

                    // Transporteur et prix
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundImage: AssetImage(carrierImage),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            carrierName,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Text(
                          price,
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Bouton de contact
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3A7FEA),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  if (phone.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Numéro du transporteur non disponible."),
                      ),
                    );
                    return;
                  }

                  showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    builder: (context) => Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Contacter le transporteur",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Appel
                          ElevatedButton.icon(
                            onPressed: () => _callNumber(phone),
                            icon: const Icon(Icons.phone),
                            label: const Text("Appeler"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // WhatsApp (affiché seulement si whatsapp == true)
                          if (hasWhatsApp)
                            ElevatedButton.icon(
                              onPressed: () => _openWhatsApp(phone),
                              icon: const Icon(Icons.chat_bubble_outline),
                              label: const Text("WhatsApp"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Contacter le transporteur",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _callNumber(String number) {
    log("Appel vers $number");
    // TODO: intégrer url_launcher plus tard un vrai appel
  }

  void _openWhatsApp(String number) {
    log("WhatsApp vers $number");
    // TODO: intégrer url_launcher avec wa.me plutard
  }
}
