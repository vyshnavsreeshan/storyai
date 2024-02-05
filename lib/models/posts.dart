import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final DocumentSnapshot documentSnapshot;
  final String id;
  final String caption;
  final String imageUrl;
  final String userId;
  final String userName;
  final DateTime createdAt;
  final String avatarUrl;

  Post({
    required this.documentSnapshot,
    required this.id,
    required this.caption,
    required this.imageUrl,
    required this.userId,
    required this.userName,
    required this.createdAt,
    required this.avatarUrl,
  });
}
