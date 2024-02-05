import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:storyai/theme/pallete.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with AutomaticKeepAliveClientMixin {
  int selectedTab = 0;
  late String currentUserId;
  bool isPostSelected = false;
  bool isBookSelected = false;
  late DocumentSnapshot selectedPost;
  late DocumentSnapshot selectedBook;
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<DocumentSnapshot> fetchUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    currentUserId = currentUser?.uid ?? '';

    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(currentUserId);

    try {
      final snapshot = await userDoc.get();
      return snapshot;
    } catch (error) {
      print('Failed to fetch user data: $error');
      throw error;
    }
  }

  Stream<QuerySnapshot> fetchUserPosts() {
    final userPostsCollection = FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots();

    return userPostsCollection;
  }

  Stream<QuerySnapshot> fetchUserBooks() {
    final userBooksCollection = FirebaseFirestore.instance
        .collection('books')
        .where('userId', isEqualTo: currentUserId)
        .snapshots();

    return userBooksCollection;
  }

  void selectPost(DocumentSnapshot post) {
    setState(() {
      isPostSelected = true;
      selectedPost = post;
    });
  }

  void selectBook(DocumentSnapshot book) {
    setState(() {
      isBookSelected = true;
      selectedBook = book;
    });
  }

  void deselectPost() {
    setState(() {
      isPostSelected = false;
    });
  }

  void deselectBook() {
    setState(() {
      isBookSelected = false;
    });
  }

  Future<void> deletePost(DocumentSnapshot post) async {
    try {
      // Delete the image from Firestore storage
      final imageUrl =
          post['imageUrl']; // Assuming the field name is 'imageUrl'
      final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await storageRef.delete();

      // Delete the post document
      await post.reference.delete();
      deselectPost();
      // Show a success message or perform any other desired action
    } catch (error) {
      print('Failed to delete post: $error');
      // Show an error message or perform any other desired action
    }
  }

  Future<void> deleteBook(DocumentSnapshot book) async {
    try {
      final bookUrl = book['bookUrl'];
      final storageRef = FirebaseStorage.instance.refFromURL(bookUrl);
      await storageRef.delete();
      await book.reference.delete();
      deselectBook();
      // Show a success message or perform any other desired action
    } catch (error) {
      print('Failed to delete book: $error');
      // Show an error message or perform any other desired action
    }
  }

  Future<void> toggleBookAvailability(DocumentSnapshot book) async {
    final bookRef = book.reference;
    final isAvailable = book['isAvailable'];

    try {
      await bookRef.update({'isAvailable': !isAvailable});

      // Retrieve the updated book document after the update
      final updatedBook = await bookRef.get();

      // Update the selectedBook object with the new isAvailable value
      setState(() {
        selectedBook = updatedBook;
      });
    } catch (error) {
      print('Failed to toggle book availability: $error');
      // Show an error message or perform any other desired action
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
        actions: [
          IconButton(
            onPressed: () async {
              await GoogleSignIn().signOut();
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(
              Icons.power_settings_new,
              color: Pallete.brown,
            ),
          ),
        ],
        title: Row(
          children: [
            Text(
              'Profile',
              style: TextStyle(
                color: Pallete.brown,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<DocumentSnapshot>(
          future: fetchUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Failed to fetch user data'));
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('User data not found'));
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final userName = userData['userName'];
            final email = userData['email'];
            final photoUrl = userData['photoUrl'];

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 16),
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(photoUrl),
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedTab = 0;
                                isPostSelected = false;
                              });
                            },
                            child: Text(
                              'Posts',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: selectedTab == 0
                                    ? Pallete.brown
                                    : Colors.grey[400],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedTab = 1;
                                isBookSelected = false;
                              });
                            },
                            child: Text(
                              'Books',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: selectedTab == 1
                                    ? Pallete.brown
                                    : Colors.grey[400],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      if (selectedTab == 0) ...[
                        // Display the Posts tab content
                        if (isPostSelected) ...[
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(photoUrl),
                                      radius: 25,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      userName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Spacer(),
                                    PopupMenuButton(
                                      onSelected: (value) {
                                        if (value == 'delete') {
                                          deletePost(selectedPost);
                                        }
                                      },
                                      itemBuilder: (context) {
                                        return [
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Delete'),
                                          ),
                                        ];
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  selectedPost['caption'],
                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                                SizedBox(height: 10),
                                AspectRatio(
                                  aspectRatio: 4 / 5,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      selectedPost['imageUrl'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Display posts in grid format
                          StreamBuilder<QuerySnapshot>(
                            stream: fetchUserPosts(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Failed to fetch posts'));
                              } else if (!snapshot.hasData) {
                                return Center(child: Text('No posts found'));
                              }

                              final posts = snapshot.data!.docs;

                              return GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 4.0,
                                  mainAxisSpacing: 4.0,
                                ),
                                itemCount: posts.length,
                                itemBuilder: (context, index) {
                                  final post = posts[index];
                                  final imageUrl = post['imageUrl'];

                                  return GestureDetector(
                                    onTap: () {
                                      selectPost(post);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(imageUrl),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ] else if (selectedTab == 1) ...[
                        // Display the Books tab content
                        if (isBookSelected) ...[
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(photoUrl),
                                      radius: 25,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      userName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Spacer(),
                                    PopupMenuButton(
                                      onSelected: (value) {
                                        if (value == 'delete') {
                                          deleteBook(
                                              selectedBook); // Call deleteBook method
                                        } else if (value ==
                                            'toggleAvailability') {
                                          toggleBookAvailability(
                                              selectedBook); // Call toggleBookAvailability method
                                        }
                                      },
                                      itemBuilder: (context) {
                                        return [
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Delete'),
                                          ),
                                          PopupMenuItem(
                                            value: 'toggleAvailability',
                                            child: Text(
                                                selectedBook['isAvailable']
                                                    ? 'Mark Unavailable'
                                                    : 'Mark Available'),
                                          ),
                                        ];
                                      },
                                    ),
                                  ],
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
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        selectedBook['title'],
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
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
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        selectedBook['author'],
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
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
                                        'Availability: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        selectedBook['isAvailable']
                                            ? 'Available'
                                            : 'Unavailable',
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
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
                                      selectedBook['bookUrl'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Display books in grid format
                          StreamBuilder<QuerySnapshot>(
                            stream: fetchUserBooks(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Failed to fetch books'));
                              } else if (!snapshot.hasData) {
                                return Center(child: Text('No books found'));
                              }

                              final books = snapshot.data!.docs;

                              return GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 4.0,
                                  mainAxisSpacing: 4.0,
                                ),
                                itemCount: books.length,
                                itemBuilder: (context, index) {
                                  final book = books[index];
                                  final bookUrl = book['bookUrl'];

                                  return GestureDetector(
                                    onTap: () {
                                      selectBook(book);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(bookUrl),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
