import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../widgets/app_bar.dart';
import 'detail_screen.dart';

const Color kPrimaryBlue = Color(0xFF3A7FEA);
const Color kDarkBackground = Color(0xFF050816);
const Color kDarkCard = Color(0xFF111727);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDarkMode = true;
  bool _isLoading = true;
  String? _error;

  final List<Map<String, dynamic>> _allAnnouncements = [];
  final List<Map<String, dynamic>> _visibleAnnouncements = [];

  String? _sortMode; // 'date_asc', 'date_desc', 'weight_desc', 'weight_asc'

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('AnnonceCollection')
          .get();

      _allAnnouncements.clear();
      for (final doc in snap.docs) {
        _allAnnouncements.add(_mapAnnonceDoc(doc));
      }

      _visibleAnnouncements
        ..clear()
        ..addAll(_allAnnouncements);

      _applySort(); // tri par défaut (date la plus proche)
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Erreur Firestore: $e');
      setState(() {
        _isLoading = false;
        _error = "Impossible de charger les annonces.";
      });
    }
  }

  Map<String, dynamic> _mapAnnonceDoc(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    final String departPays = (data['departPays'] ?? '').toString();
    final String departVille = (data['departVille'] ?? '').toString();
    final String arriveePays = (data['arriveePays'] ?? '').toString();
    final String arriveeVille = (data['arriveeVille'] ?? '').toString();

    // poids disponible
    final int poids =
        int.tryParse((data['poidsDisponible'] ?? '0').toString()) ?? 0;

    // dates (format Firestore actuel : "13-12-2025")
    final DateTime? voyageDate = _parseSimpleDate(data['dateVoyage']);
    final DateTime? expiresAt = _parseSimpleDate(data['expiresAt']);

    final String departureDateLabel = _formatDate(voyageDate);
    final String arrivalDateLabel = _formatDate(voyageDate);
    final String expiresAtLabel = _formatDate(expiresAt);

    // prix temporaire (en attendant un vrai champ en DB)
    const String tempPrice = '17\$/kg';

    final String numeroTel = (data['numeroTel'] ?? '').toString();

    return {
      'id': doc.id,
      'depart_country': departPays,
      'depart_city': departVille,
      'destination_country': arriveePays,
      'destination_city': arriveeVille,
      'weight': '${poids}Kg',
      'weight_value': poids,
      'voyage_date': voyageDate,
      'departure_date_label': departureDateLabel,
      'arrival_date_label': arrivalDateLabel,
      'expires_at_label': expiresAtLabel,
      'carrier_name': (data['description'] ?? 'Transporteur').toString(),
      'carrier_image': 'assets/img/avatar1.jpg',
      'price': tempPrice,
      'raw_numero_tel': numeroTel,
      'raw_data': data,
    };
  }

  DateTime? _parseSimpleDate(dynamic raw) {
    if (raw == null) return null;
    final String value = raw.toString();
    final parts = value.split('-');
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

  String _formatDate(DateTime? date) {
    if (date == null) return '--';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day-$month-$year';
  }

  void _toggleTheme() {
    setState(() => isDarkMode = !isDarkMode);
  }

  void _openFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _FilterBottomSheet(
          isDarkMode: isDarkMode,
          onReset: () {
            // plus tard on branchera la logique de filtre
          },
          onApply: () {
            Navigator.pop(ctx);
          },
        );
      },
    );
  }

  void _openSortSheet() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _SortBottomSheet(
          isDarkMode: isDarkMode,
          currentSort: _sortMode,
        );
      },
    );

    if (selected != null) {
      setState(() {
        _sortMode = selected;
      });
      _applySort();
    }
  }

  void _applySort() {
    // tri simple en mémoire
    _visibleAnnouncements.sort((a, b) {
      final DateTime? dateA = a['voyage_date'] as DateTime?;
      final DateTime? dateB = b['voyage_date'] as DateTime?;
      final int weightA = (a['weight_value'] as int?) ?? 0;
      final int weightB = (b['weight_value'] as int?) ?? 0;

      switch (_sortMode) {
        case 'date_desc':
          if (dateA == null || dateB == null) return 0;
          return dateB.compareTo(dateA);
        case 'weight_desc':
          return weightB.compareTo(weightA);
        case 'weight_asc':
          return weightA.compareTo(weightB);
        case 'date_asc':
        default:
          if (dateA == null || dateB == null) return 0;
          return dateA.compareTo(dateB);
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool isAuthenticated =
        FirebaseAuth.instance.currentUser != null;

    final Color bgColor =
    isDarkMode ? kDarkBackground : const Color(0xFFF5F6FA);
    final Color primaryText =
    isDarkMode ? Colors.white : Colors.black87;
    final Color secondaryText =
    isDarkMode ? Colors.white70 : Colors.grey[700]!;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        "Annonces",
                        style: TextStyle(
                          color: primaryText,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _toggleTheme,
                        icon: Icon(
                          isDarkMode
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                          color: primaryText,
                        ),
                      ),
                    ],
                  ),
                ),

                // Boutons Filtrer / Trier
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: _TopActionButton(
                          icon: Icons.filter_list,
                          label: "Filtrer",
                          isDarkMode: isDarkMode,
                          onTap: _openFilterSheet,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TopActionButton(
                          icon: Icons.sort,
                          label: "Trier",
                          isDarkMode: isDarkMode,
                          onTap: _openSortSheet,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // LISTE
                Expanded(
                  child: _isLoading
                      ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                      AlwaysStoppedAnimation<Color>(kPrimaryBlue),
                    ),
                  )
                      : _error != null
                      ? Center(
                    child: Text(
                      _error!,
                      style: TextStyle(color: secondaryText),
                    ),
                  )
                      : _visibleAnnouncements.isEmpty
                      ? Center(
                    child: Text(
                      "Aucune annonce disponible.",
                      style: TextStyle(color: secondaryText),
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                        16, 8, 16, 120),
                    itemCount: _visibleAnnouncements.length,
                    itemBuilder: (context, index) {
                      final item =
                      _visibleAnnouncements[index];
                      return _buildAnnouncementCard(
                        context: context,
                        item: item,
                        primaryText: primaryText,
                        secondaryText: secondaryText,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // NAVBAR
          FloatingBottomBar(
            isDarkMode: isDarkMode,
            isAuthenticated: isAuthenticated,
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard({
    required BuildContext context,
    required Map<String, dynamic> item,
    required Color primaryText,
    required Color secondaryText,
  }) {
    final Color cardColor = isDarkMode ? kDarkCard : Colors.white;

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
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ligne 1 : icônes partage / favoris
              // Ligne 2 : pays + villes
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icônes en haut à droite
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.ios_share_outlined,
                          color: secondaryText,
                          size: 20,
                        ),
                        onPressed: () {
                          // sera branché plus tard (Share.plus)
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: Icon(
                          Icons.favorite_border,
                          color: secondaryText,
                          size: 20,
                        ),
                        onPressed: () {
                          // sera branché plus tard (favoris Firestore)
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Pays + villes
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Départ
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['depart_country'] ?? '',
                              style: const TextStyle(
                                color: kPrimaryBlue,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['depart_city'] ?? '',
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Destination
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              item['destination_country'] ?? '',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: kPrimaryBlue,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['destination_city'] ?? '',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Ligne bagage + poids disponibles (en bleu et gras)
              Column(
                children: [
                  Row(
                    children: [
                      _dot(),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Divider(
                          color: Colors.grey.withValues(alpha: 0.4),
                          thickness: 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.luggage,
                        color: kPrimaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Divider(
                          color: Colors.grey.withValues(alpha: 0.4),
                          thickness: 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _dot(),
                    ],
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: item['weight'] ?? '',
                      style: const TextStyle(
                        color: kPrimaryBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      children: const [
                        TextSpan(
                          text: ' disponibles',
                          style: TextStyle(
                            color: kPrimaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Dates (sans heures)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['departure_date_label'] ?? '--',
                        style: const TextStyle(
                          color: kPrimaryBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Départ",
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item['arrival_date_label'] ?? '--',
                        style: const TextStyle(
                          color: kPrimaryBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Arrivée",
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Avatar + nom + prix
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage:
                        AssetImage(item['carrier_image'] ?? ''),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item['carrier_name'] ?? '',
                        style: TextStyle(
                          color: secondaryText,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    item['price'] ?? '17\$/kg',
                    style: const TextStyle(
                      color: kPrimaryBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
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
}

/// Bouton "Filtrer" / "Trier" en haut
class _TopActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _TopActionButton({
    required this.icon,
    required this.label,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor =
    isDarkMode ? Colors.white24 : Colors.black12;
    final Color textColor =
    isDarkMode ? Colors.white : Colors.black87;

    return SizedBox(
      height: 44,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 18,
          color: textColor,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: isDarkMode
              ? Colors.white.withValues(alpha: 0.03)
              : Colors.white,
        ),
      ),
    );
  }
}

/// BOTTOM SHEET : FILTRES
class _FilterBottomSheet extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onApply;
  final VoidCallback onReset;

  const _FilterBottomSheet({
    required this.isDarkMode,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  final TextEditingController _departController = TextEditingController();
  final TextEditingController _arriveeController = TextEditingController();

  bool _onlyVerifiedAds = false;
  bool _onlyVerifiedUsers = false;

  // nouveaux sliders (UI uniquement)
  RangeValues _priceRange = const RangeValues(10, 30); // 10–30 $/kg
  RangeValues _weightRange = const RangeValues(5, 25); // 5–25 kg
  DateTimeRange? _dateRange;

  static const List<String> _cityOptions = [
    'Montréal, Canada',
    'Toronto, Canada',
    'Vancouver, Canada',
    'Dakar, Sénégal',
    'Touba, Sénégal',
    'Paris, France',
    'Lyon, France',
    'Marseille, France',
    'Stockholm, Suède',
    'Casablanca, Maroc',
    'New York, États-Unis',
  ];

  @override
  Widget build(BuildContext context) {
    final Color sheetBg = widget.isDarkMode
        ? const Color(0xFF050816)
        : Colors.white;
    final Color primaryText =
    widget.isDarkMode ? Colors.white : Colors.black87;
    final Color secondaryText =
    widget.isDarkMode ? Colors.white70 : Colors.grey[700]!;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: primaryText,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Text(
                        "Filtres",
                        style: TextStyle(
                          color: primaryText,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          _departController.clear();
                          _arriveeController.clear();
                          setState(() {
                            _onlyVerifiedAds = false;
                            _onlyVerifiedUsers = false;
                            _priceRange = const RangeValues(10, 30);
                            _weightRange = const RangeValues(5, 25);
                            _dateRange = null;
                          });
                          widget.onReset();
                        },
                        child: const Text(
                          "Réinitialiser",
                          style: TextStyle(
                            color: kPrimaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // CONTENU
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    children: [
                      // VILLES
                      Text(
                        "Villes",
                        style: TextStyle(
                          color: primaryText,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _CityAutocompleteField(
                        label: "Départ",
                        controller: _departController,
                        isDarkMode: widget.isDarkMode,
                        options: _cityOptions,
                      ),
                      const SizedBox(height: 12),
                      _CityAutocompleteField(
                        label: "Arrivée",
                        controller: _arriveeController,
                        isDarkMode: widget.isDarkMode,
                        options: _cityOptions,
                      ),

                      const SizedBox(height: 18),
                      Divider(color: Colors.grey.withValues(alpha: 0.4)),
                      const SizedBox(height: 12),

                      // STATUT
                      Text(
                        "Statut",
                        style: TextStyle(
                          color: primaryText,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),

                      CheckboxListTile(
                        value: _onlyVerifiedAds,
                        onChanged: (v) {
                          setState(() => _onlyVerifiedAds = v ?? false);
                        },
                        activeColor: kPrimaryBlue,
                        checkColor: Colors.white,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "Afficher uniquement les annonces vérifiées",
                          style: TextStyle(
                            color: primaryText,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          "(UI uniquement pour l’instant)",
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      CheckboxListTile(
                        value: _onlyVerifiedUsers,
                        onChanged: (v) {
                          setState(() => _onlyVerifiedUsers = v ?? false);
                        },
                        activeColor: kPrimaryBlue,
                        checkColor: Colors.white,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "Afficher uniquement les annonceurs vérifiés",
                          style: TextStyle(
                            color: primaryText,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          "(UI uniquement pour l’instant)",
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),
                      Divider(color: Colors.grey.withValues(alpha: 0.4)),
                      const SizedBox(height: 12),

                      // PRIX
                      Text(
                        "Prix (UI, \$ / kg)",
                        style: TextStyle(
                          color: primaryText,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: 50,
                        divisions: 10,
                        labels: RangeLabels(
                          '\$${_priceRange.start.toStringAsFixed(0)}',
                          '\$${_priceRange.end.toStringAsFixed(0)}',
                        ),
                        activeColor: kPrimaryBlue,
                        inactiveColor:
                        Colors.grey.withValues(alpha: 0.5),
                        onChanged: (values) {
                          setState(() => _priceRange = values);
                        },
                      ),

                      const SizedBox(height: 18),
                      Divider(color: Colors.grey.withValues(alpha: 0.4)),
                      const SizedBox(height: 12),

                      // POIDS
                      Text(
                        "Poids disponible (UI, kg)",
                        style: TextStyle(
                          color: primaryText,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RangeSlider(
                        values: _weightRange,
                        min: 0,
                        max: 50,
                        divisions: 10,
                        labels: RangeLabels(
                          '${_weightRange.start.toStringAsFixed(0)}kg',
                          '${_weightRange.end.toStringAsFixed(0)}kg',
                        ),
                        activeColor: kPrimaryBlue,
                        inactiveColor:
                        Colors.grey.withValues(alpha: 0.5),
                        onChanged: (values) {
                          setState(() => _weightRange = values);
                        },
                      ),

                      const SizedBox(height: 18),
                      Divider(color: Colors.grey.withValues(alpha: 0.4)),
                      const SizedBox(height: 12),

                      // DATES
                      Text(
                        "Dates de voyage",
                        style: TextStyle(
                          color: primaryText,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: widget.isDarkMode
                                ? Colors.white24
                                : Colors.grey.withValues(alpha: 0.4),
                          ),
                          backgroundColor: widget.isDarkMode
                              ? Colors.white.withValues(alpha: 0.04)
                              : const Color(0xFFF3F4F8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final now = DateTime.now();
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: now.subtract(const Duration(days: 1)),
                            lastDate: now.add(const Duration(days: 365)),
                            initialDateRange: _dateRange ??
                                DateTimeRange(
                                  start: now,
                                  end: now.add(const Duration(days: 7)),
                                ),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: Theme.of(context)
                                      .colorScheme
                                      .copyWith(
                                    primary: kPrimaryBlue,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() => _dateRange = picked);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _dateRange == null
                                  ? "Toutes les dates"
                                  : "${_formatShort(_dateRange!.start)}  -  ${_formatShort(_dateRange!.end)}",
                              style: TextStyle(
                                color: primaryText,
                                fontSize: 14,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 18,
                              color: kPrimaryBlue,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // BOUTON APPLIQUER
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: widget.onApply,
                      child: const Text(
                        "Afficher les résultats",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatShort(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d-$m-$y';
  }
}

class _CityAutocompleteField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isDarkMode;
  final List<String> options;

  const _CityAutocompleteField({
    required this.label,
    required this.controller,
    required this.isDarkMode,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryText =
    isDarkMode ? Colors.white : Colors.black87;
    final Color hintText =
    isDarkMode ? Colors.white54 : Colors.grey[600]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: primaryText,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue value) {
            if (value.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            final input = value.text.toLowerCase();
            return options.where(
                  (o) => o.toLowerCase().contains(input),
            );
          },
          onSelected: (selection) {
            controller.text = selection;
          },
          fieldViewBuilder:
              (context, textController, focusNode, onFieldSubmitted) {
            // garder le texte externe synchronisé
            textController.text = controller.text;
            textController.selection = TextSelection.fromPosition(
              TextPosition(offset: textController.text.length),
            );
            return TextField(
              controller: textController,
              focusNode: focusNode,
              style: TextStyle(color: primaryText),
              decoration: InputDecoration(
                hintText: "Ville, Pays",
                hintStyle: TextStyle(color: hintText),
                filled: true,
                fillColor: isDarkMode
                    ? Colors.white.withValues(alpha: 0.04)
                    : const Color(0xFFF3F4F8),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDarkMode
                        ? Colors.white24
                        : Colors.grey.withValues(alpha: 0.4),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: kPrimaryBlue, // bleu SendPacket
                    width: 1.6,
                  ),
                ),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: isDarkMode
                    ? const Color(0xFF111727)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: options.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final opt = options.elementAt(index);
                      return ListTile(
                        title: Text(
                          opt,
                          style: TextStyle(
                            color: primaryText,
                            fontSize: 14,
                          ),
                        ),
                        onTap: () => onSelected(opt),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// BOTTOM SHEET : TRI
class _SortBottomSheet extends StatelessWidget {
  final bool isDarkMode;
  final String? currentSort;

  const _SortBottomSheet({
    required this.isDarkMode,
    required this.currentSort,
  });

  @override
  Widget build(BuildContext context) {
    final Color sheetBg = isDarkMode
        ? const Color(0xFF050816)
        : Colors.white;
    final Color primaryText =
    isDarkMode ? Colors.white : Colors.black87;
    final Color secondaryText =
    isDarkMode ? Colors.white70 : Colors.grey[700]!;

    Widget buildOption({
      required String value,
      required String title,
      required String subtitle,
    }) {
      final bool selected = currentSort == value;
      return ListTile(
        onTap: () => Navigator.pop(context, value),
        title: Text(
          title,
          style: TextStyle(
            color: primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: secondaryText,
            fontSize: 12,
          ),
        ),
        trailing: selected
            ? const Icon(Icons.check, color: kPrimaryBlue)
            : null,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: primaryText,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    "Trier",
                    style: TextStyle(
                      color: primaryText,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const Divider(height: 1),

            buildOption(
              value: 'date_asc',
              title: "Date la plus proche",
              subtitle: "Annonces avec la date de voyage la plus proche",
            ),
            buildOption(
              value: 'date_desc',
              title: "Date la plus lointaine",
              subtitle: "Annonces les plus éloignées dans le temps",
            ),
            buildOption(
              value: 'weight_desc',
              title: "Poids disponible décroissant",
              subtitle: "Plus de kg disponibles en premier",
            ),
            buildOption(
              value: 'weight_asc',
              title: "Poids disponible croissant",
              subtitle: "Moins de kg disponibles en premier",
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
