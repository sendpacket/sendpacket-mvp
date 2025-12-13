import 'package:flutter/material.dart';
import '../home/home_screen.dart';

class OnboardingStep {
  final String subTitle;
  final String mainTitle;
  final String description;

  OnboardingStep({
    required this.subTitle,
    required this.mainTitle,
    required this.description,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentStep = 0;

  final List<OnboardingStep> steps = [
    OnboardingStep(
      subTitle: "L'envoi de colis",
      mainTitle: "Autrement",
      description:
      "Trouvez un voyageur qui part à votre destination et expédiez votre colis en un clic.",
    ),
    OnboardingStep(
      subTitle: "Gagnez de l'argent",
      mainTitle: "Facilement",
      description:
      "Monétisez l'espace disponible dans vos bagages.\nFaites de vos voyages une source de revenus.",
    ),
    OnboardingStep(
      subTitle: "Flexibilité totale",
      mainTitle: "Sur mesure",
      description:
      "Contrôlez le prix et le volume.\nPubliez une annonce et acceptez l’offre qui vous convient.",
    ),
  ];

  void _next() {
    if (currentStep < steps.length - 1) {
      setState(() => currentStep++);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  void _previous() {
    if (currentStep > 0) {
      setState(() => currentStep--);
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (details.primaryVelocity! < 0) {
      _next();
    } else if (details.primaryVelocity! > 0) {
      _previous();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              "assets/img/backgroundSP.png",
              fit: BoxFit.cover,
            ),

            Container(
              color: const Color(0xFF08141F).withValues(alpha: 0.6),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.15),

                    const Text(
                      "SendPackage",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),

                    const Spacer(),

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            steps[currentStep].subTitle,
                            key: ValueKey('sub-$currentStep'),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            steps[currentStep].mainTitle,
                            key: ValueKey('main-$currentStep'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              steps[currentStep].description,
                              key: ValueKey('desc-$currentStep'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        steps.length,
                            (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: currentStep == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: currentStep == index
                                ? Colors.white
                                : Colors.white38,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _next,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF08141F),
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                currentStep == steps.length - 1
                                    ? "Commencer"
                                    : "Suivant",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}