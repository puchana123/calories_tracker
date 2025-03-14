import 'package:flutter/material.dart';
import 'package:calories_tracker/models/user_model.dart';
import 'package:calories_tracker/services/firebase_service.dart';

class EditUserDetails extends StatefulWidget {
  final UserModel user;
  final FirebaseService firebaseService;

  const EditUserDetails(
      {super.key, required this.user, required this.firebaseService});

  @override
  State<EditUserDetails> createState() => _EditUserDetailsState();
}

class _EditUserDetailsState extends State<EditUserDetails> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _targetCalController;

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController(text: widget.user.age.toString());
    _weightController =
        TextEditingController(text: widget.user.weight.toString());
    _heightController =
        TextEditingController(text: widget.user.height.toString());
    _targetCalController =
        TextEditingController(text: widget.user.targetCal.toString());
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _targetCalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Edit User Details'),
        ),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Form(
                key: _formKey,
                child: Column(children: [
                  // Name
                  Row(
                    children: [
                      SizedBox(
                          width: 80,
                          child: Text(
                            "Name",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )),
                      SizedBox(width: 50),
                      Expanded(
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(widget.user.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                  )))),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Age
                  TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your age';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Height
                  TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(
                      labelText: 'Height (cm)',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your height';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Weight
                  TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your weight';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Target Calories
                  TextFormField(
                      controller: _targetCalController,
                      decoration: const InputDecoration(
                        labelText: 'Target Calories',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your target calories';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      }),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Update user details
                            UserModel updatedUser = UserModel(
                              uid: widget.user.uid,
                              email: widget.user.email,
                              name: widget.user.name,
                              age: int.parse(_ageController.text),
                              height: int.parse(_heightController.text),
                              weight: int.parse(_weightController.text),
                              targetCal: int.parse(_targetCalController.text),
                            );
                            // Update the database
                            await widget.firebaseService
                                .updateUserDetails(updatedUser);

                            if (mounted) {
                              Navigator.pop(context, updatedUser);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        )),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        )),
                  ),
                ]))));
  }
}
