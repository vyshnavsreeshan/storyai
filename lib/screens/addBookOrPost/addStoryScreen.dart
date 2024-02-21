import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:storyai/theme/pallete.dart';

class Story {
  final String story;
  final List<String> genres;
  final String name;

  Story({
    required this.story,
    required this.genres,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'story': story,
      'genres': genres,
    };
  }
}

class AddStoryScreen extends StatefulWidget {
  const AddStoryScreen({Key? key}) : super(key: key);

  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  TextEditingController _textEditingController = TextEditingController();
  TextEditingController _typeEditingController = TextEditingController();
  bool _storyEntered = false; // Track whether story text has been entered
  bool _typeEntered = false;
  List<String> _selectedGenres = []; // List to store selected genres
  User? user = FirebaseAuth.instance.currentUser;

  // Predefined list of available genres
  final List<String> availableGenres = [
    'Adventure',
    'Mystery',
    'Science Fiction',
    'Fantasy',
    'Romance',
  ];

  void _addStoryToFirestore() async {
    if (_storyEntered) {
      // Get user information
      if (user != null) {
        final String uid = user!.uid;
        final String name = user!.displayName ?? '';
        final String profileUrl = user!.photoURL ?? '';

        // Create the story object
        final story = Story(
          story: _textEditingController.text,
          genres: _selectedGenres,
          name: name,
        );

        try {
          // Add story to Firestore
          await FirebaseFirestore.instance.collection('stories').add({
            ...story.toMap(),
            'userId': uid,
            'username': name,
            'profileUrl': profileUrl,
          });
          // Clear text fields and selected genres
          _textEditingController.clear();
          _selectedGenres.clear();
          _storyEntered = false;
          setState(() {});
          Navigator.pop(context);
          // Show success message or navigate to another screen
        } catch (e) {
          print('Error adding story to Firestore: $e');
          // Show error message
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Pallete.brown),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(
          "Add Story",
          style: TextStyle(
            color: Pallete.brown,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                hintText: 'Write your short story here',
              ),
              maxLines: null,
              maxLength: 1000, // Allow multiple lines of text
              onChanged: (text) {
                setState(() {
                  _storyEntered = text.isNotEmpty; // Track if story is entered
                });
              },
            ),
            SizedBox(height: 20),
            _storyEntered
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Genre(s):',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 10),
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          return availableGenres.where((String option) {
                            return option.toLowerCase().contains(
                                  textEditingValue.text.toLowerCase(),
                                );
                          });
                        },
                        onSelected: (String selection) {
                          setState(() {
                            _selectedGenres.add(selection);
                            _typeEditingController.text = selection;
                            _typeEditingController.clear();
                            _typeEntered = _selectedGenres.isNotEmpty;
                          });
                        },
                        fieldViewBuilder: (BuildContext context,
                            TextEditingController fieldTextEditingController,
                            FocusNode fieldFocusNode,
                            VoidCallback onFieldSubmitted) {
                          _typeEditingController = fieldTextEditingController;
                          return TextField(
                            controller: fieldTextEditingController,
                            focusNode: fieldFocusNode,
                            decoration: InputDecoration(
                              hintText: 'Type of the story',
                            ),
                          );
                        },
                        optionsViewBuilder: (BuildContext context,
                            AutocompleteOnSelected<String> onSelected,
                            Iterable<String> options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4.0,
                              child: SizedBox(
                                height: 200.0,
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: options.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final String option =
                                        options.elementAt(index);
                                    return GestureDetector(
                                      onTap: () {
                                        onSelected(option);
                                      },
                                      child: ListTile(
                                        title: Text(option),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      // Display selected genres
                      Wrap(
                        children: _selectedGenres
                            .map(
                              (genre) => Chip(
                                label: Text(genre),
                                onDeleted: () {
                                  setState(() {
                                    _selectedGenres.remove(genre);
                                    _typeEntered = _selectedGenres.isNotEmpty;
                                  });
                                },
                              ),
                            )
                            .toList(),
                      ),
                      SizedBox(height: 20),
                    ],
                  )
                : SizedBox(),
            if (_typeEntered)
              ElevatedButton(
                onPressed: _addStoryToFirestore,
                child: Text('Save Story'),
              )
          ],
        ),
      ),
    );
  }
}
