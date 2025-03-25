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
  bool _isLoading = false;

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

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      int newAge = int.parse(_ageController.text);
      int newWeight = int.parse(_weightController.text);
      int newHeight = int.parse(_heightController.text);
      int newTargetCal = int.parse(_targetCalController.text);

      // Create a new UserModel object with updated details
      UserModel updatedUser = UserModel(
        uid: widget.user.uid,
        email: widget.user.email,
        name: widget.user.name,
        age: newAge,
        weight: newWeight,
        height: newHeight,
        targetCal: newTargetCal,
      );

      // Update the user details in Firestor
      try {
        await widget.firebaseService.updateUserDetails(updatedUser);
        // Return updated user details to previous screen
        if (mounted) {
          Navigator.pop(context, updatedUser);
        }
      } catch (e) {
        // print("Error updating user details: $e");
        if (mounted) {
          _showError(
              "Update Error", "An error occurred while updating user details.");
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showError(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Edit User Details'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Center(
                          child: Text(
                            widget.user.name,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Age
                        TextFormField(
                          controller: _ageController,
                          decoration: const InputDecoration(
                              labelText: 'Age', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your age';
                            }
                            final age = int.tryParse(value);
                            if (age == null) {
                              return 'Please enter a valid number';
                            }
                            if (age < 1 || age > 150) {
                              return 'Age must be between 1 and 150';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),

                        // Height
                        TextFormField(
                          controller: _heightController,
                          decoration: const InputDecoration(
                              labelText: 'Height (cm)',
                              border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your height';
                            }
                            final height = int.tryParse(value);
                            if (height == null) {
                              return 'Please enter a valid number';
                            }
                            if (height < 50 || height > 300) {
                              return 'Height must be between 50 and 300 cm';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),

                        // Weight
                        TextFormField(
                          controller: _weightController,
                          decoration: const InputDecoration(
                              labelText: 'Weight (kg)',
                              border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your weight';
                            }
                            final weight = int.tryParse(value);
                            if (weight == null) {
                              return 'Please enter a valid number';
                            }
                            if (weight < 10 || weight > 500) {
                              return 'Weight must be between 10 and 500 kg';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),

                        // Target Calories
                        TextFormField(
                            controller: _targetCalController,
                            decoration: const InputDecoration(
                                labelText: 'Target Calories',
                                border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your target calories';
                              }
                              final targetCal = int.tryParse(value);
                              if (targetCal == null) {
                                return 'Please enter a valid number';
                              }
                              if (targetCal < 500 || targetCal > 10000) {
                                return 'Target calories must be between 500 and 10,000 kcal';
                              }
                              return null;
                            }),
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                              onPressed: _isLoading ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text(
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
                              onPressed: _isLoading
                                  ? null
                                  : () {
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
                      ]),
                ))));
  }
}
