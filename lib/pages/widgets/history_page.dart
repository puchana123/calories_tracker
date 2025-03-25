import 'package:calories_tracker/models/daily_calories_model.dart';
import 'package:calories_tracker/models/user_model.dart';
import 'package:calories_tracker/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HistoryPage extends StatefulWidget {
  final UserModel? user;
  final FirebaseService firebaseService;
  final Function() onCaloriesAdded;

  const HistoryPage({
    required Key key,
    required this.user,
    required this.firebaseService,
    required this.onCaloriesAdded,
  }) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<DailyCalories> _weeklyCalories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return; // Early exit if disposed
    try {
      if (widget.user == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _weeklyCalories = [];
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      DateTime today = DateTime.now();
      if (today.weekday == 1) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('landing_data_${widget.user!.uid}');
        // print("Cleared cache on landing page for UID: ${widget.user!.uid}");
      }

      // Try to load data from cache
      final cachedData = await _loadFromCache();
      if (cachedData != null && mounted) {
        setState(() {
          _weeklyCalories = cachedData;
          _isLoading = false;
        });
      }

      // Fetch weekly calories data from Firebase
      List<DailyCalories> weeklyCalories =
          await _fetchWeeklyCalories(widget.user!.uid);

      if (mounted) {
        setState(() {
          _weeklyCalories = weeklyCalories;
          _isLoading = false;
        });
      }

      // Save to cache
      await _saveToCache(weeklyCalories);
    } catch (e) {
      // print("Error fetching data: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _weeklyCalories = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error fetching data: $e"),
          ),
        );
      }
    }
  }

  Future<List<DailyCalories>> _fetchWeeklyCalories(String userId) async {
    try {
      DateTime today = DateTime.now();
      DateTime todayNormalize = DateTime(today.year, today.month, today.day);
      DateTime startOfWeek =
          todayNormalize.subtract(Duration(days: (today.weekday - 1) % 7));
      DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

      // print(
      //     "Fetching weekly calories for UID: $userId, $startOfWeek to $endOfWeek");

      List<DailyCalories> weeklyData = await widget.firebaseService
          .getWeeklyCalories(
              userId: userId, startOfWeek: startOfWeek, endOfWeek: endOfWeek);

      Map<DateTime, DailyCalories> dataMap = {
        for (var daily in weeklyData)
          DateTime(daily.date.year, daily.date.month, daily.date.day): daily
      };

      List<DailyCalories> completeWeek = [];
      for (int i = 0; i < 7; i++) {
        DateTime currentDate = startOfWeek.add(Duration(days: i));
        completeWeek.add(dataMap[currentDate] ??
            DailyCalories(date: currentDate, consumed: 0, burned: 0));
      }

      return completeWeek;
    } catch (e) {
      // print("Error fetching weekly calories: $e");
      return [];
    }
  }

  Future<void> _saveToCache(List<DailyCalories> data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = {
      'timestamp': DateTime.now().toIso8601String(),
      'data': data
          .map((e) => {
                'date': e.date.toIso8601String(),
                'consumed': e.consumed,
                'burned': e.burned,
                'id': e.id,
              })
          .toList(),
    };
    await prefs.setString(
        'weekly_calories_${widget.user!.uid}', jsonEncode(jsonData));
  }

  Future<List<DailyCalories>?> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString('weekly_calories_${widget.user!.uid}');
    if (cachedJson != null) {
      final jsonData = jsonDecode(cachedJson);
      final timestamp = DateTime.parse(jsonData['timestamp']);
      final data = jsonData['data'] as List<dynamic>;
      if (DateTime.now().difference(timestamp).inHours < 24) {
        return data
            .map((json) => DailyCalories(
                  id: json['id'],
                  date: DateTime.parse(json['date']),
                  consumed: json['consumed'],
                  burned: json['burned'],
                ))
            .toList();
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: _isLoading
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          "History",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 10),
                      Column(
                        children: [
                          _historyCard(
                            title: "Total Calories Consumed",
                            color: Colors.orange,
                            barColor: Colors.orange,
                            data: _weeklyCalories
                                .map((e) => e.consumed.toDouble())
                                .toList(),
                          ),
                          SizedBox(height: 10),
                          _historyCard(
                            title: "Total Calories Burned",
                            color: Colors.blue,
                            barColor: Colors.blue,
                            data: _weeklyCalories
                                .map((e) => e.burned.toDouble())
                                .toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _historyCard({
    required String title,
    required Color color,
    required Color barColor,
    required List<double> data,
  }) {
    final total = data.isNotEmpty ? data.reduce((a, b) => a + b) : 0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(total.toStringAsFixed(0),
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  SizedBox(width: 10),
                  Text("kcal",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: data.isEmpty
                  ? Center(child: Text("No data available"))
                  : BarChart(
                      BarChartData(
                        barGroups: _generateBarGroups(data, barColor),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: _getBottomTitles,
                          )),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData:
                            FlGridData(show: true, drawVerticalLine: false),
                        minY: 0,
                        maxY: _calculateMaxY(data),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    int index = value.toInt();
    if (index >= 0 && index < weekdays.length) {
      return SideTitleWidget(
          meta: meta,
          child: Text(
            weekdays[index],
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ));
    }
    return const SizedBox.shrink();
  }

  List<BarChartGroupData> _generateBarGroups(
      List<double> data, Color barColor) {
    if (data.isEmpty || _weeklyCalories.isEmpty) {
      // print("No data available");
      return [];
    }
    // const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final barGroups = List.generate(data.length, (index) {
      final value = data[index];
      // print(
      //     "$barColor chart - Day $index (${weekdays[index]}): Value = $value");
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color: barColor,
            width: 16,
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      );
    });
    return barGroups;
  }

  double _calculateMaxY(List<double> data) {
    if (data.isEmpty) {
      // print("No data for maxY calculation, defaulting to 1000");
      return 1000.0;
    }
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final maxY = (maxValue * 1.2).ceilToDouble();
    // print("Calculated maxY: $maxY (maxValue: $maxValue)");
    return maxY > 0 ? maxY : 1000.0;
  }
}
