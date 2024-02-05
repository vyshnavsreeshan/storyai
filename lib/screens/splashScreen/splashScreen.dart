import 'dart:async';
import 'package:storyai/main.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(
        const Duration(seconds: 1),
        () => Navigator.pushReplacement(
            context,
            PageTransition(
                child: const DefaultScreen(), type: PageTransitionType.fade)));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: RichText(
          text: const TextSpan(
              text: 'Book',
              style: TextStyle(
                fontFamily: 'serif',
                color: Colors.blue,
                fontSize: 30,
                fontWeight: FontWeight.w400,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: 'Buddies',
                  style: TextStyle(
                    fontFamily: 'serif',
                    color: Colors.blue,
                    fontSize: 34,
                    fontWeight: FontWeight.w400,
                  ),
                )
              ]),
        ),
      ),
    );
  }
}
