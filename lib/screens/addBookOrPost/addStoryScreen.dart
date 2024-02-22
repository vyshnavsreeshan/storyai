import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:storyai/theme/pallete.dart';

class Story {
  final String story;
  final List<String> genres;
  final String name;
  final String? audioUrl;
  final DateTime createdAt;

  Story({
    required this.story,
    required this.genres,
    required this.name,
    this.audioUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'story': story,
      'genres': genres,
      'audioUrl': audioUrl,
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
  bool _storyEntered = false;
  bool _typeEntered = false;
  bool _audioPicked = false;
  List<String> _selectedGenres = [];
  User? user = FirebaseAuth.instance.currentUser;
  File? _audioFile;
  bool _isUploading = false;
  bool _isUploaded = false;

  final List<String> availableGenres = [
    'Adventure',
    'Mystery',
    'Science Fiction',
    'Fantasy',
    'Romance',
  ];

  void _addStoryToFirestore() async {
    if (_storyEntered && _typeEntered) {
      setState(() {
        _isUploading = true;
      });

      if (user != null) {
        final String uid = user!.uid;
        final String name = user!.displayName ?? '';
        final String profileUrl = user!.photoURL ?? '';

        final story = Story(
          story: _textEditingController.text,
          genres: _selectedGenres,
          name: name,
          audioUrl: '',
          createdAt: DateTime.now(),
        );

        try {
          String? audioUrl;
          if (_audioFile != null) {
            audioUrl = await uploadAudioToStorage(_audioFile!);
          }

          await FirebaseFirestore.instance.collection('stories').add({
            ...story.toMap(),
            'userId': uid,
            'username': name,
            'profileUrl': profileUrl,
            'audioUrl': audioUrl,
            'createdAt': DateTime.now().toUtc(),
          });

          setState(() {
            _isUploaded = true;
            _isUploading = false;
          });

          _textEditingController.clear();
          _selectedGenres.clear();
          _storyEntered = false;

          // Navigate to the previous screen after upload
          Navigator.pop(context);
        } catch (e) {
          print('Error adding story to Firestore: $e');
          setState(() {
            _isUploading = false;
          });
        }
      }
    }
  }

  Future<String> uploadAudioToStorage(File audioFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString() +
          '.${audioFile.path.split('.').last}';
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('audio').child(fileName);

      await storageReference.putFile(audioFile);

      String audioUrl = await storageReference.getDownloadURL();

      print('Audio file uploaded to Firebase Storage');
      return audioUrl;
    } catch (e) {
      print('Error uploading audio file: $e');
      throw e;
    }
  }

  void _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _audioFile = File(result.files.single.path!);
        _audioPicked = true;
      });
    }
  }

  Widget _uploadButton() {
    if (_isUploading) {
      return ElevatedButton(
        onPressed: null,
        child: Text('Uploading...'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
        ),
      );
    } else if (_isUploaded) {
      return ElevatedButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Uploaded'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: _addStoryToFirestore,
        child: Text('Save Story'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Pallete.brown, // Change to your desired color
        ),
      );
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
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(
          "Add Story",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _textEditingController,
                decoration: InputDecoration(
                  hintText: 'Write your short story here',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                    ),
                  ),
                ),
                maxLines: null,
                maxLength: 1000,
                onChanged: (text) {
                  setState(() {
                    _storyEntered = text.isNotEmpty;
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
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
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
                  onPressed: _pickAudio,
                  child: Text('Pick Audio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Pallete.brown,
                  ),
                ),
              SizedBox(height: 20),
              if (_audioPicked) _uploadButton(),
            ],
          ),
        ),
      ),
    );
  }
}
