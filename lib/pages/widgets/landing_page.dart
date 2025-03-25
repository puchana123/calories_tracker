import 'package:calories_tracker/models/daily_calories_model.dart';
import 'package:calories_tracker/models/user_model.dart';
import 'package:calories_tracker/pages/widgets/add_calories.dart';
import 'package:calories_tracker/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Landing Page
class LandingPage extends StatefulWidget {
  final UserModel? user;
  final FirebaseService firebaseService;
  final Function()? onCaloriesAdded;

  LandingPage({
    super.key,
    required this.user,
    required this.firebaseService,
    Function()? onCaloriesAdded,
  }) : onCaloriesAdded = onCaloriesAdded ?? (() {});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  DailyCalories? _dailyCalories;
  bool _isLoading = true;
  List<DailyCalories> _weeklyCalories = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Update daily calories
  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    if (widget.user == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    DateTime today = DateTime.now();
    DateTime todayNormalize = DateTime(today.year, today.month, today.day);

    if (today.weekday == 1) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('landing_data_${widget.user!.uid}');
      // print("Cleared cache on landing page for UID: ${widget.user!.uid}");
    }

    // Try to load data from cache
    final cachedData = await _loadFromCache();
    if (cachedData != null) {
      if (mounted) {
        setState(() {
          _dailyCalories = cachedData['daily'];
          _weeklyCalories = cachedData['weekly'];
          _isLoading = false;
        });
      }
      // print("Loaded from cache: ${_dailyCalories?.id}");
    }

    DailyCalories? dailyCalories = await widget.firebaseService
        .getDailyCalories(widget.user!.uid, todayNormalize);
    if (dailyCalories == null) {
      dailyCalories =
          DailyCalories(date: todayNormalize, consumed: 0, burned: 0);
      dailyCalories = await widget.firebaseService
          .addDailyCalories(widget.user!.uid, dailyCalories);
      // print("Created new dailyCalories: ${dailyCalories.id}");
    } else {
      // print("Fetched existing dailyCalories: ${dailyCalories.id}");
    }

    // Fetch Weekly data
    List<DailyCalories> weeklyData =
        await _fetchWeeklyCalories(widget.user!.uid);

    if (mounted) {
      setState(() {
        _dailyCalories = dailyCalories;
        _weeklyCalories = weeklyData;
        _isLoading = false;
      });
    }

    await _saveToCache(dailyCalories, weeklyData);
  }

  Future<Map<String, dynamic>?> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('landing_data_${widget.user!.uid}');
    if (cachedData != null) {
      final jsonData = jsonDecode(cachedData);
      final timestamp = DateTime.parse(jsonData['timestamp']);
      if (DateTime.now().difference(timestamp).inHours < 24) {
        return {
          'daily': DailyCalories(
              id: jsonData['daily']['id'],
              date: DateTime.parse(jsonData['daily']['date']),
              consumed: jsonData['daily']['consumed'],
              burned: jsonData['daily']['burned']),
          'weekly': (jsonData['weekly'] as List)
              .map((json) => DailyCalories(
                    id: json['id'],
                    date: DateTime.parse(json['date']),
                    consumed: json['consumed'],
                    burned: json['burned'],
                  ))
              .toList(),
        };
      }
    }
    return null;
  }

  Future<void> _saveToCache(
      DailyCalories daily, List<DailyCalories> weekly) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = {
      'timestamp': DateTime.now().toIso8601String(),
      'daily': {
        'id': daily.id,
        'date': daily.date.toIso8601String(),
        'consumed': daily.consumed,
        'burned': daily.burned,
      },
      'weekly': weekly.map((daily) {
        return {
          'id': daily.id,
          'date': daily.date.toIso8601String(),
          'consumed': daily.consumed,
          'burned': daily.burned,
        };
      }).toList(),
    };
    await prefs.setString(
        'landing_data_${widget.user!.uid}', jsonEncode(jsonData));
  }

  // Fetch weekly calories data
  Future<List<DailyCalories>> _fetchWeeklyCalories(String userId) async {
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

    int todayIndex =
        completeWeek.indexWhere((d) => d.date.isAtSameMomentAs(todayNormalize));
    if (todayIndex != -1 && _dailyCalories != null) {
      completeWeek[todayIndex] = _dailyCalories!;
      // print(
      //     "Updated today (index $todayIndex) with consumed: ${_dailyCalories!.consumed}");
    }
    return completeWeek;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LinearProgressIndicator(),
                    SizedBox(height: 10),
                    Text("Loading..."),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _fetchData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          "Today",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Calories Left Card
                      _caloriesLeftCard(),
                      const SizedBox(height: 10),

                      // Consume & Burned Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _infoCard(
                                "Consumed",
                                "${_dailyCalories?.consumed ?? 0} kcal",
                                Icons.fastfood,
                                Colors.orange),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _infoCard(
                                "Burned",
                                "${_dailyCalories?.burned ?? 0} kcal",
                                Icons.local_fire_department,
                                Colors.blue),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
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
                                "Total Calories Consumed This Week",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              )),
                              SizedBox(height: 20),
                              // BarChart
                              SizedBox(
                                height: 180,
                                child: _weeklyCalories.isEmpty
                                    ? const Center(
                                        child: Text("No data available"))
                                    : BarChart(BarChartData(
                                        barGroups: _generateBarGroups(),
                                        borderData: FlBorderData(show: false),
                                        titlesData: FlTitlesData(
                                          show: true,
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 30,
                                              getTitlesWidget: _getBottomTitles,
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          topTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          rightTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                        ),
                                        gridData: FlGridData(
                                            show: true,
                                            drawVerticalLine: false),
                                        minY: 0,
                                        maxY: _calculateMaxY(),
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
                            if (_dailyCalories == null || widget.user == null) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                    "Error: ${_dailyCalories == null ? 'Daily calories' : 'User'} not loaded yet."),
                              ));
                              _fetchData();
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddCalories(
                                            dailyCalories: _dailyCalories!,
                                            userId: widget.user!.uid,
                                            firebaseService:
                                                widget.firebaseService,
                                            onCaloriesAdded: () {
                                              _fetchData();
                                              widget.onCaloriesAdded!();
                                            },
                                          )));
                            }
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
      ),
    );
  }

  // Calories Left Card
  Widget _caloriesLeftCard() {
    int targetCal = widget.user?.targetCal ?? 0;
    int consumed = _dailyCalories?.consumed ?? 0;
    int burned = _dailyCalories?.burned ?? 0;
    int caloriesLeft = targetCal - consumed + burned;
    double progress = targetCal > 0
        ? (caloriesLeft / (targetCal + burned)).clamp(0.0, 1.0)
        : 0.0;

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
              color: progress <= 0.25
                  ? Colors.red
                  : progress <= 0.5
                      ? Colors.orange
                      : Colors.green,
              minHeight: 10,
            ),
            SizedBox(height: 10),
            Text(
              "$caloriesLeft/${targetCal + burned} kcal",
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
  List<BarChartGroupData> _generateBarGroups() {
    if (_weeklyCalories.isEmpty) {
      // print("No weekly data available");
      return [];
    }
    // const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final barGroups = List.generate(_weeklyCalories.length, (index) {
      final consumed = _weeklyCalories[index].consumed.toDouble();
      // print("Day $index (${weekdays[index]}): Consumed = $consumed");

      return BarChartGroupData(x: index, barRods: [
        BarChartRodData(
            toY: consumed,
            color: Colors.orange,
            width: 16,
            borderRadius: BorderRadius.circular(8))
      ]);
    });

    return barGroups;
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    int index = value.toInt();
    if (index >= 0 && index < weekdays.length) {
      return SideTitleWidget(
          meta: meta,
          child: Text(weekdays[index],
              style: TextStyle(fontSize: 12, color: Colors.grey)));
    }
    return const SizedBox.shrink();
  }

  double _calculateMaxY() {
    if (_weeklyCalories.isEmpty) {
      // print("No data for maxY calculation, defaulting to 1000");
      return 1000.0;
    }
    final maxConsumed =
        _weeklyCalories.map((e) => e.consumed).reduce((a, b) => a > b ? a : b);
    final maxY = (maxConsumed * 1.2).ceilToDouble();
    // print("Calculated maxY: $maxY (maxConsumed: $maxConsumed)");
    return maxY > 0 ? maxY : 1000.0;
  }
}
