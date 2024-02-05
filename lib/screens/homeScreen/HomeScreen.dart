import 'package:storyai/screens/addBookOrPost/AddOptionsScreen.dart';
import 'package:storyai/screens/feed/feed.dart';
import 'package:storyai/screens/messageScreen/Message.dart';
import 'package:storyai/screens/profileScreen/Profile.dart';
import 'package:storyai/screens/storeScreen/Store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:storyai/screens/story/storyScreen.dart';
import 'package:storyai/theme/pallete.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    getCurrentUserId();
  }

  Future<void> getCurrentUserId() async {
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  int _pageIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  List<Widget> _pages = [];

  static const Color bottomNavBackgroundColor = Pallete.cream;

  List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
      backgroundColor: bottomNavBackgroundColor,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.pin),
      label: 'Story',
      backgroundColor: bottomNavBackgroundColor,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.message),
      label: 'Message',
      backgroundColor: bottomNavBackgroundColor,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.add_circle),
      label: 'Add',
      backgroundColor: bottomNavBackgroundColor,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.menu_book_rounded),
      label: 'Books',
      backgroundColor: bottomNavBackgroundColor,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Account',
      backgroundColor: bottomNavBackgroundColor,
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pages = [
      Feed(),
      StoryScreen(),
      MessageScreen(currentUserId: currentUserId ?? ''),
      AddOptionsScreen(),
      Store(),
      Profile(),
    ];
  }

  void _onPageChanged(int pageIndex) {
    setState(() {
      _pageIndex = pageIndex;
    });
  }

  void _onNavItemTapped(int pageIndex) {
    if (pageIndex == 3) {
      showAddOptionsBottomSheet(context);
    } else {
      _pageController.jumpToPage(pageIndex);
      setState(() {
        _pageIndex = pageIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: Visibility(
        child: BottomNavigationBar(
          selectedItemColor: Pallete.brown,
          unselectedItemColor: Colors.grey,
          currentIndex: _pageIndex,
          onTap: _onNavItemTapped,
          items: _navItems,
        ),
      ),
    );
  }

  void showAddOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return const AddOptionsScreen();
      },
    );
  }
}
