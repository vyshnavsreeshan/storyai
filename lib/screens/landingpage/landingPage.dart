import 'package:storyai/screens/userAgreementAndPrivacyPolicy/privacyPolicy.dart';
import 'package:storyai/screens/userAgreementAndPrivacyPolicy/userAgreement.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/gestures.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class LandingPage extends StatelessWidget {
  LandingPage({super.key});
  late BuildContext _context;
  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
        body: Stack(
      fit: StackFit.expand,
      children: [bodyGif(), quotes(), signInButton(), userAgreementText()],
    ));
  }

  Map<String, String> getRandomQuote() {
    List<Map<String, String>> quotes = [
      {
        "quote": "You're never alone when you're reading a book.",
        "author": "-Susan Wiggs"
      },
      {
        "quote": "If you don’t like to read, you haven’t found the right book.",
        "author": "-J.K. Rowling"
      },
      {
        "quote": "Books are a uniquely portable magic.",
        "author": "-Stephen King"
      },
      {
        "quote": "Books were my pass to personal freedom",
        "author": "-Oprah Winfrey"
      },
      {"quote": "We read to know we are not alone.", "author": "-C.S. Lewis"},
      {
        "quote": "Books may well be the only true magic.",
        "author": "-Alice Hoffman"
      },
      {"quote": "Books fall open, you fall in", "author": "-David McCord"},
      {
        "quote": "In a good book the best is between the lines.",
        "author": "-Swedish Proverb"
      },
      {
        "quote": "Read A Thousand Books And Your Words Will Flow Like A River",
        "author": "-Virginia Woolf"
      }
    ];
    Random random = Random();
    int index = random.nextInt(quotes.length);
    return quotes[index];
  }

  bodyGif() {
    return Image.asset(
      'assets/landingPage.gif',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }

  quotes() {
    final randomQuote = getRandomQuote();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  randomQuote['quote'] ?? '',
                  textStyle: const TextStyle(
                    fontSize: 24.0,
                    fontFamily: 'serif',
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                  textAlign: TextAlign.center,
                  speed: const Duration(milliseconds: 100),
                ),
              ],
              totalRepeatCount: 1,
              pause: const Duration(milliseconds: 1000),
              displayFullTextOnTap: true,
              stopPauseOnTap: true,
            ),
            const SizedBox(height: 16.0),
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  randomQuote['author'] ?? '',
                  textStyle: const TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'serif',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  speed: const Duration(milliseconds: 100),
                ),
              ],
              totalRepeatCount: 1,
              pause: const Duration(milliseconds: 1000),
              displayFullTextOnTap: true,
              stopPauseOnTap: true,
            ),
          ],
        ),
      ),
    );
  }

  signInButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 75.0),
          child: InkWell(
            onTap: () {
              signInWithGoogle();
              print("sign in button pressed");
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 9.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.white.withOpacity(0.01),
                  border: Border.all(
                      color: const Color.fromRGBO(255, 246, 217, 0.8),
                      width: 1.0)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset(
                    'assets/google.png', // replace with your Google logo asset
                    height: 24.0,
                    width: 24.0,
                  ),
                  const SizedBox(width: 20.0),
                  const Text(
                    'Sign in with Google',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  userAgreementText() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 35.0),
          child: Text.rich(
            TextSpan(
              style: const TextStyle(
                  fontSize: 12.0, color: Color.fromARGB(255, 214, 194, 121)),
              text: 'By continuing, you agree to our ',
              children: [
                TextSpan(
                    text: 'User Agreement',
                    style: const TextStyle(
                      fontSize: 10.0,
                      color: Colors.red,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => navigateToUserAgreementScreen(_context)),
                const TextSpan(
                    text: ' and acknowledge that you understand the '),
                TextSpan(
                    text: 'Privacy Policy',
                    style: const TextStyle(
                      fontSize: 10.0,
                      color: Colors.red,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => navigateToPrivacyPolicyScreen(_context)),
                const TextSpan(text: '.'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }

  void signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // Handle the case where the user canceled the sign-in process
        print("Google sign-in canceled by the user");
        return;
      }

      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      User? user = userCredential.user;

      if (user == null) {
        // Handle the case where the user information is missing
        print("Firebase user information is missing");
        return;
      }

      // Continue with storing user information in Firestore or other actions
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      DocumentReference userDoc = users.doc(user.uid);
      DocumentSnapshot snapshot = await userDoc.get();

      if (!snapshot.exists) {
        userDoc.set({
          'userId': user.uid,
          'userName': user.displayName,
          'email': user.email,
          'photoUrl': user.photoURL,
        });
        Navigator.pushReplacementNamed(_context, '/onboarding');
      } else {
        Navigator.pushReplacementNamed(_context, '/home');
      }
    } on PlatformException catch (e) {
      print("Error during Google sign-in: $e");

      // You can customize the error handling based on the error code
      if (e.code == 'sign_in_canceled') {
        // The user canceled the sign-in process
        print("User canceled the sign-in process");
      } else if (e.code == 'network_error') {
        // Handle network error
        print("Network error during sign-in");
      } else {
        // Handle other error codes
        print("Unexpected error during sign-in: ${e.code}");
      }

      // Example: Show a snackbar with the error message
      ScaffoldMessenger.of(_context).showSnackBar(
        SnackBar(
          content: Text("Error during sign-in. Please try again."),
        ),
      );
    } catch (e) {
      // Catch any unexpected errors
      print("Unexpected error during sign-in: $e");
    }
  }

  navigateToUserAgreementScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserAgreementScreen()),
    );
  }

  navigateToPrivacyPolicyScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
    );
  }
}
