import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:storyai/theme/pallete.dart';

import 'ChatRoomScreen.dart';

class MessageScreen extends StatelessWidget {
  final String currentUserId;
  const MessageScreen({required this.currentUserId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6D9),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // Aligns the title to the center
          children: [
            Text(
              'Chats',
              style: TextStyle(
                color: Pallete.brown,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true, // Centers the title
        titleSpacing: 0, // Adjust spacing around the title if needed
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chatRooms')
            .where('users.$currentUserId', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final chatRooms = snapshot.data!.docs;

          if (chatRooms.isEmpty) {
            return Center(child: Text('No chat rooms available.'));
          }

          chatRooms.sort((a, b) {
            final aTimestamp = a['timestamp'] ?? 0;
            final bTimestamp = b['timestamp'] ?? 0;
            return bTimestamp.compareTo(aTimestamp);
          });

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index].data() as Map<String, dynamic>;
              final chatRoomId = chatRooms[index].id;
              final userNames = chatRoom['userNames'] as Map<String, dynamic>;

              final currentUser = FirebaseAuth.instance.currentUser;
              final currentUserId = currentUser?.uid;

              final otherUserId = userNames.keys.firstWhere(
                (userId) => userId != currentUserId,
                orElse: () => '',
              );
              // Swap currentUserId and otherUserId
              final displayUserId =
                  currentUserId == otherUserId ? currentUserId : otherUserId;
              final displayUserName = userNames[displayUserId];
              final displayUserAvatarUrl =
                  chatRoom['avatarUrls'][displayUserId];

              return Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(displayUserAvatarUrl),
                  ),
                  title: Text(displayUserName),
                  subtitle: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chatRooms')
                        .doc(chatRoomId)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .limit(1)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Text('No messages');
                      }

                      final lastMessage =
                          snapshot.data!.docs[0].data() as Map<String, dynamic>;
                      final messageText = lastMessage['content'];
                      final messageTime = lastMessage['timestamp'];

                      final formattedTime =
                          DateFormat.jm().format(messageTime.toDate());

                      return Text(
                        '$formattedTime: $messageText',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatRoomScreen(
                          chatRoomId: chatRoomId,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
