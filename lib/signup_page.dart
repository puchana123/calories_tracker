import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  bool _termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up New User"),),
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
                  // Input fields 1 rows
                  _buildTextField(
                      "Name",
                      "Enter your name",
                      (value) =>
                          value!.isEmpty ? "Please enter your name" : null),
                  _buildTextField(
                      "Username",
                      "Enter your username",
                      (value) => value!.isEmpty
                          ? "Please enter your username"
                          : null),
                  _buildPasswordTextField("Password", _passwordController),
                  _buildConfirmPasswordTextField("Confirm Password"),
                  _buildAgeField("Age", "Enter your age"),
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
                      onPressed: () {
                        if (_formkey.currentState!.validate() &&
                            _termsAccepted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(
                            content: Text("Sign Up Successful"),
                          ));
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

  Widget _buildTextField(
      String label, String hint, String? Function(String?)? validator) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        decoration: InputDecoration(
            labelText: label, hintText: hint, border: OutlineInputBorder()),
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordTextField(
      String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
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

  Widget _buildConfirmPasswordTextField(String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) =>
            value != _passwordController.text ? 'Passwords do not match' : null,
      ),
    );
  }

  Widget _buildAgeField(String label, String hint) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
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
}
