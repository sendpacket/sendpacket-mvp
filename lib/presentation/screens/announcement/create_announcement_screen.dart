import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:country_picker/country_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../data/model/announcement_model.dart';

const Color kPrimaryBlue = Color(0xFF3A7FEA);
const Color kDarkBackground = Color(0xFF050816);
const Color kLightBackground = Color(0xFFF7F9FC);
const Color kDarkCard = Color(0xFF111727);

class CreateAnnouncementScreen extends StatefulWidget {
  final bool isDarkMode;
  const CreateAnnouncementScreen({super.key, required this.isDarkMode});

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  int _currentStep = 0;
  bool _hasStarted = false;
  bool _isSubmitting = false;

  // -------- TRAJET --------
  String? _departCountry;
  String? _departCity;
  String? _arriveCountry;
  String? _arriveCity;

  final Map<String, List<String>> cities = {
    "Canada": ["Montréal", "Toronto", "Vancouver"],
    "Senegal": ["Dakar", "Thiès", "Saint-Louis"],
    "France": ["Paris", "Lyon", "lens"],
  };

  // -------- DATES --------
  DateTime? _dateVoyage;
  DateTime? _expiresAt;

  // -------- POIDS & PRIX --------
  double _poids = 10;
  final TextEditingController _priceCtrl = TextEditingController();
  String? _fullPhoneNumber;
  bool _useWhatsapp = true;
  final TextEditingController _descriptionCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _priceCtrl.dispose();
    _descriptionCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ========= THEME HELPERS =========

  bool get _isDark => widget.isDarkMode;

  Color get _bg => _isDark ? kDarkBackground : kLightBackground;
  Color get _card => _isDark ? kDarkCard : Colors.white;
  Color get _primaryText => _isDark ? Colors.white : Colors.black87;
  Color? get _secondaryText => _isDark ? Colors.white70 : Colors.grey[700];

  Color get _inputBg =>
      _isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade100;

  List<BoxShadow> get _cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: _isDark ? 0.35 : 0.08),
      blurRadius: 18,
      offset: const Offset(0, 10),
    ),
  ];

  InputDecoration _inputDecoration({
    required String label,
    IconData? prefixIcon,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: _inputBg,
      labelText: label,
      labelStyle: TextStyle(color: _secondaryText),
      alignLabelWithHint: alignLabelWithHint,
      prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, color: kPrimaryBlue),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kPrimaryBlue),
      ),
    );
  }

  Widget _cardContainer({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
    EdgeInsets? margin,
  }) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: _cardShadow,
      ),
      child: child,
    );
  }

  // ========= HELPERS =========

  String _formatDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year.toString();
    return "$day-$month-$year";
  }

  Future<void> _pickDate({
    required DateTime? initial,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 3),
      builder: (context, child) {
        final baseTheme = Theme.of(context);

        return Theme(
          data: baseTheme.copyWith(
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
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: kPrimaryBlue,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onSelected(picked);
    }
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ========= VALIDATION PAR STEP =========

  bool _validateStep() {
    switch (_currentStep) {
      case 0: // TRAJET
        if (_departCountry == null ||
            _departCity == null ||
            _arriveCountry == null ||
            _arriveCity == null) {
          _showSnack("Complète les lieux de départ et d’arrivée.");
          return false;
        }
        if (_departCountry == _arriveCountry && _departCity == _arriveCity) {
          _showSnack("Le lieu de départ doit être différent du lieu d’arrivée.");
          return false;
        }
        return true;

      case 1: // DATES + POIDS
        if (_dateVoyage == null || _expiresAt == null) {
          _showSnack("Choisis les deux dates.");
          return false;
        }

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        final depart = DateTime(_dateVoyage!.year, _dateVoyage!.month, _dateVoyage!.day);
        final expiration = DateTime(_expiresAt!.year, _expiresAt!.month, _expiresAt!.day);

        if (depart.isBefore(today)) {
          _showSnack("La date de départ doit être future.");
          return false;
        }
        if (expiration.isBefore(today)) {
          _showSnack("L’expiration doit être ≥ aujourd’hui.");
          return false;
        }

        if (expiration.isAfter(depart)) {
          _showSnack("La date d’expiration doit être antérieure ou égale à la date du voyage.");
          return false;
        }

        final price = num.tryParse(_priceCtrl.text.trim());
        if (price == null || price <= 0) {
          _showSnack("Prix invalide.");
          return false;
        }

        return true;

      case 2: // CONTACT
        if (_fullPhoneNumber == null || _fullPhoneNumber!.replaceAll(" ", "").length < 6) {
          _showSnack("Numéro de téléphone invalide.");
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  void _next() {
    if (_currentStep == 2) {
      _fullPhoneNumber = _phoneCtrl.text;
    }
    if (_validateStep()) {
      setState(() => _currentStep++);
    }
  }

  void _previous() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  // ========= FIRESTORE SUBMIT =========

  Future<void> _submit() async {
    if (!_validateStep()) return;

    setState(() => _isSubmitting = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(kPrimaryBlue),
        ),
      ),
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pop(context);
        _showSnack("Utilisateur non connecté.");
        return;
      }

      final existing = await FirebaseFirestore.instance
          .collection("AnnonceCollection")
          .where("ownerId", isEqualTo: user.uid)
          .get();

      if (existing.docs.length >= 3) {
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pop();
        await _showLimitBottomSheet();
        return;
      }

      final now = DateTime.now();
      final todayStr = _formatDate(now);
      final dateVoyageStr = _formatDate(_dateVoyage!);
      final expiresStr = _formatDate(_expiresAt!);

      final annonce = Announcement(
        departPays: _departCountry!,
        departVille: _departCity!,
        arriveePays: _arriveCountry!,
        arriveeVille: _arriveCity!,
        createdAt: todayStr,
        dateVoyage: dateVoyageStr,
        expiresAt: expiresStr,
        numeroTel: _fullPhoneNumber!,
        poidsDisponible: _poids.round(),
        pricePerKilo: num.tryParse(_priceCtrl.text.trim().replaceAll(',', '.')) ?? 0,
        whatsapp: _useWhatsapp,
        isBoosted: false,
        ownerId: user.uid,
        description: _descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text,
      );

      await FirebaseFirestore.instance
          .collection("AnnonceCollection")
          .add(annonce.toMap());

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      await _showSuccessSheet();

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      Navigator.pop(context);
      _showSnack("Erreur : $e");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _showSuccessSheet() async {
    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: kPrimaryBlue, size: 64),
            const SizedBox(height: 12),
            Text(
              "Annonce publiée 🎉",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryText),
            ),
            const SizedBox(height: 8),
            Text(
              "Votre annonce est maintenant visible par les utilisateurs.",
              textAlign: TextAlign.center,
              style: TextStyle(color: _secondaryText),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Retour à l’accueil"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLimitBottomSheet() async {
    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: _LimitSheetContent(isDark: _isDark),
      ),
    );
  }


  // ========= INTRO =========

  Widget _introPage() {
    final bgColor = _isDark ? kDarkBackground : const Color(0xFFF7F9FC);
    final primaryText = _isDark ? Colors.white : Colors.black87;
    final secondaryText = _isDark ? Colors.white70 : Colors.grey[700];

    return Container(
      color: bgColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            "Avant de publier une annonce",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primaryText,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Pour garantir votre sécurité et celle des autres utilisateurs, "
                "merci de prendre connaissance des recommandations suivantes :",
            style: TextStyle(fontSize: 15, color: secondaryText),
          ),
          const SizedBox(height: 24),
          _adviceItem(
            "Inspectez soigneusement les colis",
            "Assurez-vous qu’ils ne contiennent aucun objet interdit "
                "(substances illicites, armes, objets dangereux, etc.).",
          ),
          _adviceItem(
            "Planifiez la livraison à l’avance",
            "Convenez clairement avec le client des modalités de réception "
                "et des personnes à contacter à l’arrivée.",
          ),
          _adviceItem(
            "Privilégiez un lieu public",
            "Fixez les rencontres dans des lieux publics et fréquentés "
                "pour plus de sécurité.",
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => setState(() => _hasStarted = true),
              child: const Text(
                "Commencer",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _adviceItem(String title, String description) {
    return _cardContainer(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: kPrimaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _primaryText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(color: _secondaryText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========= UI =========

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
        titleTextStyle: TextStyle(
          color: _isDark ? Colors.white : Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        title: const Text("Créer une annonce"),
      ),
      body: _hasStarted
          ? Stack(
        children: [
          Column(
            children: [
              _stepIndicator(),
              const Divider(height: 1),
              Expanded(child: _stepBody()),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: _bottomButtons(),
            ),
          ),
        ],
      )
          : _introPage(),
    );
  }

  Widget _stepIndicator() {
    final titles = ["Trajet", "Voyage", "Contact", "Résumé"];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(titles.length, (i) {
          final active = i == _currentStep;
          final done = i < _currentStep;

          final color = (active || done)
              ? kPrimaryBlue
              : kPrimaryBlue.withValues(alpha: 0.25);

          return Expanded(
            child: Column(
              children: [
                Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  titles[i],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    color: active ? kPrimaryBlue : _secondaryText,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _stepBody() {
    switch (_currentStep) {
      case 0:
        return _stepTrajet();
      case 1:
        return _stepDatesPoids();
      case 2:
        return _stepContact();
      case 3:
      default:
        return _stepResume();
    }
  }

  // --------- STEP 0 : TRAJET ---------
  Widget _stepTrajet() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _countryCityCard(
            title: "Lieu de départ",
            selectedCountry: _departCountry,
            selectedCity: _departCity,
            onPickCountry: (c) {
              setState(() {
                _departCountry = c;
                _departCity = null;
              });
            },
            onPickCity: (c) => setState(() => _departCity = c),
          ),
          const SizedBox(height: 16),
          _countryCityCard(
            title: "Lieu d’arrivée",
            selectedCountry: _arriveCountry,
            selectedCity: _arriveCity,
            onPickCountry: (c) {
              setState(() {
                _arriveCountry = c;
                _arriveCity = null;
              });
            },
            onPickCity: (c) => setState(() => _arriveCity = c),
          ),
        ],
      ),
    );
  }

  Widget _countryCityCard({
    required String title,
    required String? selectedCountry,
    required String? selectedCity,
    required Function(String) onPickCountry,
    required Function(String) onPickCity,
  }) {
    final list = selectedCountry == null ? <String>[] : (cities[selectedCountry] ?? []);

    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _primaryText,
            ),
          ),
          const SizedBox(height: 12),

          // ---------- COUNTRY PICKER ----------
          GestureDetector(
            onTap: () {
              showCountryPicker(
                context: context,
                showPhoneCode: false,
                countryListTheme: CountryListThemeData(
                  backgroundColor: _isDark ? kDarkBackground : Colors.white,
                  textStyle: TextStyle(color: _primaryText),
                  searchTextStyle: TextStyle(color: _primaryText),
                  inputDecoration: InputDecoration(
                    filled: true,
                    fillColor: _isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.grey.shade100,
                    prefixIcon: const Icon(Icons.search, color: kPrimaryBlue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                onSelect: (c) => onPickCountry(c.name),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: _inputBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedCountry ?? "Sélectionner un pays",
                      style: TextStyle(
                        color: selectedCountry == null ? _secondaryText : _primaryText,
                      ),
                    ),
                  ),
                  const Icon(Icons.expand_more, color: kPrimaryBlue),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ---------- CITY DROPDOWN ----------
          Theme(
            data: Theme.of(context).copyWith(
              canvasColor: _card,
              splashColor: Colors.transparent,
              highlightColor: kPrimaryBlue.withValues(alpha: 0.08),
            ),
            child: DropdownButtonFormField<String>(
              initialValue: selectedCity,
              hint: Text(
                "Ville",
                style: TextStyle(
                  color: _isDark ? Colors.white60 : Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              dropdownColor: _card,
              iconEnabledColor: kPrimaryBlue,
              style: TextStyle(
                color: _primaryText,
                fontWeight: FontWeight.w500,
              ),
              items: list
                  .map((c) => DropdownMenuItem<String>(
                value: c,
                child: Text(c, style: TextStyle(color: _primaryText)),
              ))
                  .toList(),
              onChanged: list.isEmpty ? null : (v) => onPickCity(v!),
              decoration: InputDecoration(
                filled: true,
                fillColor: _inputBg,
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
          ),
        ],
      ),
    );
  }

  // --------- STEP  : DATES ---------
  Widget _stepDates() {
    return Column(
      children: [
        _readonlyDateField(
          label: "Date du voyage",
          icon: Icons.flight_takeoff,
          value: _dateVoyage,
          onPick: (d) => setState(() => _dateVoyage = d),
        ),
        const SizedBox(height: 16),
        _readonlyDateField(
          label: "Expiration de l’annonce",
          icon: Icons.event_busy,
          value: _expiresAt,
          onPick: (d) => setState(() => _expiresAt = d),
        ),
      ],
    );
  }

  Widget _readonlyDateField({
    required String label,
    required IconData icon,
    required DateTime? value,
    required ValueChanged<DateTime> onPick,
  }) {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: value == null ? "" : _formatDate(value)),
      onTap: () => _pickDate(initial: value, onSelected: onPick),
      decoration: _inputDecoration(label: label, prefixIcon: icon),
      style: TextStyle(color: _primaryText),
    );
  }

  // --------- STEP : POIDS-PRIX ---------
  Widget _stepPoidsPrix() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _inputBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Poids disponible (1–100Kg)",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _primaryText,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  "${_poids.round()} Kg",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 8),
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
                  label: "${_poids.round()} Kg",
                  value: _poids,
                  onChanged: (v) => setState(() => _poids = v),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _priceCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _inputDecoration(label: "Prix (\$/kg)", prefixIcon: Icons.attach_money),
          style: TextStyle(color: _primaryText),
        ),
      ],
    );
  }

  // --------- STEP 2 : DATES + POIDS-PRIX ---------
  Widget _stepDatesPoids() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _stepDates(),
          const SizedBox(height: 24),
          _stepPoidsPrix(),
        ],
      ),
    );
  }

  // --------- STEP 3 : CONTACT ---------
  Widget _stepContact() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          IntlPhoneField(
            controller: _phoneCtrl,
            initialCountryCode: "CA",
            onChanged: (phone) {
              _fullPhoneNumber = phone.completeNumber;
            },
            decoration: _inputDecoration(label: "Numéro de téléphone"),
            style: TextStyle(color: _primaryText),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _inputBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(FontAwesomeIcons.whatsapp, color: kPrimaryBlue, size: 20),
                const SizedBox(width: 10),
                Text(
                  "WhatsApp",
                  style: TextStyle(
                    color: _primaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _useWhatsapp,
                  activeThumbColor: kPrimaryBlue,
                  activeTrackColor: kPrimaryBlue.withValues(alpha: 0.35),
                  onChanged: (v) => setState(() => _useWhatsapp = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _descriptionCtrl,
            maxLines: 4,
            decoration: _inputDecoration(
              label: "Description (optionnel)",
              alignLabelWithHint: true,
            ),
            style: TextStyle(color: _primaryText),
          ),
        ],
      ),
    );
  }

  // --------- STEP 4 : RÉSUMÉ ---------
  Widget _stepResume() {
    final bgColor = _isDark ? kDarkBackground : const Color(0xFFF7F9FC);
    final secondary = _isDark ? Colors.white70 : Colors.grey[700];

    return Container(
      color: bgColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Résumé de l'annonce",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _primaryText,
              ),
            ),
            const SizedBox(height: 24),

            _resumeCard(
              title: "Trajet",
              children: [
                _resumeRow(
                  label: "${_departCity ?? '—'} (${_departCountry ?? '—'})",
                  icon: Icons.flight_takeoff,
                ),
                const SizedBox(height: 8),
                _resumeRow(
                  label: "${_arriveCity ?? '—'} (${_arriveCountry ?? '—'})",
                  icon: Icons.flight_land,
                ),
              ],
            ),
            const SizedBox(height: 20),

            _resumeCard(
              title: "Dates du voyage",
              children: [
                _resumeRow(
                  label: "Départ : ${_dateVoyage == null ? '—' : _formatDate(_dateVoyage!)}",
                  icon: Icons.calendar_today,
                ),
                const SizedBox(height: 8),
                _resumeRow(
                  label: "Expiration : ${_expiresAt == null ? '—' : _formatDate(_expiresAt!)}",
                  icon: Icons.timer_off,
                ),
              ],
            ),
            const SizedBox(height: 20),

            _resumeCard(
              title: "Détails de l'annonce",
              children: [
                _resumeRow(
                  label: "Poids disponible : ${_poids.round()} Kg",
                  icon: Icons.monitor_weight,
                ),
                const SizedBox(height: 8),
                _resumeRow(
                  label: _priceCtrl.text.isEmpty ? "Prix : —" : "Prix : ${_priceCtrl.text}\$/kg",
                  icon: Icons.attach_money,
                ),
                if (_descriptionCtrl.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _resumeRow(
                    label: _descriptionCtrl.text,
                    icon: Icons.description,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            _resumeCard(
              title: "Contact",
              children: [
                _resumeRow(
                  label: _fullPhoneNumber ?? "—",
                  icon: Icons.phone,
                ),
                const SizedBox(height: 8),
                _resumeRow(
                  label: _useWhatsapp ? "WhatsApp activé" : "WhatsApp désactivé",
                  icon: FontAwesomeIcons.whatsapp,
                ),
              ],
            ),

            const SizedBox(height: 32),
            Text(
              "Veuillez vérifier vos informations avant de publier.",
              style: TextStyle(fontSize: 13, color: secondary),
            ),
            const SizedBox(height: 140),
          ],
        ),
      ),
    );
  }

  Widget _resumeCard({
    required String title,
    required List<Widget> children,
  }) {
    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _primaryText,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _resumeRow({
    required String label,
    required IconData icon,
  }) {
    final textColor = _isDark ? Colors.white70 : Colors.grey[800];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: kPrimaryBlue),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  // --------- BOUTONS BAS ---------
  Widget _bottomButtons() {
    final isLast = _currentStep == 3;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : _previous,
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimaryBlue,
                  side: BorderSide(color: kPrimaryBlue.withValues(alpha: 0.6)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Retour",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : (isLast ? _submit : _next),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryBlue,
                disabledBackgroundColor: kPrimaryBlue.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text(
                isLast ? "Publier" : "Suivant",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LimitSheetContent extends StatelessWidget {
  final bool isDark;
  const _LimitSheetContent({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final primaryText = isDark ? Colors.white : Colors.black87;
    final secondaryText = isDark ? Colors.white70 : Colors.grey[700];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.warning_amber_rounded,
          color: Colors.orange,
          size: 64,
        ),
        const SizedBox(height: 12),
        Text(
          "Limite atteinte",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Vous avez déjà 3 annonces actives.\n"
              "Veuillez supprimer une annonce existante avant d’en publier une nouvelle.",
          textAlign: TextAlign.center,
          style: TextStyle(color: secondaryText),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Retour à la liste"),
          ),
        ),
      ],
    );
  }
}
