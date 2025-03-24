import 'package:calories_tracker/models/user_model.dart';
import 'package:calories_tracker/pages/widgets/bmi_page.dart';
import 'package:calories_tracker/pages/widgets/history_page.dart';
import 'package:calories_tracker/pages/widgets/landing_page.dart';
import 'package:calories_tracker/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  final String uid;

  const HomePage({super.key, required this.uid});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserModel? _user;
  bool _isLoading = true;
  int _selectedIndex = 1;
  List<Widget> _pages = [];
  late FirebaseService _firebaseService;

  @override
  void initState() {
    super.initState();
    _firebaseService = FirebaseService();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    if(!mounted) return;

    setState(() {
      _isLoading = true;
    });

    // Try loading from cache
    final cachedUser = await _loadUserFromCache();
    if (cachedUser != null && mounted) {
      setState(() {
        _user = cachedUser;
        _initializePages();
        _isLoading = false;
      });
    }

    // Fetch user details from Firebase
    UserModel? fetchedUser = await _firebaseService.getUser(widget.uid);

    if(mounted){
      setState(() {
        _user = fetchedUser;
        _initializePages();
        _isLoading = false;
      });
    }

    if (fetchedUser != null) {
      await _saveUserToCache(fetchedUser);
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
    await prefs.setString('user_${widget.uid}', jsonEncode(jsonData));
  }

  Future<UserModel?> _loadUserFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString('user_${widget.uid}');
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
    if (_user != null) {
      _pages = [
        BMIPage(
          user: _user,
          firebaseService: _firebaseService,
          onUserUpdated: (updatedUser) {
            if(mounted){
              setState(() {
                _user = updatedUser;
                _initializePages();
              });
            }
          },
        ),
        LandingPage(user: _user, firebaseService: _firebaseService),
        HistoryPage(
          user: _user,
          firebaseService: _firebaseService,
          key: UniqueKey(),
        ),
      ];
    } else {
      _pages = [
        _buildErrorWidget(),
        _buildErrorWidget(),
        _buildErrorWidget(),
      ];
    }
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
              if(mounted){
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
    if(mounted){
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
