import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:storyai/models/books.dart';
import 'package:storyai/services/firestoreServices.dart';
import 'package:storyai/theme/pallete.dart';
import '../../components/bookCard.dart';

class Store extends StatefulWidget {
  @override
  State<Store> createState() => _StoreState();
}

class _StoreState extends State<Store> with AutomaticKeepAliveClientMixin {
  final _firestoreService = FirestoreService();
  GeoPoint? _userLocation;
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();
  bool _showSearchBar = false; // Track the visibility of the search bar
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
  }

  Future<void> _fetchUserLocation() async {
    await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    GeoPoint userLocation = GeoPoint(position.latitude, position.longitude);
    setState(() {
      _userLocation = userLocation;
      _isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    await _fetchUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Books',
              style: TextStyle(
                color: Pallete.brown,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            IconButton(
              onPressed: () {
                setState(() {
                  _showSearchBar = !_showSearchBar;
                });
              },
              icon: Icon(
                Icons.search,
                color: Pallete.brown,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: _showSearchBar ? 60 : 0,
                      child: Card(
                        color: Pallete.brown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            style: TextStyle(color: Pallete.whiteColor),
                            cursorColor: Pallete.whiteColor,
                            controller: _searchController,
                            onChanged: (query) {
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: TextStyle(color: Pallete.whiteColor),
                              border: InputBorder.none,
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {});
                                      },
                                      icon: Icon(
                                        Icons.clear,
                                        color: Pallete.whiteColor,
                                      ),
                                    )
                                  : null,
                              prefixIcon: _showSearchBar
                                  ? Icon(
                                      Icons.search,
                                      color: Pallete.whiteColor,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<List<Books>>(
                      stream: _searchController.text.isNotEmpty
                          ? _firestoreService
                              .searchedBook(_searchController.text)
                          : _firestoreService.getBooks(_userLocation),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              'No books available near your location.',
                            ),
                          );
                        }
                        final books = snapshot.data!;

                        return ListView.builder(
                          itemCount: books.length,
                          itemBuilder: (context, index) {
                            final book = books[index];
                            final bookOwnerId = book.userId;
                            return BookCard(
                              book: book,
                              bookOwnerId: bookOwnerId,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
