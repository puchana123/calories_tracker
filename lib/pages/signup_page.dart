import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:calories_tracker/services/firebase_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formkey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  // Text editing controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  bool _termsAccepted = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Sign Up New User"),
        ),
        body: Stack(children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/login_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formkey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Sign Up",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(height: 20),
                      _buildEmailField(),
                      _buildNameField(),
                      _buildPasswordTextField(),
                      _buildConfirmPasswordTextField(),
                      _buildAgeField(),
                      Row(
                        children: [
                          Expanded(
                              child:
                                  _buildNumberField("Weight", "Weight in kg")),
                          SizedBox(width: 10),
                          Expanded(
                              child:
                                  _buildNumberField("Height", "Height in cm")),
                        ],
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: CheckboxListTile(
                          title: Text("I agree to the terms and conditions."),
                          value: _termsAccepted,
                          onChanged: (value) {
                            setState(() {
                              _termsAccepted = value!;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      if (!_termsAccepted &&
                          _formkey.currentState?.validate() == true)
                        Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              "Please accept the terms and conditions.",
                              style: TextStyle(color: Colors.red),
                            )),
                      ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  if (_formkey.currentState!.validate() &&
                                      _termsAccepted) {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    // Sign up new user
                                    await _signUpUser();
                                    if (mounted) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  color: Colors.black,
                                )
                              : Text("Sign Up",
                                  style: TextStyle(color: Colors.white))),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]));
  }

  // Function to sign up a new user
  Future<void> _signUpUser() async {
    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String name = _nameController.text.trim();
      int age = int.parse(_ageController.text.trim());
      int weight = int.parse(_weightController.text.trim());
      int height = int.parse(_heightController.text.trim());

      await _firebaseService.signUp(email, password, name, age, weight, height);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Sign Up Successful! Please sign in to continue."),
          duration: Duration(seconds: 3),
        ));
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _showError("Error during sign up", e.message ?? "An error occurred");
      }
    } catch (e) {
      if (mounted) {
        _showError("Error during sign up", "Error occurred: $e");
      }
    }
  }

  Widget _buildEmailField() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: _emailController,
        decoration: InputDecoration(
            labelText: "Email",
            hintText: "Enter your email",
            border: OutlineInputBorder()),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email';
          }
          // Regular expression for validating email format
          String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
          RegExp regex = RegExp(pattern);
          if (!regex.hasMatch(value)) {
            return 'Please enter a valid email address';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildNameField() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: _nameController,
        decoration: InputDecoration(
            labelText: "Name",
            hintText: "Enter your name",
            border: OutlineInputBorder()),
        validator: (value) => value!.isEmpty ? "Please enter your name" : null,
      ),
    );
  }

  Widget _buildPasswordTextField() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: _passwordController,
        obscureText: true,
        decoration: InputDecoration(
          labelText: "Password",
          hintText: "Enter your password",
          border: OutlineInputBorder(),
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          if (value.length < 6) {
            return 'Password must be at least 6 characters long';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildConfirmPasswordTextField() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        obscureText: true,
        decoration: InputDecoration(
          labelText: "Confirm Password",
          hintText: "Confirm your password",
          border: OutlineInputBorder(),
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) =>
            value != _passwordController.text ? 'Passwords do not match' : null,
      ),
    );
  }

  Widget _buildAgeField() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: _ageController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: "Age",
          hintText: "Enter your age",
          border: OutlineInputBorder(),
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          int? age = int.tryParse(value);
          if (age == null || age < 1 || age > 150) {
            return 'Age must be between 1 and 150';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildNumberField(String label, String hint) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: label == "Weight" ? _weightController : _heightController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(),
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your $label.toLowerCase()';
          }
          final num = int.tryParse(value);
          if (num == null) {
            return 'Please enter a valid number';
          }
          if (label == "Weight" && (num < 20 || num > 500)) {
            return 'Weight must be between 20 and 500 kg';
          }
          if (label == "Height" && (num < 50 || num > 300)) {
            return 'Height must be between 50 and 300 cm';
          }
          return null;
        },
      ),
    );
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
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        });
  }
}
