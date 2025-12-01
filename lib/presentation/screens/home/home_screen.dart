import 'package:flutter/material.dart';
import 'detail_screen.dart';
import '../../widgets/app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  final List<Map<String, dynamic>> announcements = [
    {
      "depart_city": "MTL",
      "depart_country": "Canada",
      "destination_city": "DKR",
      "destination_country": "Sénégal",
      "weight": "23Kg",
      "departure_time": "18:00 28 Janvier 2024",
      "arrival_time": "17:00 29 Janvier 2024",
      "carrier_name": "Lionnel Fatt",
      "carrier_image": "assets/img/avatar1.jpg",
      "price": "17\$/kg",
    },
    {
      "depart_city": "TOR",
      "depart_country": "Canada",
      "destination_city": "DSS",
      "destination_country": "Sénégal",
      "weight": "20Kg",
      "departure_time": "10:00 30 Janvier 2024",
      "arrival_time": "09:00 31 Janvier 2024",
      "carrier_name": "Marie Sene",
      "carrier_image": "assets/img/avatar2.jpg",
      "price": "15\$/kg",
    },
    {
      "depart_city": "VAN",
      "depart_country": "Canada",
      "destination_city": "LFW",
      "destination_country": "Sénégal",
      "weight": "18Kg",
      "departure_time": "08:00 25 Janvier 2024",
      "arrival_time": "12:00 26 Janvier 2024",
      "carrier_name": "Abdou Diallo",
      "carrier_image": "assets/img/avatar3.jpg",
      "price": "20\$/kg",
    },
    {
      "depart_city": "QUE",
      "depart_country": "Canada",
      "destination_city": "BJL",
      "destination_country": "Sénégal",
      "weight": "25Kg",
      "departure_time": "14:00 27 Janvier 2024",
      "arrival_time": "13:00 28 Janvier 2024",
      "carrier_name": "Sadio Mané",
      "carrier_image": "assets/img/avatar4.jpg",
      "price": "18\$/kg",
    },
    {
      "depart_city": "OTT",
      "depart_country": "Canada",
      "destination_city": "ZIG",
      "destination_country": "Sénégal",
      "weight": "22Kg",
      "departure_time": "09:00 29 Janvier 2024",
      "arrival_time": "08:00 30 Janvier 2024",
      "carrier_name": "Seydou Ba",
      "carrier_image": "assets/img/avatar5.jpg",
      "price": "16\$/kg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: isDarkMode ? Colors.black : Colors.white,
                    pinned: true,
                    floating: false,
                    elevation: 0.5,
                    title: Text(
                      "Annonces",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    iconTheme: IconThemeData(
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(
                          isDarkMode ? Icons.light_mode : Icons.dark_mode,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        onPressed: toggleTheme,
                      ),
                    ],
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(60),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: TextField(
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: "Rechercher...",
                            hintStyle: TextStyle(color: Colors.grey),
                            fillColor: isDarkMode ? Colors.grey[850] : const Color(0xFFF4F4F4),
                            filled: true,
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            suffixIcon: Icon(Icons.sort, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final item = announcements[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(
                                  item: item,
                                  isDarkMode: isDarkMode,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            elevation: 2,
                            color: isDarkMode ? Colors.grey[900] : Colors.white,
                            shadowColor: Colors.grey.shade200,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${item["depart_city"]} (${item["depart_country"]})",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: isDarkMode ? Colors.white : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Départ: ${item["departure_time"]}",
                                              style: const TextStyle(color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.airplanemode_active, color: Color(0xFF3A7FEA)),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              "${item["destination_city"]} (${item["destination_country"]})",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: isDarkMode ? Colors.white : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Arrivée: ${item["arrival_time"]}",
                                              style: const TextStyle(color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(Icons.line_weight, size: 16, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text("Poids disponible: ${item["weight"]}", style: const TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 22,
                                            backgroundImage: AssetImage(item["carrier_image"]),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            item["carrier_name"],
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                              color: isDarkMode ? Colors.white : Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        item["price"],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: announcements.length,
                    ),
                  ),
                ],
              ),
            ),
            //
            FloatingBottomBar(isDarkMode: isDarkMode),
          ],
        ),
      ),
    );
  }
}
