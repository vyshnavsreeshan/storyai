import 'package:cloud_firestore/cloud_firestore.dart';

class Books {
  final String id;
  final String title;
  final String author;
  final GeoPoint bookLocation;
  final String bookUrl;
  final String userId;
  final String userName;
  final String avatarUrl;
  final bool isAvailable;

  Books({
    required this.id,
    required this.title,
    required this.author,
    required this.bookLocation,
    required this.bookUrl,
    required this.userId,
    required this.userName,
    required this.avatarUrl,
    required this.isAvailable,
  });
}
