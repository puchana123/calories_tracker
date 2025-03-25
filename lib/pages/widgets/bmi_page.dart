import 'package:calories_tracker/models/user_model.dart';
import 'package:calories_tracker/pages/widgets/edit_user_details.dart';
import 'package:calories_tracker/services/firebase_service.dart';
import 'package:flutter/material.dart';

// BMI Page
class BMIPage extends StatefulWidget {
  final UserModel? user;
  final FirebaseService firebaseService;
  final Function(UserModel)? onUserUpdated;

  const BMIPage(
      {super.key,
      required this.user,
      required this.firebaseService,
      this.onUserUpdated});

  @override
  State<BMIPage> createState() => _BMIPageState();
}

class _BMIPageState extends State<BMIPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) {
      return Scaffold(
        body: Center(
            child: Text(
          "User not found",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
        )),
      );
    }

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
                  "BMI Calculator",
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

                // Update Details Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true;
                            });
                            final updatedUser = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditUserDetails(
                                    user: widget.user!,
                                    firebaseService: widget.firebaseService),
                              ),
                            );
                            if(mounted){
                              setState(() {
                                _isLoading = false;
                              });
                            }
                            if (updatedUser != null) {
                              // Show snackbar
                              if (mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                      "User details updated successfully!"),
                                  duration: Duration(seconds: 3),
                                ));
                                widget.onUserUpdated?.call(updatedUser);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            color: Colors.black,
                          )
                        : Text(
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
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true;
                            });
                            try {
                              await widget.firebaseService.signOut();
                              if (mounted) {
                                Navigator.pushNamedAndRemoveUntil(context, '/',
                                    (Route<dynamic> route) => false);
                              }
                            } catch (e) {
                              // print("Error signing out: $e");
                              _showError("Sign Out Error",
                                  "There was an error signing you out.");
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            color: Colors.black,
                          )
                        : Text(
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
    String bmiStatus = "Unknown";
    Color bmiColor = Colors.grey;

    if (weight > 0 && height > 0) {
      bmi = double.parse(
          (weight / ((height / 100) * (height / 100))).toStringAsFixed(1));
      if (bmi < 18.5) {
        bmiStatus = "Underweight";
        bmiColor = Colors.yellow;
      } else if (bmi >= 18.5 && bmi < 24.9) {
        bmiStatus = "Normal";
        bmiColor = Colors.green;
      } else if (bmi >= 25 && bmi < 29.9) {
        bmiStatus = "Overweight";
        bmiColor = Colors.orange;
      } else if (bmi >= 30) {
        bmiStatus = "Obese";
        bmiColor = Colors.red;
      }
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // BMI Calculator
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                  color: bmiColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ]),
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
        ListTile(
          title: Text(title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          trailing: Text(
            value,
            style: TextStyle(fontSize: 18),
          ),
        ),
        Divider(
          color: Colors.grey[300],
          height: 1,
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
