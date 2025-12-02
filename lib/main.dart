import 'package:flutter/material.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
void main() async {

WidgetsFlutterBinding.ensureInitialized();
if(kIsWeb) {
await Firebase.initializeApp(options: FirebaseOptions(apiKey: "AIzaSyDF-k5CnsTjVZKyc6VrCzIGJsrCjFe0T2Y",
                                                      authDomain: "send-packet.firebaseapp.com",
                                                      projectId: "send-packet",
                                                      storageBucket: "send-packet.firebasestorage.app",
                                                      messagingSenderId: "209130586578",
                                                      appId: "1:209130586578:web:6e24825b233cc4eef6080b" ));

}
else { await Firebase.initializeApp();}
      runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Send Packet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF3A7FEA),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3A7FEA),
      body: Center(
        child: Image.asset(
          'assets/img/logosp.png',
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
