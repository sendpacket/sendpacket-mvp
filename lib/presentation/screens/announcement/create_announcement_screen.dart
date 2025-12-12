import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:country_picker/country_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../data/model/announcement_model.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState
    extends State<CreateAnnouncementScreen> {
  int _currentStep = 0;
  bool _hasStarted = false;
  bool _isSubmitting = false;

  // -------- TRAJET --------
  String? _departCountry;
  String? _departCity;
  String? _arriveCountry;
  String? _arriveCity;

  // villes disponibles par pays (modifiable)
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

  // -------- CONTACT --------
  String? _fullPhoneNumber;
  bool _useWhatsapp = true;
  final TextEditingController _descriptionCtrl = TextEditingController();

  @override
  void dispose() {
    _priceCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
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
    );
    if (picked != null) onSelected(picked);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ========= VALIDATION PAR STEP =========

  bool _validateStep() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_currentStep) {
      case 0: // TRAJET
        if (_departCountry == null ||
            _departCity == null ||
            _arriveCountry == null ||
            _arriveCity == null) {
          _showSnack("Complète les lieux de départ et d’arrivée.");
          return false;
        }
        if (_departCountry == _arriveCountry &&
            _departCity == _arriveCity) {
          _showSnack("Le lieu de départ doit être différent du lieu d’arrivée.");
          return false;
        }
        return true;

      case 1: // DATES
        if (_dateVoyage == null || _expiresAt == null) {
          _showSnack("Choisis les deux dates.");
          return false;
        }

        final depart = DateTime(
            _dateVoyage!.year, _dateVoyage!.month, _dateVoyage!.day);
        final expiration = DateTime(
            _expiresAt!.year, _expiresAt!.month, _expiresAt!.day);

        if (depart.isBefore(today)) {
          _showSnack("La date de départ doit être future.");
          return false;
        }
        if (expiration.isBefore(today)) {
          _showSnack("L’expiration doit être ≥ aujourd’hui.");
          return false;
        }
        if (expiration.isAfter(depart)) {
          _showSnack("Expiration ≤ date de départ.");
          return false;
        }
        return true;

      case 2: // POIDS + PRIX
        final price = num.tryParse(_priceCtrl.text.trim());
        if (price == null || price <= 0) {
          _showSnack("Prix invalide.");
          return false;
        }
        return true;

      case 3: // CONTACT
        if (_fullPhoneNumber == null ||
            _fullPhoneNumber!.replaceAll(" ", "").length < 6) {
          _showSnack("Numéro de téléphone invalide.");
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  void _next() {
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

    // Loader modal
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pop(context);
        _showSnack("Utilisateur non connecté.");
        return;
      }

      // Limite de 3 annonces
      final existing = await FirebaseFirestore.instance
          .collection("AnnonceCollection")
          .where("ownerId", isEqualTo: user.uid)
          .get();

      if (existing.docs.length >= 3) {
        Navigator.of(context, rootNavigator: true).pop(); // ferme loader
        await _showLimitBottomSheet();
        return;
      }

      // formattage dates
      final now = DateTime.now();
      final todayStr = _formatDate(now);
      final dateVoyageStr = _formatDate(_dateVoyage!);
      final expiresStr = _formatDate(_expiresAt!);

      // récupération infos user
      String? firstName;
      String? lastName;
      String? image;

      try {
        final u = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();

        final d = u.data();
        if (d != null) {
          firstName = d['firstName']?.toString();
          lastName = d['lastName']?.toString();
          image = d['profileImage']?.toString();
        }
      } catch (_) {}

      final annonce = Announcement(
        id: DateTime.now().millisecondsSinceEpoch,
        departPays: _departCountry!,
        departVille: _departCity!,
        arriveePays: _arriveCountry!,
        arriveeVille: _arriveCity!,
        createdAt: todayStr,
        dateVoyage: dateVoyageStr,
        expiresAt: expiresStr,
        numeroTel: _fullPhoneNumber!,
        poidsDisponible: _poids.round(),
        pricePerKilo:
        num.tryParse(_priceCtrl.text.trim().replaceAll(',', '.')) ?? 0,
        whatsapp: _useWhatsapp,
        isBoosted: false,
        ownerId: user.uid,
        description:
        _descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text,
        ownerFirstName: firstName,
        ownerLastName: lastName,
        ownerProfileImage: image,
      );

      await FirebaseFirestore.instance
          .collection("AnnonceCollection")
          .add(annonce.toMap());

      // ferme loader
      Navigator.of(context, rootNavigator: true).pop();

      await _showSuccessSheet();

      Navigator.pop(context, true);
    } catch (e) {
      Navigator.pop(context);
      _showSnack("Erreur : $e");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  //Message ajout reussi
  Future<void> _showSuccessSheet() async {
    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 12),
            const Text("Annonce publiée 🎉",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text(
              "Votre annonce est maintenant visible par les utilisateurs.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text("Retour à l’accueil"),
                onPressed: () => Navigator.pop(context),
              ),
            )
          ],
        ),
      ),
    );
  }

// Limites de 3 annonces atteint
  Future<void> _showLimitBottomSheet() async {
    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Colors.orange, size: 64),
            const SizedBox(height: 12),
            const Text(
              "Limite atteinte",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Vous avez déjà 3 annonces actives.\n"
                  "Veuillez supprimer une annonce existante avant d’en publier une nouvelle.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text("Retour à la liste"),
                onPressed: () {
                  Navigator.pop(context); // ferme bottom sheet
                  Navigator.pop(context); // retour HomeScreen
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _introPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          const Text(
            "Avant de publier une annonce",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          const Text(
            "Pour garantir votre sécurité et celle des autres utilisateurs, "
                "merci de prendre connaissance des recommandations suivantes :",
            style: TextStyle(fontSize: 15),
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
            child: ElevatedButton(
              onPressed: () => setState(() => _hasStarted = true),
              child: const Text("Commencer"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _adviceItem(String title, String description) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.85),
                  ),
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
      appBar: AppBar(
        title: const Text("Créer une annonce"),
      ),
      body: _hasStarted
          ? Column(
        children: [
          _stepIndicator(),
          const Divider(height: 1),
          Expanded(child: _stepBody()),
          _bottomButtons(),
        ],
      )
          : _introPage(),
    );
  }

  Widget _stepIndicator() {
    final titles = ["Trajet", "Dates", "Poids", "Contact", "Résumé"];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: List.generate(5, (i) {
          final active = i == _currentStep;
          final done = i < _currentStep;

          Color c = done
              ? Colors.green
              : (active ? Colors.blue : Colors.grey.shade300);

          return Expanded(
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  titles[i],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: active ? FontWeight.bold : FontWeight.w400,
                    color: active
                        ? Colors.blue
                        : (done ? Colors.green : Colors.grey.shade600),
                  ),
                )
              ],
            ),
          );
        }),
      ),
    );
  }

  // --------- STEP BODY ---------
  Widget _stepBody() {
    switch (_currentStep) {
      case 0:
        return _stepTrajet();
      case 1:
        return _stepDates();
      case 2:
        return _stepPoidsPrix();
      case 3:
        return _stepContact();
      case 4:
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
    final list = selectedCountry == null
        ? <String>[]
        : (cities[selectedCountry] ?? []);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // COUNTRY PICKER
            GestureDetector(
              onTap: () {
                showCountryPicker(
                  context: context,
                  showPhoneCode: false,
                  onSelect: (Country c) => onPickCountry(c.name),
                );
              },
              child: Container(
                padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedCountry ?? "Sélectionner un pays",
                        style: TextStyle(
                          color: selectedCountry == null
                              ? Colors.grey.shade500
                              : Colors.black,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // CITY DROPDOWN
            DropdownButtonFormField<String>(
              value: selectedCity,
              decoration: InputDecoration(
                labelText: "Ville",
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: list
                  .map((city) =>
                  DropdownMenuItem(value: city, child: Text(city)))
                  .toList(),
              onChanged:
              list.isEmpty ? null : (v) => onPickCity(v.toString()),
            ),
          ],
        ),
      ),
    );
  }

  // --------- STEP 1 : DATES ---------
  Widget _stepDates() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextFormField(
            readOnly: true,
            controller: TextEditingController(
              text: _dateVoyage == null ? "" : _formatDate(_dateVoyage!),
            ),
            decoration: const InputDecoration(
                labelText: "Date du voyage",
                prefixIcon: Icon(Icons.flight_takeoff),
                border: OutlineInputBorder()),
            onTap: () => _pickDate(
                initial: _dateVoyage,
                onSelected: (d) => setState(() => _dateVoyage = d)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            readOnly: true,
            controller: TextEditingController(
              text: _expiresAt == null ? "" : _formatDate(_expiresAt!),
            ),
            decoration: const InputDecoration(
                labelText: "Expiration de l’annonce",
                prefixIcon: Icon(Icons.event_busy),
                border: OutlineInputBorder()),
            onTap: () => _pickDate(
                initial: _expiresAt,
                onSelected: (d) => setState(() => _expiresAt = d)),
          ),
        ],
      ),
    );
  }

  // --------- STEP 2 : POIDS & PRIX ---------
  Widget _stepPoidsPrix() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Poids disponible (1–100Kg)",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Center(
            child: Text("${_poids.round()} Kg",
                style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Slider(
            min: 1,
            max: 50,
            divisions: 99,
            label: "${_poids.round()} Kg",
            value: _poids,
            onChanged: (v) => setState(() => _poids = v),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _priceCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Prix (\$/kg)",
              prefixIcon: Icon(Icons.attach_money),
            ),
          )
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
          IntlPhoneField(
            decoration: const InputDecoration(
              labelText: "Numéro de téléphone",
              border: OutlineInputBorder(),
            ),
            initialCountryCode: "CA",
            onChanged: (phone) {
              _fullPhoneNumber = phone.completeNumber;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(FontAwesomeIcons.whatsapp, color: Colors.green),
              const SizedBox(width: 8),
              const Text("WhatsApp"),
              const Spacer(),
              Switch(
                value: _useWhatsapp,
                onChanged: (v) => setState(() => _useWhatsapp = v),
              )
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Description (optionnel)",
            ),
          )
        ],
      ),
    );
  }

  // --------- STEP 4 : RÉSUMÉ ---------
  Widget _stepResume() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- Title ----------
          const Text(
            "Résumé de l'annonce",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // ---------- Trajet ----------
          const Text(
            "Trajet",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.flight_takeoff, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "${_departCity ?? '—'} (${_departCountry ?? '—'})",
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.flight_land, size: 20, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "${_arriveCity ?? '—'} (${_arriveCountry ?? '—'})",
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade300, thickness: 1),
          const SizedBox(height: 20),

          // ---------- Dates ----------
          const Text(
            "Dates du voyage",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.calendar_today, size: 20, color: Colors.deepPurple),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Départ : ${_dateVoyage == null ? '—' : _formatDate(_dateVoyage!)}",
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.timer_off, size: 20, color: Colors.redAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Expiration : ${_expiresAt == null ? '—' : _formatDate(_expiresAt!)}",
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade300, thickness: 1),
          const SizedBox(height: 20),

          // ---------- Détails ----------
          const Text(
            "Détails de l'annonce",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.monitor_weight, size: 20, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Poids disponible : ${_poids.round()} Kg",
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.attach_money, size: 20, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Prix : ${_priceCtrl.text.isEmpty ? "—" : "${_priceCtrl.text}\$/kg"}",
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),

          if (_descriptionCtrl.text.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.description, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _descriptionCtrl.text,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade300, thickness: 1),
          const SizedBox(height: 20),

          // ---------- Contact ----------
          const Text(
            "Contact",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.phone, size: 20, color: Colors.blueGrey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _fullPhoneNumber ?? "—",
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(FontAwesomeIcons.whatsapp, size: 22, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _useWhatsapp ? "WhatsApp activé" : "WhatsApp désactivé",
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          const Text(
            "Veuillez vérifier vos informations avant de publier.",
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }


  // --------- BOUTONS BAS ---------
  Widget _bottomButtons() {
    final isLast = _currentStep == 4;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : _previous,
                child: const Text("Retour"),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : (isLast ? _submit : _next),
              child: _isSubmitting
                  ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(isLast ? "Publier" : "Suivant"),
            ),
          ),
        ],
      ),
    );
  }
}
