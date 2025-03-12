import 'package:calories_tracker/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// Landing Page
class LandingPage extends StatelessWidget {
  final UserModel? user;

  const LandingPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Center(
                child: Text(
                  "Today",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),

              // Calories Left Card
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Calories Left",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: 500 / 2000,
                        backgroundColor: Colors.grey[300],
                        color: Colors.green,
                        minHeight: 10,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "500/2000 kcal",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Consume & Burned Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _infoCard(
                        "Consume", "1700 kcal", Icons.fastfood, Colors.orange),
                  ),
                  Expanded(
                    child: _infoCard("Burned", "200 kcal",
                        Icons.local_fire_department, Colors.blue),
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
              _customButton("Add Consume", Colors.orange),
              SizedBox(height: 10),
              _customButton("Add Workout", Colors.green),
            ],
          ),
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

  // Buttons
  Widget _customButton(String text, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(backgroundColor: color),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }
}
