import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../profileScreen/feedProfile.dart';

class ChatRoomScreen extends StatefulWidget {
  final String chatRoomId;

  const ChatRoomScreen({required this.chatRoomId});

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String otherUserName = '';
  String currentUserId = '';
  String otherUserId = '';
  @override
  void initState() {
    super.initState();
    fetchOtherUserName();
    getCurrentUserId();
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    DateFormat format = DateFormat("h:mm a");
    return format.format(dateTime);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void fetchOtherUserName() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid;

    final chatRoomDoc = FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(widget.chatRoomId);

    final chatRoomSnapshot = await chatRoomDoc.get();

    final userNames =
        chatRoomSnapshot.data()?['userNames'] as Map<String, dynamic>;
    final otherUserId = userNames.keys.firstWhere(
      (userId) => userId != currentUserId,
      orElse: () => '',
    );

    final otherUserName = userNames[otherUserId];

    setState(() {
      this.otherUserName = otherUserName;
      this.otherUserId = otherUserId;
    });
  }

  void getCurrentUserId() {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid;

    setState(() {
      this.currentUserId = currentUserId ?? '';
    });
  }

  void _sendMessage(String message) {
    if (message.trim().isNotEmpty) {
      final currentUser = FirebaseAuth.instance.currentUser;
      final currentUserId = currentUser?.uid;

      final messageData = {
        'senderId': currentUserId,
        'content': message,
        'timestamp': DateTime.now(),
      };

      final timeData = {
        'timestamp': DateTime.now(),
      };

      FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.chatRoomId)
          .update(timeData)
          .then((value) {
        FirebaseFirestore.instance
            .collection('chatRooms')
            .doc(widget.chatRoomId)
            .collection('messages')
            .add(messageData)
            .then((value) {})
            .catchError((error) {
          print('Failed to send message: $error');
        });
      }).catchError((error) {
        print('Failed to update timestamp: $error');
      });

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                // Navigate to the profile screen for the user associated with the post
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeedProfile(userId: otherUserId),
                  ),
                );
              },
              child: Text(
                otherUserName,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chatRooms')
                  .doc(widget.chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        messages[index].data() as Map<String, dynamic>;
                    final senderId = message['senderId'];
                    final content = message['content'];
                    final timestamp = message['timestamp'] as Timestamp;
                    final isMe = senderId == currentUserId;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 250),
                        margin:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Color.fromARGB(255, 30, 66, 58)
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              content,
                              style: TextStyle(
                                fontSize: 16,
                                color: isMe ? Colors.white : Colors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              formatTimestamp(timestamp),
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                    ),
                    maxLines: null,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(_messageController.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
