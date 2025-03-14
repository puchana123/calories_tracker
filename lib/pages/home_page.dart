import 'package:calories_tracker/models/user_model.dart';
import 'package:calories_tracker/pages/widgets/bmi_page.dart';
import 'package:calories_tracker/pages/widgets/history_page.dart';
import 'package:calories_tracker/pages/widgets/landing_page.dart';
import 'package:calories_tracker/services/firebase_service.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    FirebaseService firebaseService = FirebaseService();
    UserModel? fetchedUser = await firebaseService.getUserDetalis(widget.uid);

    setState(() {
      _user = fetchedUser;
      _isLoading = false;

      if (_user != null) {
        _pages = [
          BMIPage(user: _user, firebaseService: firebaseService),
          LandingPage(user: _user, firebaseService: firebaseService),
          HistoryPage(user: _user),
        ];
      } else {
        _pages = [
          Center(
            child: Text("User not found"),
          ),
          Center(
            child: Text("User not found"),
          ),
          Center(
            child: Text("User not found"),
          )
        ];
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
