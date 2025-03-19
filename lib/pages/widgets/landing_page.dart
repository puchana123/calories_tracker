import 'package:calories_tracker/models/daily_calories_model.dart';
import 'package:calories_tracker/models/user_model.dart';
import 'package:calories_tracker/pages/widgets/add_calories.dart';
import 'package:calories_tracker/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// Landing Page
class LandingPage extends StatefulWidget {
  final UserModel? user;
  final FirebaseService firebaseService;

  const LandingPage(
      {super.key, required this.user, required this.firebaseService});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  DailyCalories? _dailyCalories;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDailyCalories();
  }

  // Update daily calories
  Future<void> _fetchDailyCalories() async {
    if (widget.user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Get today's date
    DateTime today = DateTime.now();
    // Get daily calories for today
    DailyCalories? dailyCalories =
        await widget.firebaseService.getDailyCalories(widget.user!.uid, today);
    if (dailyCalories == null) {
      // If daily calories not found, create a new one
      dailyCalories = DailyCalories(date: today, consumed: 0, burned: 0);
      // add the data to firebase
      await widget.firebaseService
          .addDailyCalories(widget.user!.uid, dailyCalories);
      // Get the data to get the id
      dailyCalories = await widget.firebaseService
          .getDailyCalories(widget.user!.uid, today);
    }

    setState(() {
      _dailyCalories = dailyCalories;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Center(
                      child: Text(
                        "Today",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Calories Left Card
                    _caloriesLeftCard(),
                    SizedBox(height: 10),

                    // Consume & Burned Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _infoCard(
                              "Consume",
                              "${_dailyCalories?.consumed ?? 0} kcal",
                              Icons.fastfood,
                              Colors.orange),
                        ),
                        Expanded(
                          child: _infoCard(
                              "Burned",
                              "${_dailyCalories?.burned ?? 0} kcal",
                              Icons.local_fire_department,
                              Colors.blue),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    // BarChart Section
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                                child: Text(
                              "Total Calories consume",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            )),
                            SizedBox(height: 20),
                            SizedBox(
                              height: 180,
                              child: BarChart(BarChartData(
                                barGroups: [
                                  _barData(0, 4),
                                  _barData(1, 6),
                                  _barData(2, 5),
                                  _barData(3, 7),
                                  _barData(4, 4),
                                  _barData(5, 8),
                                  _barData(6, 3),
                                ],
                                borderData: FlBorderData(show: false),
                                titlesData: FlTitlesData(show: false),
                                gridData: FlGridData(show: false),
                              )),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Buttons
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddCalories(
                                        dailyCalories: _dailyCalories!,
                                        userId: widget.user!.uid,
                                        firebaseService: widget.firebaseService,
                                        onCaloriesAdded: _fetchDailyCalories,
                                      )));
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange),
                        child: Text(
                          "Add Calories",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  // Calories Left Card
  Widget _caloriesLeftCard() {
    int caloriesLeft = (widget.user?.targetCal ?? 0) -
        (_dailyCalories?.consumed ?? 0) +
        (_dailyCalories?.burned ?? 0);
    double progress = 0;
    if ((widget.user?.targetCal ?? 0) > 0) {
      progress = caloriesLeft /
          ((widget.user?.targetCal ?? 0) + (_dailyCalories?.burned ?? 0));
      if (progress > 1) {
        progress = 1;
      }
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Calories Left",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: progress <= 0.5 ? Colors.red : Colors.green,
              minHeight: 10,
            ),
            SizedBox(height: 10),
            Text(
              "$caloriesLeft/${(widget.user?.targetCal ?? 0) + (_dailyCalories?.burned ?? 0)} kcal",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Info Card widget
  Widget _infoCard(String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }

  // BarChart Data
  BarChartGroupData _barData(int x, double y) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(
          toY: y,
          color: Colors.orange,
          width: 16,
          borderRadius: BorderRadius.circular(8))
    ]);
  }
}
