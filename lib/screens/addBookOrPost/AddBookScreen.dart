import 'dart:io';
import 'package:storyai/services/firestoreServices.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:storyai/theme/pallete.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({Key? key}) : super(key: key);

  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  File? _image;
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _picker = ImagePicker();
  bool _isButtonEnabled = false;
  String? _location;
  late String _userName;
  late String _avatar;
  bool _isUploading = false;
  bool _isUploaded = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isButtonEnabled = _image != null &&
            _titleController.text.isNotEmpty &&
            _authorController.text.isNotEmpty &&
            _location != null;
      });
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

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_updateButtonState);
    _authorController.addListener(_updateButtonState);
    _getCurrentUser();
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _image != null &&
          _titleController.text.isNotEmpty &&
          _authorController.text.isNotEmpty &&
          _location != null;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
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
          "Add Book",
          style: TextStyle(
            color: Pallete.brown,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                alignment: Alignment.center,
                width: 150,
                height: 200,
                decoration: BoxDecoration(
                  color: Pallete.cream,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _image == null
                    ? Icon(Icons.image, size: 50, color: Colors.grey)
                    : Image.file(_image!, fit: BoxFit.contain),
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _authorController,
                decoration: InputDecoration(
                  labelText: 'Author',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            // location
            SizedBox(height: 16),
            Container(
              height: 50.0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        enabled: false,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Location',
                        ),
                        controller: TextEditingController(text: _location),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child: IconButton(
                        onPressed: () {
                          _fetchLocation(); //button function
                        },
                        icon: Icon(Icons.my_location_rounded),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  4.0), // Adjust the border radius as needed
                              side: BorderSide(
                                  color: Pallete
                                      .brown), // Adjust the border color as needed
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //Location
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
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
                      : ElevatedButton.icon(
                          onPressed: _isButtonEnabled
                              ? () async {
                                  setState(() {
                                    _isUploading = true;
                                  });

                                  final userId =
                                      FirebaseAuth.instance.currentUser!.uid;
                                  final bookUrl = await FirestoreService()
                                      .uploadBook(_image!);
                                  final title = _titleController.text.trim();
                                  final author = _authorController.text.trim();
                                  final bookLocation = await _fetchLocation();
                                  await FirestoreService().addBook(
                                      title,
                                      author,
                                      bookUrl,
                                      userId,
                                      _userName,
                                      _avatar,
                                      bookLocation);
                                  setState(() {
                                    _isUploading = false;
                                    _isUploaded = true;
                                  });
                                  Future.delayed(Duration(seconds: 1), () {
                                    Navigator.pop(context);
                                  });
                                }
                              : null,
                          icon: Icon(Icons.my_library_books_outlined),
                          label: Text('Post Book'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _isButtonEnabled ? Pallete.brown : Colors.grey,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                        ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<GeoPoint> _fetchLocation() async {
    await Geolocator.requestPermission();

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    GeoPoint _bookLocation = GeoPoint(position.latitude, position.longitude);
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    Placemark placemark = placemarks[0];
    String formattedAddress = '${placemark.subLocality}, ${placemark.locality}';

    setState(() {
      _location = formattedAddress;
      _isButtonEnabled = _image != null &&
          _titleController.text.isNotEmpty &&
          _authorController.text.isNotEmpty &&
          _location != null;
    });

    return _bookLocation;
  }
}
