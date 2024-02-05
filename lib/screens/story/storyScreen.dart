import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({Key? key}) : super(key: key);

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final FlutterTts flutterTts = FlutterTts();
  List<String> stories = [
    // Add your stories here
    "Once upon a time...",
    "In the heart of an ancient forest, Emily and Jake stumbled upon a hidden realm, guided by ethereal butterflies.",
    // Add more stories as needed
  ];

  int currentStoryIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize TTS
    flutterTts.setLanguage("en-US");
    flutterTts.setPitch(1.0);
    flutterTts.setSpeechRate(0.5);
    // Speak the initial story
    speakStory(stories[currentStoryIndex]);
  }

  Future<void> speakStory(String story) async {
    await flutterTts.speak(story);
  }

  void changeStory(bool swipeUp) {
    setState(() {
      // Change the story index based on the swipe direction
      currentStoryIndex = swipeUp
          ? (currentStoryIndex + 1) % stories.length
          : (currentStoryIndex - 1 + stories.length) % stories.length;
      // Stop the TTS before speaking the new story
      flutterTts.stop();
      // Speak the new story
      speakStory(stories[currentStoryIndex]);
    });
  }

  @override
  void dispose() {
    // Stop TTS when the widget is disposed
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          // Determine the direction of the swipe
          bool swipeUp = details.primaryVelocity! < 0;
          // Change the story when swiped (up or down)
          changeStory(swipeUp);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: Column(
              children: [
                Container(
                  height: 500,
                  child: Center(
                    child: AnimatedTextKit(
                      key: ValueKey(currentStoryIndex), // Add a key for updates
                      animatedTexts: [
                        TypewriterAnimatedText(
                          stories[currentStoryIndex],
                          textStyle: const TextStyle(
                            fontSize: 24.0,
                            fontFamily: 'serif',
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                          textAlign: TextAlign.center,
                          speed: const Duration(
                              milliseconds: 50), // Adjust the speed as needed
                        ),
                      ],
                      totalRepeatCount: 1,
                      pause: const Duration(milliseconds: 1000),
                      displayFullTextOnTap: true,
                      stopPauseOnTap: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
