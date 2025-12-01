import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class VerifyIdentityScreen extends StatefulWidget {
  final bool isDarkMode;
  const VerifyIdentityScreen({super.key, required this.isDarkMode});

  @override
  State<VerifyIdentityScreen> createState() => _VerifyIdentityScreenState();
}

class _VerifyIdentityScreenState extends State<VerifyIdentityScreen> {
  int currentStep = 0;

  final TextEditingController firstNameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController birthDateCtrl = TextEditingController();
  final TextEditingController birthCountryCtrl = TextEditingController();

  List<String> countries = [];
  bool loadingCountries = true;

  String? selectedDocType;

  bool documentDone = false;
  bool selfieDone = false;
  bool selfieDocDone = false;

  XFile? pickedDocument;
  XFile? pickedSelfie;
  XFile? pickedSelfieWithDoc;

  @override
  void initState() {
    super.initState();
    fetchCountries();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) showWelcomePopup();
    });
  }

  Future<void> fetchCountries() async {
    try {
      final res = await http.get(Uri.parse("https://restcountries.com/v3.1/all"));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        countries = data
            .map<String>((c) => c["name"]["common"].toString())
            .toList()
          ..sort();
      }
    } catch (_) {}
    if (mounted) setState(() => loadingCountries = false);
  }

  Future<XFile?> openCamera() async {
    final picker = ImagePicker();
    return picker.pickImage(source: ImageSource.camera);
  }

  void showWelcomePopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(dialogContext).size.width * 0.85,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_user,
                      size: 60, color: Colors.blueAccent),
                  const SizedBox(height: 16),
                  const Text(
                    "Vérification d'identité",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Vos données ne seront jamais partagées.\n\n"
                        "La vérification est obligatoire pour publier des annonces.",
                    style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        if (!mounted) return;
                        setState(() => currentStep = 1);
                      },
                      child: const Text(
                        "Commencer",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> instructionThenCamera({
    required String title,
    required String text,
    required Function(XFile) onImagePicked,
  }) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          backgroundColor: Colors.white,
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(text, style: const TextStyle(fontSize: 15)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("OK"),
            )
          ],
        );
      },
    );

    final img = await openCamera();
    if (img != null) onImagePicked(img);
  }

  Widget buildPersonalInfo() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Informations personnelles",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          input(firstNameCtrl, "Prénom", Icons.person_outline),
          const SizedBox(height: 16),

          input(lastNameCtrl, "Nom", Icons.person),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(14)),
            child: TextField(
              controller: birthDateCtrl,
              readOnly: true,
              decoration: inputDecoration("Date de naissance", Icons.cake),
              onTap: pickBirthDate,
            ),
          ),
          const SizedBox(height: 16),

          GestureDetector(
            onTap: showCountrySelector,
            child: AbsorbPointer(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: birthCountryCtrl,
                  decoration: inputDecoration("Pays de naissance", Icons.flag),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => setState(() => currentStep = 2),
              child: const Text("Suivant",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDate: DateTime(1995),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3A7FEA),
              onPrimary: Colors.white,
              surface: Color(0xFFEAF2FF),
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      birthDateCtrl.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  void showCountrySelector() {
    if (loadingCountries) return;

    TextEditingController searchCtrl = TextEditingController();
    List<String> filtered = List.from(countries);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Container(
              height: MediaQuery.of(sheetContext).size.height * 0.70,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: "Rechercher un pays...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setModalState(() {
                        filtered = countries
                            .where((c) => c.toLowerCase().contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        return ListTile(
                          title: Text(filtered[i]),
                          onTap: () {
                            birthCountryCtrl.text = filtered[i];
                            Navigator.of(modalContext).pop();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showDocumentTypeSelector() {
    final docs = {
      "passport": "Passeport",
      "id_card": "Carte d'identité",
      "driver_license": "Permis de conduire",
    };

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: docs.entries.map((e) {
              return ListTile(
                title: Text(e.value),
                onTap: () {
                  setState(() => selectedDocType = e.key);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget buildDocumentStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Documents d'identité",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          GestureDetector(
            onTap: showDocumentTypeSelector,
            child: AbsorbPointer(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  decoration: inputDecoration(
                    selectedDocType == null
                        ? "Type de document"
                        : {
                      "passport": "Passeport",
                      "id_card": "Carte d'identité",
                      "driver_license": "Permis de conduire",
                    }[selectedDocType]!,
                    Icons.badge,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 25),

          buildPhotoTile(
            label: "Photo du document",
            done: documentDone,
            onTap: () => instructionThenCamera(
              title: "Photo du document",
              text: "Place le document sur une surface plane avec bon éclairage.",
              onImagePicked: (img) {
                pickedDocument = img;
                setState(() => documentDone = true);
              },
            ),
          ),
          const SizedBox(height: 16),

          buildPhotoTile(
            label: "Selfie",
            done: selfieDone,
            onTap: () => instructionThenCamera(
              title: "Selfie",
              text: "Assure-toi que ton visage soit bien visible.",
              onImagePicked: (img) {
                pickedSelfie = img;
                setState(() => selfieDone = true);
              },
            ),
          ),
          const SizedBox(height: 16),

          buildPhotoTile(
            label: "Selfie + document",
            done: selfieDocDone,
            onTap: () => instructionThenCamera(
              title: "Selfie + Document",
              text: "Tiens ton document lisiblement à côté de ton visage.",
              onImagePicked: (img) {
                pickedSelfieWithDoc = img;
                setState(() => selfieDocDone = true);
              },
            ),
          ),

          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => currentStep = 1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Précédent",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await instructionThenCamera(
                      title: "Envoyé !",
                      text: "Votre vérification est en cours de traitement.",
                      onImagePicked: (_) {},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Soumettre",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF3A7FEA)),
      filled: true,
      fillColor: const Color(0xFFEAF2FF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF3A7FEA), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    );
  }

  Widget input(TextEditingController ctrl, String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        controller: ctrl,
        decoration: inputDecoration(label, icon),
      ),
    );
  }


  Widget buildPhotoTile({
    required String label,
    required bool done,
    required VoidCallback onTap,
  }) {
    return ListTile(
      tileColor: const Color(0xFFEAF2FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      leading: Icon(
        done ? Icons.check_circle : Icons.camera_alt,
        size: 30,
        color: done ? Colors.green : Colors.blueAccent,
      ),
      title: Text(label),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDarkMode ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: widget.isDarkMode ? Colors.white : Colors.black),
          onPressed: () {
            if (currentStep == 2) {
              setState(() => currentStep = 1);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text("Vérification d'identité",
            style: TextStyle(fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(
            color: widget.isDarkMode ? Colors.white : Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: currentStep == 1
            ? buildPersonalInfo()
            : currentStep == 2
            ? buildDocumentStep()
            : const SizedBox(),
      ),
    );
  }
}
