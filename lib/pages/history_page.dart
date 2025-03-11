import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 20), // Space from top
              Center(
                child: Text(
                  "History Page",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),

              // Total Calories Consumed Card
              _historyCard(
                title: "Total Calories consume",
                value: "2,200",
                change: "+2.45%",
                color: Colors.orange,
                barColor: Colors.orange,
                data: [6, 4, 7, 5, 8, 10, 3], // Example data
              ),
              SizedBox(height: 10),

              // Total Calories Burned Card
              _historyCard(
                title: "Total Calories burned",
                value: "1,200",
                change: "+2.45%",
                color: Colors.blue,
                barColor: Colors.blue,
                data: [5, 3, 6, 4, 7, 9, 2], // Example data
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _historyCard({
    required String title,
    required String value,
    required String change,
    required Color color,
    required Color barColor,
    required List<double> data,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            Row(
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                SizedBox(width: 8),
                Text("kilo calories",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                Spacer(),
                Text(change,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 30),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  barGroups: List.generate(data.length,
                      (index) => _barData(index, data[index], barColor)),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          List<String> labels = [
                            "00",
                            "04",
                            "08",
                            "12",
                            "14",
                            "16",
                            "18"
                          ];
                          return Text(labels[value.toInt()],
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]));
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _barData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }
}
