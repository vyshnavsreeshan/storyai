import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:storyai/screens/homeScreen/HomeScreen.dart'; // Import the HomeScreen widget

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Maintain user preferences
  List<String> selectedGenres = [];

  final List<String> availableGenres = [
  'Adventure',
  'Mystery',
  'Science Fiction',
  'Fantasy',
  'Romance',
  'Historical Fiction',
  'Thriller',
  'Horror',
  'Drama',
  'Comedy',
  'Western',
  'Fantasy Adventure',
  'Action',
  'Psychological Thriller',
  'Crime',
  'War',
  'Comedy',
  'Space Opera',
  'Cyberpunk',
  'Superhero',
  'Fairy Tale',
  'Autobiography',
  'Historical Romance',
  'Post-Apocalyptic',
  'Time Travel',
  'Romantic Comedy',
  'Alien Invasion',
  'Travelogue',
  'Medical Thriller',
  'Magical Realism',
  'Mythology',
  'Biography',
  'Social Commentary',
  'Gothic',
  'Political Fiction',
  'Family Saga',
  'Legal Drama',
  'Urban Fantasy',
  'Humor Satire',
  'Domestic Noir',
  'Paranormal',
  'Techno-Thriller',
  'Adventure Comedy',
  'Space Western',
  'Military Fiction',
  'Alternate Reality',
  'Religious Fiction',
  'Philosophical Fiction',
  'Hard Science Fiction',
  'Soft Science Fiction',
  'Military Science Fiction',
  'Futuristic Fiction',
];

  int maxDisplayedGenres = 26; // Set the maximum number of displayed genres

  String? searchText;

  @override
  Widget build(BuildContext context) {
    List<String> filteredGenres = searchText != null && searchText!.isNotEmpty
        ? availableGenres
            .where((genre) =>
                genre.toLowerCase().contains(searchText!.toLowerCase()))
            .toList()
        : availableGenres;

    return Scaffold(
      appBar: AppBar(
        title: Text('User Onboarding'),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: GenreSearchDelegate(availableGenres),
              ).then((selectedGenre) {
                if (selectedGenre != null) {
                  setState(() {
                    selectedGenres.add(selectedGenre);
                  });
                }
              });
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Select your preferences:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: filteredGenres
                  .take(maxDisplayedGenres)
                  .map((genre) {
                    bool isSelected = selectedGenres.contains(genre);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedGenres.remove(genre);
                          } else {
                            selectedGenres.add(genre);
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : null,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: Text(
                          genre,
                          style: TextStyle(
                            color: isSelected ? Colors.white : null,
                          ),
                        ),
                      ),
                    );
                  })
                  .toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setPref();
                // Navigate to HomeScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              child: Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  void setPref() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentReference userDocRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        await userDocRef.update({'preferences': selectedGenres});
        print('User preferences updated successfully: $selectedGenres');
      } catch (error) {
        print('Error updating user preferences: $error');
      }
    }
  }
}

class GenreSearchDelegate extends SearchDelegate<String> {
  final List<String> availableGenres;

  GenreSearchDelegate(this.availableGenres);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final List<String> searchResults = query.isEmpty
        ? availableGenres
        : availableGenres
            .where((genre) =>
                genre.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final String genre = searchResults[index];
        return ListTile(
          title: Text(genre),
          onTap: () {
            close(context, genre);
          },
        );
      },
    );
  }
}
