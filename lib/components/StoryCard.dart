import 'dart:async';
import 'package:flutter/material.dart';
import 'package:storyai/models/StoryModel.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:storyai/theme/pallete.dart';

class StoryCard extends StatefulWidget {
  final StoryModel story;
  StoryCard({required this.story});

  @override
  _StoryCardState createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration();
  Duration _position = Duration();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        _duration = duration;
      });
    });

    // Start the timer to update the position every second
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _audioPlayer.getCurrentPosition().then((Duration? position) {
        setState(() {
          _position = position ?? Duration.zero;
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    _audioPlayer.release();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      // Adjust the radius as needed
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        padding: EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: 550, // Set a fixed height for the card
        ),
        decoration: BoxDecoration(
            border: Border.all(
              color: Pallete.brown, // Specify the color of the border
              width: 2, // Specify the thickness of the border
            ),
            borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                widget.story.title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  widget.story.story,
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            SizedBox(height: 10),
            Wrap(
              children: widget.story.genres
                  .map(
                    (genre) => Chip(label: Text(genre)),
                  )
                  .toList(),
            ),
            SizedBox(height: 10),
            Text(
              "Posted by: " + widget.story.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 10),
            if (widget.story.audioUrl != null)
              Column(
                children: [
                  Center(
                    child: IconButton(
                      iconSize: 50,
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: () {
                        if (_isPlaying) {
                          _audioPlayer.pause();
                        } else {
                          _audioPlayer.play(UrlSource(widget.story.audioUrl!));
                        }
                      },
                    ),
                  ),
                  Slider(
                    value: _position.inSeconds.toDouble(),
                    onChanged: (double value) {
                      setState(() {
                        _audioPlayer.seek(Duration(seconds: value.toInt()));
                      });
                    },
                    min: 0,
                    max: _duration.inSeconds.toDouble(),
                    activeColor: Pallete.brown, // Set the color of the slider
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
