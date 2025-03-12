import 'package:calories_tracker/models/user_model.dart';
import 'package:calories_tracker/pages/widgets/bmi_page.dart';
import 'package:calories_tracker/pages/widgets/history_page.dart';
import 'package:calories_tracker/pages/widgets/landing_page.dart';
import 'package:calories_tracker/services/firebase_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({super.key, required this.username});

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
    UserModel? fetchedUser =
        await firebaseService.getUserDetalis(widget.username);

    setState(() {
      _user = fetchedUser;
      _isLoading = false;

      _pages = [
        BMIPage(user: _user),
        LandingPage(user: _user),
        HistoryPage(user: _user),
      ];
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
