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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Sign Up New User"),
        ),
        body: Stack(children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/login_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(horizontal: 30),
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
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formkey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Sign Up",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(height: 20),
                      _buildEmailField(),
                      _buildNameField(),
                      _buildPasswordTextField(),
                      _buildConfirmPasswordTextField(),
                      _buildAgeField(),
                      // Input fields 2 columns
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
                      ElevatedButton(
                          onPressed: () async {
                            if (_formkey.currentState!.validate() &&
                                _termsAccepted) {
                              // Sign up new user
                              await _signUpUser();
                            } else if (!_termsAccepted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                    "Please accept the terms and conditions."),
                              ));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text("Sign Up",
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

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Sign Up Successful"),
      ));
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      _showError("Error during sign up", e.message ?? "An error occurred");
    } catch (e) {
      _showError("Error during sign up", "Error occurred: $e");
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
          if (age == null || age < 0 || age > 150) {
            return 'Age must be between 0 and 150';
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
            return 'Please enter some text';
          }
          if (int.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }

  void _showError(String title, String message) {
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: (){
              Navigator.of(context).pop();
            },
            child: Text("OK"),
          ),
        ],
      );
    });
  }
}
