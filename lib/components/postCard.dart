import 'package:storyai/screens/profileScreen/feedProfile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:storyai/theme/pallete.dart';
import '../models/posts.dart';
import '../screens/profileScreen/Profile.dart';

class PostCard extends StatelessWidget {
  final Post post;

  PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    return ClipRRect(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            border: Border.all(
              color: Pallete.brown, // Specify the color of the border
              width: 2, // Specify the thickness of the border
            ),
            borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  post.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to the profile screen for the user associated with the post
                if (post.userId == currentUserId) {
                  // Navigate to the Profile screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          Profile(), // Replace with your Profile screen
                    ),
                  );
                } else {
                  // Navigate to the FeedProfile screen for the user associated with the post
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FeedProfile(userId: post.userId),
                    ),
                  );
                }
              },
              child: Row(
                children: [
                  // CircleAvatar(
                  //   backgroundImage: NetworkImage(post.avatarUrl),
                  //   radius: 25,
                  // ),
                  SizedBox(height: 30),
                  Text(
                    post.userName,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Pallete.brown),
                  ),
                ],
              ),
            ),
            Text(
              post.caption,
              style: TextStyle(fontSize: 17, color: Pallete.brown),
            ),
          ],
        ),
      ),
    );
  }
}
