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

  @override
  void dispose() {
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Calories'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(50),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Segment button
                Container(
                  decoration: BoxDecoration(
                      color:
                          _selectedSegment == 0 ? Colors.orange : Colors.green,
                      borderRadius: BorderRadius.circular(10)),
                  child: CupertinoSlidingSegmentedControl(
                    groupValue: _selectedSegment,
                    onValueChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedSegment = value;
                        });
                      }
                    },
                    children: const <int, Widget>{
                      0: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('Consumed')),
                      1: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('Burned')),
                    },
                  ),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter calories';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final calories = int.parse(_caloriesController.text);
                        DailyCalories updatedDailyCalories = DailyCalories(
                            date: widget.dailyCalories.date,
                            consumed: widget.dailyCalories.consumed,
                            burned: widget.dailyCalories.burned);

                        if (_selectedSegment == 0) {
                          updatedDailyCalories.consumed += calories;
                        } else {
                          updatedDailyCalories.burned += calories;
                        }

                        await widget.firebaseService.addDailyCalories(
                            widget.userId,
                            updatedDailyCalories..id = widget.dailyCalories.id);

                        widget.onCaloriesAdded();
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    style: _selectedSegment == 0
                        ? ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          )
                        : ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                    child: const Text(
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
