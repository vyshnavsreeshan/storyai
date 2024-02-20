import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:storyai/models/books.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../models/posts.dart';

class FirestoreService {
  final _storage = FirebaseStorage.instance;
  final _firestore = FirebaseFirestore.instance;
  final CollectionReference _postsCollection =
      FirebaseFirestore.instance.collection('posts');

  Future<String> uploadImage(File image) async {
    final imageId = Uuid().v4();
    final ref = _storage.ref().child('posts/$imageId');
    final task = ref.putFile(image);
    await task.whenComplete(() {});
    final url = await ref.getDownloadURL();
    return url;
  }

  Future<void> addPost(String caption, String imageUrl, String userId,
      String userName, String avatarUrl) async {
    final docRef = _firestore.collection('posts').doc();
    await docRef.set({
      'caption': caption,
      'imageUrl': imageUrl,
      'userId': userId,
      'userName': userName,
      'createdAt': DateTime.now().toUtc(),
      'avatarUrl': avatarUrl,
    });
  }

  Future<String> uploadBook(File image) async {
    final bookId = Uuid().v4();
    final ref = _storage.ref().child('books/$bookId');
    final task = ref.putFile(image);
    await task.whenComplete(() {});
    final url = await ref.getDownloadURL();
    return url;
  }

  Future<void> addBook(
      String title,
      String author,
      String bookUrl,
      String userId,
      String userName,
      String avatarUrl,
      GeoPoint bookLocation) async {
    final docRef = _firestore.collection('books').doc();
    await docRef.set({
      'title': title,
      'author': author,
      'bookUrl': bookUrl,
      'userId': userId,
      'userName': userName,
      'avatarUrl': avatarUrl,
      'bookLocation': bookLocation,
      'isAvailable': true,
    });
  }

  Future<List<Post>> getPosts(
      {int? limit, DocumentSnapshot? startAfter}) async {
    Query query = _postsCollection.orderBy('createdAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    QuerySnapshot querySnapshot = await query.get();
    return querySnapshot.docs.map((doc) {
      return Post(
        documentSnapshot: doc,
        id: doc.id,
        caption: doc['caption'],
        imageUrl: doc['imageUrl'],
        userId: doc['userId'],
        userName: doc['userName'],
        createdAt: (doc['createdAt'] as Timestamp).toDate(),
        avatarUrl: doc['avatarUrl'],
      );
    }).toList();
  }

  Stream<List<Books>> getBooks(GeoPoint? userLocation) {
    if (userLocation == null) {
      return Stream.value([]);
    }
    double radius = 10.0;
    return _firestore
        .collection('books')
        .where('bookLocation',
            isGreaterThan: GeoPoint(
              userLocation.latitude - (radius / 110.574),
              userLocation.longitude -
                  (radius / (111.320 * cos(userLocation.latitude))),
            ))
        .where('bookLocation',
            isLessThan: GeoPoint(
              userLocation.latitude + (radius / 110.574),
              userLocation.longitude +
                  (radius / (111.320 * cos(userLocation.latitude))),
            ))
        .orderBy('bookLocation', descending: false)
        .snapshots()
        .map((snapshots) {
      return snapshots.docs.map((doc) {
        return Books(
            id: doc.id,
            title: doc['title'],
            author: doc['author'],
            bookLocation: doc['bookLocation'],
            bookUrl: doc['bookUrl'],
            userId: doc['userId'],
            userName: doc['userName'],
            avatarUrl: doc['avatarUrl'],
            isAvailable: doc['isAvailable']);
      }).toList();
    });
  }

  Stream<List<Books>> searchedBook(String query) {
    String lowercaseQuery = query.toLowerCase().trim();
    return _firestore.collection('books').snapshots().map((snapshots) {
      return snapshots.docs
          .map((doc) {
            String bookTitle = doc['title'].toLowerCase().trim();
            return bookTitle.contains(lowercaseQuery)
                ? Books(
                    id: doc.id,
                    title: doc['title'],
                    author: doc['author'],
                    bookLocation: doc['bookLocation'],
                    bookUrl: doc['bookUrl'],
                    userId: doc['userId'],
                    userName: doc['userName'],
                    avatarUrl: doc['avatarUrl'],
                    isAvailable: doc['isAvailable'])
                : null;
          })
          .where((book) => book != null)
          .toList()
          .cast<Books>();
    });
  }

  Future<List<String>> getPref() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid;

    if (currentUserId != null) {
      try {
        final userPrefSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('userId', isEqualTo: currentUserId)
            .get();

        if (userPrefSnapshot.docs.isNotEmpty) {
          // Assuming user preferences are stored as a list of strings in the Firestore document
          final userPrefData = userPrefSnapshot.docs.first.data();
          final userPrefList = userPrefData['preferences'] as List<dynamic>;

          // Convert dynamic list to a list of strings
          final List<String> preferences = userPrefList.cast<String>();

          return preferences;
        } else {
          // No preferences found for the user
          return [];
        }
      } catch (error) {
        // Handle error if any
        print('Error retrieving user preferences: $error');
        return []; // Return an empty list in case of an error
      }
    } else {
      // Current user not authenticated
      return []; // Return an empty list
    }
  }
}
