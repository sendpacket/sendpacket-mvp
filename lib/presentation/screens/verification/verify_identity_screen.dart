import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) showWelcomePopup();
    });
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
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      height: 1.4,
                    ),
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
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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

  // ----------------------------------------------------------------------
  // ➤ Page Informations personnelles
  // ----------------------------------------------------------------------
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
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: birthDateCtrl,
              readOnly: true,
              decoration: inputDecoration("Date de naissance", Icons.cake),
              onTap: pickBirthDate,
            ),
          ),
          const SizedBox(height: 16),

          GestureDetector(
            onTap: showCountryPickerBottomSheet,
            child: AbsorbPointer(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: birthCountryCtrl,
                  decoration: inputDecoration(
                      "Pays de naissance", Icons.flag),
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

  void showCountryPickerBottomSheet() {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      countryListTheme: CountryListThemeData(
        borderRadius: BorderRadius.circular(20),
        inputDecoration: const InputDecoration(
          hintText: 'Rechercher un pays',
          prefixIcon: Icon(Icons.search),
        ),
      ),
      onSelect: (Country c) {
        birthCountryCtrl.text = c.name;
      },
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

  // ----------------------------------------------------------------------
  // ➤ Page Documents
  // ----------------------------------------------------------------------
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => KycInstructionPage(
                    title: "Photo du document",
                    subtitle:
                    "Importez une photo claire de votre pièce d’identité.",
                    icon: Icons.badge,
                    dos: const [
                      "Texte lisible",
                      "Document complet visible",
                      "Bonne luminosité",
                    ],
                    donts: const [
                      "Aucun filtre",
                      "Pas de zone floue",
                      "Pas de reflet",
                    ],
                    onImagePicked: (img) {
                      setState(() {
                        pickedDocument = img;
                        documentDone = true;
                      });
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          buildPhotoTile(
            label: "Selfie",
            done: selfieDone,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => KycInstructionPage(
                    title: "Selfie",
                    subtitle: "Importez un selfie bien éclairé.",
                    icon: Icons.person,
                    dos: const [
                      "Visage visible",
                      "Regard face à la caméra",
                      "Bonne lumière",
                    ],
                    donts: const [
                      "Pas de lunettes de soleil",
                      "Pas de chapeau",
                      "Pas de filtres",
                    ],
                    onImagePicked: (img) {
                      setState(() {
                        pickedSelfie = img;
                        selfieDone = true;
                      });
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          buildPhotoTile(
            label: "Selfie + document",
            done: selfieDocDone,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => KycInstructionPage(
                    title: "Selfie avec document",
                    subtitle:
                    "Prenez-vous en tenant votre document près du visage.",
                    icon: Icons.assignment_ind,
                    dos: const [
                      "Visage et document visibles",
                      "Texte lisible",
                      "Bonne lumière",
                    ],
                    donts: const [
                      "Ne pas cacher le visage",
                      "Ne pas cacher le document",
                      "Pas de flou",
                    ],
                    onImagePicked: (img) {
                      setState(() {
                        pickedSelfieWithDoc = img;
                        selfieDocDone = true;
                      });
                    },
                  ),
                ),
              );
            },
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Précédent",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton(
                  onPressed: submitVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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

  // ----------------------------------------------------------------------
  // ➤ Sélecteur du type de document
  // ----------------------------------------------------------------------
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

  // ----------------------------------------------------------------------
  // ➤ SOUMISSION : Upload Storage + Firestore + UID du user Firebase
  // ----------------------------------------------------------------------
  Future<void> submitVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez vous connecter.")),
        );
        return;
      }

      final uid = user.uid;

      if (firstNameCtrl.text.isEmpty ||
          lastNameCtrl.text.isEmpty ||
          birthDateCtrl.text.isEmpty ||
          birthCountryCtrl.text.isEmpty ||
          selectedDocType == null ||
          pickedDocument == null ||
          pickedSelfie == null ||
          pickedSelfieWithDoc == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez compléter tous les champs")),
        );
        return;
      }

      final storage = FirebaseStorage.instance;

      Future<String> uploadImage(XFile file, String name) async {
        final ref = storage.ref("kyc/$uid/$name.jpg");
        await ref.putFile(File(file.path));
        return await ref.getDownloadURL();
      }

      final docUrl = await uploadImage(pickedDocument!, "document");
      final selfieUrl = await uploadImage(pickedSelfie!, "selfie");
      final selfieDocUrl =
      await uploadImage(pickedSelfieWithDoc!, "selfie_document");

      // 🔥 Enregistrement dans Firestore EXACTEMENT comme ton admin Next.js le lit
      await FirebaseFirestore.instance.collection("kycRequests").add({
        "uid": uid,
        "firstName": firstNameCtrl.text.trim(),
        "lastName": lastNameCtrl.text.trim(),
        "birthDate": birthDateCtrl.text.trim(),
        "birthCountry": birthCountryCtrl.text.trim(),
        "docType": selectedDocType,
        "documentURL": docUrl,
        "selfieURL": selfieUrl,
        "selfieDocumentURL": selfieDocUrl,
        "status": "pending",
        "submittedAt": FieldValue.serverTimestamp(),
      });

      await showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text("Envoyé !"),
            content: const Text("Votre vérification est en cours de traitement."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    }
  }

  // ----------------------------------------------------------------------
  // ➤ UI de base suivante
  // ----------------------------------------------------------------------
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
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF3A7FEA), width: 2),
      ),
      contentPadding:
      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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

  // ----------------------------------------------------------------------
  // ➤ Scaffold principal
  // ----------------------------------------------------------------------
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

/// ----------------------------------------------------------------------
/// 🔹 PAGE KYC INSTRUCTION — EXACTE AVEC PICK IMAGE DEPUIS GALLERIE
/// ----------------------------------------------------------------------
class KycInstructionPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> dos;
  final List<String> donts;
  final ValueChanged<XFile> onImagePicked;

  const KycInstructionPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.dos,
    required this.donts,
    required this.onImagePicked,
  });

  @override
  State<KycInstructionPage> createState() => _KycInstructionPageState();
}

class _KycInstructionPageState extends State<KycInstructionPage> {
  bool picking = false;

  Future<void> _pickFromGallery() async {
    if (picking) return;
    setState(() => picking = true);

    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);

    if (!mounted) return;

    setState(() => picking = false);

    if (img != null) {
      widget.onImagePicked(img);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white10 : const Color(0xFFF3F4F6)),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.blueAccent.withOpacity(0.25)
                            : const Color(0xFFE3F0FF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        size: 32,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.4,
                          color: isDark
                              ? Colors.white70
                              : Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                "À faire",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              ...widget.dos.map(
                    (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          size: 18, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.35,
                            color: isDark
                                ? Colors.white70
                                : Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Text(
                "À éviter",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              ...widget.donts.map(
                    (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.cancel, size: 18, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.35,
                            color: isDark
                                ? Colors.white70
                                : Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: picking ? null : _pickFromGallery,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: picking
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text(
                    "Choisir une photo",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
