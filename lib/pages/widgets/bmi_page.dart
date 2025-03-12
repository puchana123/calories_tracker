import 'package:calories_tracker/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// BMI Page
class BMIPage extends StatelessWidget {
  final UserModel? user;

  const BMIPage({super.key, required this.user});

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
                // Update Weight Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
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
                  height: 20,
                ),
                // Line Chart
                _weightChart()
              ],
            ),
          ),
        ),
      ),
    );
  }

  // BMI Card
  Widget _bmiCard() {
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
                  BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "20.0",
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Text(
                      "Normal",
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
                      "John Doe",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                _oneDetail("Age", "25"),
                _oneDetail("Height", "175 cm"),
                _oneDetail("Weight", "70 kg"),
                _oneDetail("Target Calories", "2000 kcal"),
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
}
