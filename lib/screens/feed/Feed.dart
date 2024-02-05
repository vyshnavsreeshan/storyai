import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:storyai/services/firestoreServices.dart';
import 'package:storyai/theme/pallete.dart';
import '../../components/postCard.dart';
import '../../models/posts.dart';

class Feed extends StatefulWidget {
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> with AutomaticKeepAliveClientMixin {
  final _firestoreService = FirestoreService();
  List<Post> _posts = [];
  bool _isFetching = false;
  String _errorMessage = '';
  int _postLimit = 2;
  DocumentSnapshot? _lastDocument;
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (_posts.isEmpty) {
      // Fetch posts only if the list is empty
      _fetchPosts();
    }

    // Add a listener to the scroll controller
    _scrollController.addListener(() {
      // Check if the user has reached the end of the list
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchPosts();
      }
    });
  }

  Future<void> _fetchPosts() async {
    if (_isFetching) {
      return;
    }

    setState(() {
      _isFetching = true;
      _errorMessage = '';
    });

    try {
      List<Post> fetchedPosts = await _firestoreService.getPosts(
        limit: _postLimit,
        startAfter: _lastDocument,
      );

      if (fetchedPosts.isNotEmpty) {
        _lastDocument = fetchedPosts.last.documentSnapshot;
      }

      print('Fetched ${fetchedPosts.length} posts.');
      setState(() {
        // Append new posts to the existing list
        _posts.addAll(fetchedPosts);
      });
    } catch (error) {
      print('Error fetching posts: $error');
      setState(() {
        _errorMessage = 'Error fetching posts. Please try again.';
      });
    } finally {
      setState(() {
        _isFetching = false;
      });
    }
  }

  Future<void> _refreshPosts() async {
    _lastDocument = null;
    _posts.clear();
    await _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    super.build(
        context); // Ensure that AutomaticKeepAliveClientMixin is correctly implemented

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Feed Explore',
              style: TextStyle(
                color: Pallete.brown,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        titleSpacing: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: _errorMessage.isNotEmpty
            ? Center(
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              )
            : ListView.builder(
                controller: _scrollController,
                itemCount: _posts.length + 1,
                itemBuilder: (context, index) {
                  if (index < _posts.length) {
                    final post = _posts[index];
                    return PostCard(post: post);
                  } else {
                    return Center(
                      child: _isFetching ? CircularProgressIndicator() : null,
                    );
                  }
                },
              ),
      ),
    );
  }
}
