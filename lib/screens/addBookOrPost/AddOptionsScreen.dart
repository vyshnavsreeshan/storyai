import 'package:flutter/material.dart';
import 'package:storyai/theme/pallete.dart';
import 'AddBookScreen.dart';
import 'AddPostScreen.dart';

class AddOptionsScreen extends StatelessWidget {
  const AddOptionsScreen({Key? key}) : super(key: key);

  void _handleBookOption(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return AddBookScreen();
        },
      ),
    );
  }

  void _handlePostOption(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return AddPostScreen();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Pallete.cream,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Upload Options',
              style: TextStyle(
                color: Pallete.brown,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.post_add,
              color: Pallete.brown,
            ),
            title: Text(
              'Add Post',
              style: TextStyle(color: Pallete.brown),
            ),
            onTap: () {
              Navigator.of(context).pop();
              _handlePostOption(context);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.book,
              color: Pallete.brown,
            ),
            title: Text(
              'Add Book',
              style: TextStyle(color: Pallete.brown),
            ),
            onTap: () {
              Navigator.of(context).pop();
              _handleBookOption(context);
            },
          ),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }
}

