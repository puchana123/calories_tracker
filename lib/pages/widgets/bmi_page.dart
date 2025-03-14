import 'package:calories_tracker/models/user_model.dart';
import 'package:calories_tracker/pages/widgets/edit_user_details.dart';
import 'package:calories_tracker/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// BMI Page
class BMIPage extends StatefulWidget {
  final UserModel? user;
  final FirebaseService firebaseService;

  const BMIPage({super.key, required this.user, required this.firebaseService});

  @override
  State<BMIPage> createState() => _BMIPageState();
}

class _BMIPageState extends State<BMIPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),

                Text(
                  "Today",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20,
                ),
                // BMI Card
                _bmiCard(),
                SizedBox(
                  height: 10,
                ),
                // Line Chart
                _weightChart(),
                SizedBox(
                  height: 10,
                ),
                // Update Details Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final updatedUser = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditUserDetails(
                              user: widget.user!,
                              firebaseService: widget.firebaseService),
                        ),
                      );
                      if (updatedUser != null) {
                        // Show snackbar
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("User details updated successfully!"),
                            duration: Duration(seconds: 3),
                          ));
                        }
                        // refresh the bmi page
                        setState(() {
                          // update the user details
                          widget.user?.age = updatedUser.age;
                          widget.user?.height = updatedUser.height;
                          widget.user?.weight = updatedUser.weight;
                          widget.user?.targetCal = updatedUser.targetCal;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                    child: Text(
                      "Update Details",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await widget.firebaseService.signOut();
                        if (mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/', (Route<dynamic> route) => false);
                        }
                      } catch (e) {
                        print("Error signing out: $e");
                        _showError("Sign Out Error",
                            "There was an error signing you out.");
                      }
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text(
                      "Log Out",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // BMI Card
  Widget _bmiCard() {
    int weight = widget.user?.weight ?? 0;
    int height = widget.user?.height ?? 0;
    double bmi = 0;
    String bmiStatus = "Normal";
    Color bmiColor = Colors.green;

    if (weight > 0 && height > 0) {
      bmi = double.parse(
          (weight / ((height / 100) * (height / 100))).toStringAsFixed(1));
    }

    if (bmi < 18.5) {
      bmiStatus = "Underweight";
      bmiColor = Colors.yellow;
    } else if (bmi >= 18.5 && bmi < 24.9) {
      bmiStatus = "Normal";
      bmiColor = Colors.green;
    } else if (bmi >= 25 && bmi < 29.9) {
      bmiStatus = "Overweight";
      bmiColor = Colors.orange;
    } else {
      bmiStatus = "Obese";
      bmiColor = Colors.red;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // BMI Calculator
            Container(
              height: 150,
              decoration:
                  BoxDecoration(color: bmiColor, shape: BoxShape.circle),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      bmi.toString(),
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Text(
                      bmiStatus,
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            _userDetails()
          ],
        ),
      ),
    );
  }

  // Weigth Chart
  Widget _weightChart() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
            height: 150,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: LineChart(LineChartData(
                    titlesData: FlTitlesData(
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          List<String> labels = [
                            "SEP",
                            "OCT",
                            "NOV",
                            "DEC",
                            "JAN",
                            "FEB"
                          ];
                          int index = value.toInt();
                          if (index >= 0 && index < labels.length) {
                            return SideTitleWidget(
                                meta: meta,
                                space: 6,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 3.0),
                                  child: Text(
                                    labels[index],
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ));
                          }
                          return Container();
                        },
                        interval: 1,
                      )),
                    ),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                          spots: [
                            FlSpot(0, 5),
                            FlSpot(1, 4),
                            FlSpot(2, 6),
                            FlSpot(3, 5),
                            FlSpot(4, 7),
                            FlSpot(5, 8),
                          ],
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                          belowBarData: BarAreaData(show: false))
                    ])),
              ),
            )),
      ),
    );
  }

  // User details
  Widget _userDetails() {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.user?.name ?? "User",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                _oneDetail("Age", widget.user?.age.toString() ?? "N/A"),
                _oneDetail("Height", "${widget.user?.height ?? "N/A"} cm"),
                _oneDetail("Weight", "${widget.user?.weight ?? "N/A"} kg"),
                _oneDetail("Target Calories",
                    "${widget.user?.targetCal ?? "N/A"} kcal"),
              ],
            )));
  }

  // One detial
  Widget _oneDetail(String title, String value) {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Row(children: [
          SizedBox(
            width: 20,
          ),
          SizedBox(
            width: 150,
            child: Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: 50,
          ),
          Expanded(
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(value, style: TextStyle(fontSize: 18)))),
        ]),
        SizedBox(
          height: 10,
        ),
        Container(
          width: double.infinity,
          height: 2,
          color: Colors.grey[300],
        )
      ],
    );
  }

  void _showError(String title, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"))
            ],
          );
        });
  }
}
