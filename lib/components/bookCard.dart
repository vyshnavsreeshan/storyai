import 'package:storyai/models/books.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:storyai/theme/pallete.dart';
import '../screens/messageScreen/ChatRoomScreen.dart';
import '../screens/profileScreen/Profile.dart';
import '../screens/profileScreen/feedProfile.dart';

class BookCard extends StatefulWidget {
  final Books book;
  final String bookOwnerId;
  const BookCard({required this.book, required this.bookOwnerId});

  @override
  _BookCardState createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  String? placeName;

  @override
  void initState() {
    super.initState();
    _getPlaceName();
  }

  Future<void> _getPlaceName() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        widget.book.bookLocation.latitude,
        widget.book.bookLocation.longitude,
      );
      if (placemarks.isNotEmpty) {
        final placemark = placemarks[0];
        setState(() {
          placeName = '${placemark.subLocality} ${placemark.locality}';
        });
      }
    } catch (e) {
      print('Error retrieving place name: $e');
    }
  }

  void _navigateToChatRoom() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid;
    final otherUserId = widget.bookOwnerId;
    if (currentUserId == otherUserId) {
      return;
    }
    // Check if the chat room already exists
    final chatRoomSnapshot = await FirebaseFirestore.instance
        .collection('chatRooms')
        .where('users.$currentUserId', isEqualTo: true)
        .where('users.$otherUserId', isEqualTo: true)
        .limit(1)
        .get();

    if (chatRoomSnapshot.docs.isNotEmpty) {
      // Chat room already exists, navigate to the existing chat room
      final chatRoomId = chatRoomSnapshot.docs.first.id;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatRoomScreen(chatRoomId: chatRoomId),
        ),
      );
    } else {
      // Chat room doesn't exist, create a new chat room
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();
      final otherUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(otherUserId)
          .get();

      final currentUserData = currentUserDoc.data() as Map<String, dynamic>;
      final otherUserData = otherUserDoc.data() as Map<String, dynamic>;

      final chatRoomData = {
        'users': {
          currentUserId: true,
          otherUserId: true,
        },
        'userNames': {
          currentUserId: currentUserData['userName'],
          otherUserId: otherUserData['userName'],
        },
        'avatarUrls': {
          currentUserId: currentUserData['photoUrl'],
          otherUserId: otherUserData['photoUrl'],
        },
        'timestamp': FieldValue.serverTimestamp()
      };

      final newChatRoomRef =
          FirebaseFirestore.instance.collection('chatRooms').doc();
      final newChatRoomId = newChatRoomRef.id;

      await newChatRoomRef.set(chatRoomData);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatRoomScreen(chatRoomId: newChatRoomId),
        ),
      );
    }
  }

  Future<void> launchGoogleMaps(double latitude, double longitude) async {
    await MapsLauncher.launchCoordinates(latitude, longitude);
  }

  @override
  Widget build(BuildContext context) {
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    return ClipRRect(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            border: Border.all(
              color: Pallete.brown, // Specify the color of the border
              width: 2, // Specify the thickness of the border
            ),
            borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    if (widget.book.userId == currentUserId) {
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
                          builder: (context) =>
                              FeedProfile(userId: widget.book.userId),
                        ),
                      );
                    }
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(widget.book.avatarUrl),
                      ),
                      SizedBox(width: 10),
                      Text(
                        widget.book.userName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Pallete.brown),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Title: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Pallete.brown),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        widget.book.title,
                        style: TextStyle(fontSize: 18, color: Pallete.brown),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Author: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Pallete.brown),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        widget.book.author,
                        style: TextStyle(fontSize: 18, color: Pallete.brown),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    if (placeName != null)
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Location: ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Pallete.brown),
                        ),
                      ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '$placeName',
                        style: TextStyle(fontSize: 18, color: Pallete.brown),
                        softWrap: true,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Status: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Pallete.brown),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        widget.book.isAvailable ? 'Available' : 'Unavailable',
                        style: TextStyle(fontSize: 18, color: Pallete.brown),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                AspectRatio(
                  aspectRatio: 4 / 5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.book.bookUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 10,
              right: 60,
              child: InkWell(
                onTap: () {
                  launchGoogleMaps(
                    widget.book.bookLocation.latitude,
                    widget.book.bookLocation.longitude,
                  );
                },
                child: widget.book.isAvailable
                    ? Icon(
                        Icons.pin_drop_rounded,
                        size: 32,
                        color: Pallete.brown,
                      )
                    : null,
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: InkWell(
                onTap: _navigateToChatRoom,
                child: Icon(
                  Icons.mail_rounded,
                  size: 32,
                  color: Pallete.brown,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
