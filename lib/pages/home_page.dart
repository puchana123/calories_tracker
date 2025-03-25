import 'package:calories_tracker/models/user_model.dart';
import 'package:calories_tracker/pages/widgets/bmi_page.dart';
import 'package:calories_tracker/pages/widgets/history_page.dart';
import 'package:calories_tracker/pages/widgets/landing_page.dart';
import 'package:calories_tracker/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  final FirebaseService firebaseService;
  final String userId;

  const HomePage(
      {super.key, required this.userId, required this.firebaseService});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserModel? _user;
  bool _isLoading = true;
  int _selectedIndex = 1;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Try to load from cache first
      final cachedUser = await _loadUserFromCache();
      if (cachedUser != null && mounted) {
        setState(() {
          _user = cachedUser;
          _isLoading = false;
          // print("Loaded user from cache: ${_user?.toMap()}");
        });
        _initializePages();
      }
      // Fetch from Firebase
      final user = await widget.firebaseService.getUser(widget.userId);
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
          if (user != null) {
            // print("Fetched and cached user: ${user.uid}");
          } else {
            // print("No user data found for UID: ${widget.userId}");
          }
        });
        if (user != null) {
          await _saveUserToCache(user);
          _initializePages();
        }
      }
    } catch (e) {
      // print("Error fetching user details: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveUserToCache(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = {
      'timestamp': DateTime.now().toIso8601String(),
      'uid': user.uid,
      'name': user.name,
      'email': user.email,
      'age': user.age,
      'height': user.height,
      'weight': user.weight,
      'targetCal': user.targetCal,
    };
    await prefs.setString('user_${user.uid}', jsonEncode(jsonData));
  }

  Future<UserModel?> _loadUserFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString('user_${widget.userId}');
    if (cachedJson != null) {
      final jsonData = jsonDecode(cachedJson);
      final timestamp = DateTime.parse(jsonData['timestamp']);
      if (DateTime.now().difference(timestamp).inHours < 24) {
        return UserModel(
          uid: jsonData['uid'],
          name: jsonData['name'],
          email: jsonData['email'],
          age: jsonData['age'],
          height: jsonData['height'],
          weight: jsonData['weight'],
          targetCal: jsonData['targetCal'],
        );
      }
    }
    return null;
  }

  void _initializePages() {
    void refreshAll() {
      _fetchUserDetails();
      if (mounted) {
        setState(() {
          _pages = _buildPages(refreshAll);
        });
      }
    }

    _pages = _buildPages(refreshAll);
  }

  List<Widget> _buildPages(Function() refreshCallback) {
    return [
      BMIPage(
        user: _user,
        firebaseService: widget.firebaseService,
        onUserUpdated: (updatedUser) {
          if (mounted) {
            setState(() {
              _user = updatedUser;
              _pages = _buildPages(refreshCallback);
            });
          }
        },
      ),
      LandingPage(
        key: UniqueKey(),
        user: _user,
        firebaseService: widget.firebaseService,
        onCaloriesAdded: refreshCallback,
      ),
      HistoryPage(
        key: UniqueKey(),
        user: _user,
        firebaseService: widget.firebaseService,
        onCaloriesAdded: refreshCallback,
      ),
    ];
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 50),
          SizedBox(height: 10),
          Text("User not found"),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: Text("Go back"),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LinearProgressIndicator(),
                    SizedBox(height: 10),
                    Text("Loading..."),
                  ],
                ),
              ),
            )
          : _user == null
              ? _buildErrorWidget()
              : IndexedStack(
                  index: _selectedIndex,
                  children: _pages,
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: "BMI",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),
        ],
      ),
    );
  }
}
