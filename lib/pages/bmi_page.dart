import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// BMI Page
class BMIPage extends StatelessWidget {
  const BMIPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16),
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
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: Text(
                    "Update Weight",
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
              height: 200,
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
            height: 250,
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
}
