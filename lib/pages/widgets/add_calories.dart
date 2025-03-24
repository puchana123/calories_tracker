import 'package:calories_tracker/models/daily_calories_model.dart';
import 'package:calories_tracker/services/firebase_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddCalories extends StatefulWidget {
  final DailyCalories dailyCalories;
  final String userId;
  final FirebaseService firebaseService;
  final Function() onCaloriesAdded;

  const AddCalories({
    super.key,
    required this.dailyCalories,
    required this.userId,
    required this.firebaseService,
    required this.onCaloriesAdded,
  });

  @override
  State<AddCalories> createState() => _AddCaloriesState();
}

class _AddCaloriesState extends State<AddCalories> {
  final _caloriesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _selectedSegment = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _addCalories() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final calories = int.parse(_caloriesController.text);
        DailyCalories updatedDailyCalories = DailyCalories(
          id: widget.dailyCalories.id,
          date: widget.dailyCalories.date,
          consumed: widget.dailyCalories.consumed,
          burned: widget.dailyCalories.burned,
        );
        if (_selectedSegment == 0) {
          updatedDailyCalories.consumed += calories;
        } else {
          updatedDailyCalories.burned += calories;
        }

        await widget.firebaseService
            .updateDailyCalories(widget.userId, updatedDailyCalories);

        widget.onCaloriesAdded();
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to add calories: $e'),
          ));
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Calories'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Segment button
                CupertinoSlidingSegmentedControl(
                  groupValue: _selectedSegment,
                  onValueChanged: (value) {
                    if (value != null && mounted) {
                      setState(() {
                        _selectedSegment = value;
                      });
                    }
                  },
                  backgroundColor: Colors.grey[300]!,
                  thumbColor:
                      _selectedSegment == 0 ? Colors.orange : Colors.green,
                  children: const <int, Widget>{
                    0: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          'Consumed',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                    1: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          'Burned',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      hintText:
                          "Enter ${_selectedSegment == 0 ? 'Consumed' : 'Burned'} Calories",
                      labelText:
                          "${_selectedSegment == 0 ? 'Consumed' : 'Burned'} Calories",
                      border: OutlineInputBorder()),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter calories';
                    }
                    final calories = int.tryParse(value);
                    if (calories == null) {
                      return 'Please enter a valid number';
                    }
                    if (calories <= 0) {
                      return 'Calories must be greater than 0';
                    }
                    if (calories > 10000) {
                      return 'Calories cannot exceed 10,000';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading || widget.userId.isEmpty
                        ? null
                        : _addCalories,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _selectedSegment == 0 ? Colors.orange : Colors.green,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.black,
                          )
                        : const Text(
                            'Add Calories',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                )
              ],
            )),
      ),
    );
  }
}
