import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isDarkMode;

  const DetailScreen({
    super.key,
    required this.item,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    String departureParts = item["departure_time"];
    String arrivalParts = item["arrival_time"];
    String departureTime = departureParts.split(" ")[0];
    String departureDate = departureParts.split(" ").sublist(1).join(" ");
    String arrivalTime = arrivalParts.split(" ")[0];
    String arrivalDate = arrivalParts.split(" ").sublist(1).join(" ");

    // Infos supplémentaires
    String lastBookingDate = "22 Janvier 2024";
    String collectionAddress = "145 Boulevard Deguire, Mtl";
    String deliveryAddress = "3051 Liberté 6, Dakar";

    Color backgroundColor = isDarkMode ? Colors.black : Colors.white;
    Color textColor = isDarkMode ? Colors.white : Colors.black87;
    Color subTextColor = isDarkMode ? Colors.white70 : Colors.grey[800]!;

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
                  Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: subTextColor, fontSize: 15)),
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
                        Icon(Icons.location_on, color: Colors.redAccent, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "${item["depart_city"]} (${item["depart_country"]}) → ${item["destination_city"]} (${item["destination_country"]})",
                            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Départ
                    infoRow(Icons.airplanemode_active, "Départ", "Heure: $departureTime\nDate: $departureDate"),

                    // Arrivée
                    infoRow(Icons.flag, "Arrivée", "Heure: $arrivalTime\nDate: $arrivalDate"),

                    // Dernier délai réservation
                    infoRow(Icons.timer, "Dernier délai de réservation", lastBookingDate),

                    // Adresse collecte
                    infoRow(Icons.home_work, "Adresse de collecte", collectionAddress),

                    // Adresse livraison
                    infoRow(Icons.location_city, "Adresse de réception", deliveryAddress),

                    const SizedBox(height: 24),

                    // Transporteur et prix
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundImage: AssetImage(item["carrier_image"]),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item["carrier_name"],
                            style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 18),
                          ),
                        ),
                        Text(
                          item["price"],
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    builder: (context) => Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Contacter le transporteur",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => _callNumber("+15145551234"),
                            icon: const Icon(Icons.phone),
                            label: const Text("Appeler"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => _openWhatsApp("15145551234"),
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: const Text("WhatsApp"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
    print("Appel vers $number");
  }

  void _openWhatsApp(String number) {
    print("WhatsApp vers $number");
  }
}
