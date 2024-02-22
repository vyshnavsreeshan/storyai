import 'package:flutter/material.dart';
import 'package:storyai/models/StoryModel.dart';

class StoryCard extends StatelessWidget {
  final StoryModel story;
  StoryCard({required this.story});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              story.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              story.story,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Wrap(
              children: story.genres
                  .map(
                    (genre) => Chip(label: Text(genre)),
                  )
                  .toList(),
            ),
            if (story.audioUrl != null) // Check if audioUrl is not null
              Text(
                'Audio URL: ${story.audioUrl}',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }
}
