import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:storyai/services/firestoreServices.dart';
import 'package:storyai/theme/pallete.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  File? _image;
  late String _userName;
  late String _avatar;
  final _captionController = TextEditingController();
  bool _isUploading = false;
  bool _isUploaded = false;

  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    setState(() {
      _userName = userData.get('userName');
      _avatar = userData.get('photoUrl');
    });
  }

  Future<void> _uploadPost() async {
    setState(() {
      _isUploading = true;
    });
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final imageUrl = await FirestoreService().uploadImage(_image!);

    final caption = _captionController.text.trim();

    await FirestoreService()
        .addPost(caption, imageUrl, userId, _userName, _avatar);

    setState(() {
      _isUploading = false;
      _isUploaded = true;
    });
    Future.delayed(Duration(seconds: 1), () {
      Navigator.pop(context);
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Pallete.brown,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Add Post",
          style: TextStyle(
            color: Pallete.brown,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_image == null)
                  Opacity(
                    opacity: 0.40,
                    child: Image.asset(
                      'assets/uploadIcon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                if (_image != null) Image.file(_image!, fit: BoxFit.contain),
                if (_image != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _captionController,
                        decoration: InputDecoration(
                          hintText: 'Enter a caption',
                          fillColor: Color.fromRGBO(255, 246, 217, 0),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Pallete.brown),
                          ),
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: _isUploading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : _isUploaded
                    ? Center(
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 48,
                        ),
                      )
                    : _image != null
                        ? ElevatedButton.icon(
                            onPressed: _uploadPost,
                            icon: Icon(Icons.post_add),
                            label: Text('Post'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Pallete.brown,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: Icon(Icons.add_photo_alternate),
                            label: Text('Add Image'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Pallete.brown,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }
}
