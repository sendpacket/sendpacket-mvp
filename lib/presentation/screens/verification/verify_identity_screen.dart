import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sendpacket/presentation/screens/settings/settings_screen.dart';
import '../../screens/auth/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';



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
  String? ageError;

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
      final user = FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      if (user == null) {
        showMustLoginPopup();
      } else {
        showWelcomePopup();
      }
    });
  }


  Future<XFile?> openCamera() async {
    final picker = ImagePicker();
    return picker.pickImage(source: ImageSource.camera);
  }

  void showWelcomePopup() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, _, _) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final scale = Tween<double>(begin: 0.92, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        );

        return Transform.scale(
          scale: scale.value,
          child: Opacity(
            opacity: animation.value,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.82,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha:0.07)
                            : Colors.white.withValues(alpha:0.85),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha:0.15)
                              : Colors.black.withValues(alpha:0.05),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user,
                            size: 58,
                            color: Colors.blueAccent.shade200,
                          ),
                          const SizedBox(height: 18),

                          Text(
                            "Vérification d'identité",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 14),

                          Text(
                            "Vos données ne seront jamais partagées.\n\n"
                                "La vérification vous permet d'obtenir un badge qui montre aux utilisateurs que votre compte est authentique.",
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.45,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 26),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                                setState(() => currentStep = 1);
                              },
                              child: const Text(
                                "Commencer",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showMustLoginPopup() {
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
                    color: Colors.black.withValues(alpha:0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline,
                      size: 60, color: Colors.blueAccent),
                  const SizedBox(height: 16),
                  const Text(
                    "Connexion requise",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Vous devez être connecté pour vérifier votre identité.",
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
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) =>
                              const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Se connecter",
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

  Widget appleInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha:0.4)
                : Colors.grey.withValues(alpha:0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(
            color: isDark ? Colors.white54 : Colors.black45,
          ),
          prefixIcon: Icon(
            icon,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        ),
      ),
    );
  }

  Widget buildPersonalInfo() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Informations personnelles",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),

          const SizedBox(height: 20),

          appleInputField(
            controller: firstNameCtrl,
            label: "Prénom",
            icon: Icons.person_outline,
          ),

          appleInputField(
            controller: lastNameCtrl,
            label: "Nom",
            icon: Icons.person,
          ),

          appleInputField(
            controller: birthDateCtrl,
            label: "Date de naissance",
            icon: Icons.cake,
            readOnly: true,
            onTap: pickBirthDate,
          ),

          appleInputField(
            controller: birthCountryCtrl,
            label: "Pays de naissance",
            icon: Icons.flag,
            readOnly: true,
            onTap: showCountryPickerBottomSheet,
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => setState(() => currentStep = 2),
              child: const Text(
                "Suivant",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showCountryPickerBottomSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showCountryPicker(
      context: context,
      showPhoneCode: false,

      countryListTheme: CountryListThemeData(
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        inputDecoration: InputDecoration(
          filled: true,
          fillColor: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
          hintText: "Rechercher un pays",
          hintStyle: TextStyle(
              color: isDark ? Colors.white54 : Colors.black54
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.blueAccent,
              width: 2,
            ),
          ),
        ),

        textStyle: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white : Colors.black87,
        ),

        bottomSheetHeight: MediaQuery.of(context).size.height * 0.75,
      ),

      onSelect: (Country country) {
        birthCountryCtrl.text = country.name;
      },
    );
  }

  Future<void> pickBirthDate() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        DateTime tempDate = DateTime(1995);

        return Container(
          padding: const EdgeInsets.only(top: 12, bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Sélectionner votre date de naissance",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  maximumDate: DateTime.now(),
                  minimumDate: DateTime(1900),
                  initialDateTime: DateTime(1995),
                  onDateTimeChanged: (DateTime newDate) {
                    tempDate = newDate;
                  },
                ),
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final today = DateTime.now();
                      int age = today.year - tempDate.year;

                      if (today.month < tempDate.month ||
                          (today.month == tempDate.month && today.day < tempDate.day)) {
                        age--;
                      }

                      if (age < 18) {
                        setState(() {
                          ageError = "L'âge minimal requis est 18 ans.";
                          birthDateCtrl.text = ""; // On efface la date invalide
                        });
                        Navigator.pop(context);
                        return;
                      }

                      setState(() {
                        ageError = null;
                        birthDateCtrl.text =
                        "${tempDate.day}/${tempDate.month}/${tempDate.year}";
                      });

                      Navigator.pop(context);
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Valider",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget appleTile({
    required String label,
    required IconData icon,
    required bool done,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha:0.5)
                : Colors.grey.withValues(alpha:0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withValues(alpha:0.20),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blueAccent),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: done
            ? const Icon(Icons.check_circle, color: Colors.green, size: 26)
            : Icon(Icons.arrow_forward_ios,
            size: 16,
            color: isDark ? Colors.white54 : Colors.black38),
      ),
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

          appleSelectField(
            text: selectedDocType == null
                ? "Type de document"
                : {
              "passport": "Passeport",
              "id_card": "Carte d'identité",
              "driver_license": "Permis de conduire",
            }[selectedDocType]!,
            icon: Icons.badge,
            onTap: showDocumentTypeSelector,
            isFilled: selectedDocType != null,
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
                    subtitle: "Importez une photo claire de votre pièce d’identité.",
                    icon: Icons.badge,
                    dos: const ["Assurez vous que le document soit lisible", "Assurez vous que le document soit complet", "Assurez vous d'avoir une bonne lumière"],
                    donts: const ["Assurez vous que le document n'ait pas de reflet", "Assurez vous que le document n'ait pas de filtre", "Assurez vous que le document ne soit pas de flou"],
                    onImagePicked: (img) {
                      setState(() {
                        pickedDocument = img;
                        documentDone = true;
                      });
                    },
                    sampleImage: "assets/img/examplePics.png",
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
                    subtitle: "Importez un selfie bien éclairé. Veuillez suivre nos recommendations pour faciliter votre approbation",
                    icon: Icons.person,
                    dos: const ["Assurez vous que votre visage soit visible", "Assurez vous être dans un endroit avec une bonne lumière"],
                    donts: const ["Assurez vous que votre selfie n'ait pas de filtres et soit réelle", "Veuillez s'il vous plait ne pas mettre de lunettes"],
                    onImagePicked: (img) {
                      setState(() {
                        pickedSelfie = img;
                        selfieDone = true;
                      });
                    },
                    sampleImage: "assets/img/examplePicsSelfie.png",
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
                    title: "Selfie + document",
                    subtitle: "Photo de vous tenant votre document, soit par selfie ou comme illustré dans l'exemple ci-dessous.",
                    icon: Icons.assignment_ind,
                    dos: const ["Assurez vous que votre visage et votre document sont visibles", "Assurez vous que le texte de votre document soit lisible"],
                    donts: const ["Assurez vous de ne pas mettre de photo de floue", "Assurez vous de ne rien cacher"],
                    onImagePicked: (img) {
                      setState(() {
                        pickedSelfieWithDoc = img;
                        selfieDocDone = true;
                      });
                    },
                    sampleImage: "assets/img/examplePicsSelDoc.png",
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
                  onPressed: submitVerification,
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

  Widget appleSelectField({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    bool isFilled = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha:0.5)
                  : Colors.grey.withValues(alpha:0.15),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueAccent, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Icon(
              isFilled ? Icons.check_circle : Icons.arrow_forward_ios,
              size: isFilled ? 24 : 16,
              color: isFilled
                  ? Colors.green
                  : (isDark ? Colors.white54 : Colors.black38),
            )
          ],
        ),
      ),
    );
  }

  void showDocumentTypeSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final docs = {
      "passport": "Passeport",
      "id_card": "Carte d'identité",
      "driver_license": "Permis de conduire",
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1,),
                blurRadius: 25,
                spreadRadius: 5,
                offset: const Offset(0, -3),
              ),
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Petite barre iOS
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Sélectionnez un document",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),

              const SizedBox(height: 12),

              ...docs.entries.map((e) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2C2C2E)
                        : const Color(0xFFF7F7F8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withValues(alpha:0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.credit_card,
                        color: isDark ? Colors.blueAccent.shade200 : Colors.blueAccent,
                      ),
                    ),
                    title: Text(
                      e.value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                    onTap: () {
                      setState(() => selectedDocType = e.key);
                      Navigator.pop(context);
                    },
                  ),
                );
              }),

              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  void showMissingFieldsPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final dark = Theme.of(context).brightness == Brightness.dark;

        return Center(
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  width: MediaQuery.of(dialogContext).size.width * 0.85,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: dark
                        ? Colors.black.withValues(alpha:0.55)
                        : Colors.white.withValues(alpha:0.85),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: dark
                            ? Colors.black.withValues(alpha:0.6)
                            : Colors.black.withValues(alpha:0.15),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60,
                        color: dark ? Colors.red[300] : Colors.redAccent,
                      ),

                      const SizedBox(height: 16),

                      Text(
                        "Champs manquants",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: dark ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        "Veuillez compléter tous les champs avant de continuer.",
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.4,
                          color: dark ? Colors.white70 : Colors.black54,
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
                          },
                          child: const Text(
                            "OK",
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
            ),
          ),
        );
      },
    );
  }

  Future<void> submitVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final uid = user.uid;

      if (firstNameCtrl.text.isEmpty ||
          lastNameCtrl.text.isEmpty ||
          birthDateCtrl.text.isEmpty ||
          birthCountryCtrl.text.isEmpty ||
          selectedDocType == null ||
          pickedDocument == null ||
          pickedSelfie == null ||
          pickedSelfieWithDoc == null) {
        showMissingFieldsPopup();
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
      final selfieDocUrl = await uploadImage(pickedSelfieWithDoc!, "selfie_document");

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

      if (!mounted) return;

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
                      color: Colors.black.withValues(alpha:0.25),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified, size: 60, color: Colors.blueAccent),
                    const SizedBox(height: 16),

                    const Text(
                      "Demande envoyée !",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "Votre vérification d'identité est maintenant en cours de traitement.",
                      style:
                      TextStyle(fontSize: 15, color: Colors.black54, height: 1.4),
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
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => SettingsScreen(isDarkMode: widget.isDarkMode),
                            ),
                          );
                        },
                        child: const Text(
                          "OK",
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

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }
  }

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF3A7FEA)),
      filled: true,
      fillColor: const Color(0xFFEAF2FF),
      border:
      OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha:0.5)
                : Colors.grey.withValues(alpha:0.15),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withValues(alpha:0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            done ? Icons.check_circle : Icons.camera_alt,
            color: done ? Colors.green : Colors.blueAccent,
            size: 26,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDark ? Colors.white54 : Colors.black38,
        ),
      ),
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
        iconTheme:
        IconThemeData(color: widget.isDarkMode ? Colors.white : Colors.black),
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

class KycInstructionPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> dos;
  final List<String> donts;
  final ValueChanged<XFile> onImagePicked;
  final String sampleImage;


  const KycInstructionPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.dos,
    required this.donts,
    required this.onImagePicked,
    required this.sampleImage,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Apple Style
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.blueAccent.withValues(alpha:0.25)
                            : const Color(0xFFE3F0FF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(widget.icon,
                          size: 32, color: Colors.blueAccent),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.4,
                          color:
                          isDark ? Colors.white70 : Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                "Recommandations pour une bonne photo",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 8),

              ...widget.dos.map((e) => Padding(
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
                                : Colors.grey.shade800),
                      ),
                    ),
                  ],
                ),
              )),

              const SizedBox(height: 18),

              Text(
                "À éviter",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 8),

              ...widget.donts.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.cancel,
                        size: 18, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e,
                        style: TextStyle(
                            fontSize: 14,
                            height: 1.35,
                            color: isDark
                                ? Colors.white70
                                : Colors.grey.shade800),
                      ),
                    ),
                  ],
                ),
              )),

              const SizedBox(height: 24),

              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    widget.sampleImage,
                    width: 320,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 24),


              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: picking ? null : _pickFromGallery,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: picking
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white)),
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
