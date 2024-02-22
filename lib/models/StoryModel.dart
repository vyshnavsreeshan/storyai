import 'package:cloud_firestore/cloud_firestore.dart';

class StoryModel {
  final DocumentSnapshot documentSnapshot;
  final String story;
  final List<String> genres;
  final String name;
  final String? audioUrl;
  final DateTime createdAt;
  final String title;

  StoryModel({
    required this.documentSnapshot,
    required this.story,
    required this.genres,
    required this.name,
    this.audioUrl,
    required this.createdAt,
    required this.title,
  });
}
