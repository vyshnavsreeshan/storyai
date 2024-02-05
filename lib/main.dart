import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:storyai/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:storyai/screens/homeScreen/HomeScreen.dart';
import 'package:storyai/screens/landingpage/landingPage.dart';
import 'package:storyai/screens/onboarding/user_onboarding.dart';
import 'package:storyai/screens/splashScreen/splashScreen.dart';
import 'package:storyai/theme/pallete.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Pallete.appTheme,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
      },
      home: const DefaultScreen(),
    );
  }
}

class DefaultScreen extends StatelessWidget {
  const DefaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData) {
          // User is signed in, check if it's the first time
          User user = snapshot.data as User;
          CollectionReference users =
              FirebaseFirestore.instance.collection('users');
          DocumentReference userDoc = users.doc(user.uid);
          return FutureBuilder(
            future: userDoc.get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasData && !snapshot.data!.exists) {
                // User is signing in for the first time, navigate to onboarding screen
                return const OnboardingScreen();
              } else {
                // User has signed in before, navigate to the home screen
                return const HomeScreen();
              }
            },
          );
        } else {
          // User is not signed in, show the landing page
          return LandingPage();
        }
      },
    );
  }
}
