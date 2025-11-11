import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../home/home_screen.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/img/onboarding1.jpeg",
      "text": "Trouvez un voyageur qui part à vôtre destination et expédiez votre colis en un clic.",
    },
    {
      "image": "assets/img/onboarding2.jpeg",
      "text": "Monétisez l'espace disponible dans vos bagages. Faites de vos voyages une source de revenus sans effort supplémentaire",
    },
    {
      "image": "assets/img/onboarding3.jpeg",
      "text": "Contrôlez le prix et le volume. Publiez une annonce de bagage disponible, acceptez l'offre qui vous convient, sans contrainte",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              itemCount: onboardingData.length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      onboardingData[index]["image"]!,
                      width: 250,
                      height: 250,
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        onboardingData[index]["text"]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              onboardingData.length,
                  (index) => buildDot(index, context),
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: currentPage == onboardingData.length - 1
                ? SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Démarrer",
                  style: TextStyle(fontSize: 16,
                    color: Colors.white,),
                ),
              ),
            )
                : SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Text("Suivant"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: currentPage == index ? 12 : 8,
      height: currentPage == index ? 12 : 8,
      decoration: BoxDecoration(
        color: currentPage == index ? AppColors.primary : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}
