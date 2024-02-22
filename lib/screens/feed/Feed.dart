import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:storyai/components/StoryCard.dart';
import 'package:storyai/models/StoryModel.dart';
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
  List<dynamic> _feedItems = [];
  bool _isFetching = false;
  String _errorMessage = '';
  int _postLimit = 2;
  DocumentSnapshot? _lastPostDocument;
  DocumentSnapshot? _lastStoryDocument;
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchData();

    // Add a listener to the scroll controller
    _scrollController.addListener(() {
      // Check if the user has reached the end of the list
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchData();
      }
    });
  }

  Future<void> _fetchData() async {
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
        startAfter: _lastPostDocument,
      );

      if (fetchedPosts.isNotEmpty) {
        // If there are fetched posts, update the last post document
        _lastPostDocument = fetchedPosts.last.documentSnapshot;
      }

      print('Fetched ${fetchedPosts.length} posts.');

      // Fetch and sort stories
      List<StoryModel> fetchedStories = await _firestoreService.getStories(
        limit: _postLimit,
        startAfter: _lastStoryDocument,
      );

      if (fetchedStories.isNotEmpty) {
        // If there are fetched stories, update the last story document
        _lastStoryDocument = fetchedStories.last.documentSnapshot;
      }

      print('Fetched ${fetchedStories.length} stories.');

      // Combine fetched posts and stories
      List<dynamic> combinedItems = [...fetchedPosts, ...fetchedStories];

      // Sort combined items by creation time in descending order
      combinedItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Append combined items to the end of the feed items list
      setState(() {
        _feedItems.addAll(combinedItems);
      });
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        _errorMessage = 'Error fetching data. Please try again.';
      });
    } finally {
      setState(() {
        _isFetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
        onRefresh: () async {
          _lastPostDocument = null;
          _lastStoryDocument = null;
          _feedItems.clear();
          await _fetchData();
        },
        child: _errorMessage.isNotEmpty
            ? Center(
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              )
            : ListView.builder(
                controller: _scrollController,
                itemCount: _feedItems.length + 1,
                itemBuilder: (context, index) {
                  if (index < _feedItems.length) {
                    final item = _feedItems[index];
                    if (item is Post) {
                      return PostCard(post: item);
                    } else if (item is StoryModel) {
                      return StoryCard(story: item);
                    }
                  }

                  // This is for the loading indicator
                  if (index == _feedItems.length) {
                    return Center(
                      child: _isFetching ? CircularProgressIndicator() : null,
                    );
                  }

                  // Return an empty container if index exceeds the total count
                  return Container();
                },
              ),
      ),
    );
  }
}
