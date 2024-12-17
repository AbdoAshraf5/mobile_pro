import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';

class SignInUpPage extends StatefulWidget {
  @override
  _SignInUpPageState createState() => _SignInUpPageState();
}

class _SignInUpPageState extends State<SignInUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailControllerSignIn = TextEditingController();
  final TextEditingController _passwordControllerSignIn =
      TextEditingController();

  final TextEditingController _emailControllerSignUp = TextEditingController();
  final TextEditingController _passwordControllerSignUp =
      TextEditingController();
  final TextEditingController _phoneControllerSignUp = TextEditingController();
  final TextEditingController _ageControllerSignUp = TextEditingController();
  final TextEditingController _genderControllerSignUp = TextEditingController();
  final TextEditingController _maritalStatusControllerSignUp =
      TextEditingController();

  bool _isSignIn = true;
  String? _errorMessage;
  bool _isAcceptedTerms = false;

  String? _selectedGender = 'Male';
  String? _selectedMaritalStatus = 'Single';

  void _toggleMode() {
    setState(() {
      _isSignIn = !_isSignIn;
      _errorMessage = null;
    });
  }

  // SignIn logic
  Future<void> _signIn() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailControllerSignIn.text.trim(),
        password: _passwordControllerSignIn.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    }
  }

  // SignUp logic
  Future<void> _signUp() async {
    try {
      int age = int.tryParse(_ageControllerSignUp.text) ?? 0;
      if (age < 18) {
        setState(() {
          _errorMessage = 'You must be at least 18 years old to sign up.';
        });
        return;
      }

      if (!_isAcceptedTerms) {
        setState(() {
          _errorMessage = 'You must accept the terms and conditions.';
        });
        return;
      }

      // Create User in Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailControllerSignUp.text.trim(),
        password: _passwordControllerSignUp.text.trim(),
      );

      // Add user details to Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'phone': _phoneControllerSignUp.text.trim(),
        'age': age,
        'gender': _selectedGender,
        'marital_status': _selectedMaritalStatus,
        'email': _emailControllerSignUp.text.trim(),
      });

      _toggleMode(); // Switch to SignIn after successful SignUp
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignIn ? 'Sign In' : 'Sign Up'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              if (_isSignIn)
                // SignIn Fields
                Column(
                  children: [
                    TextField(
                      controller: _emailControllerSignIn,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _passwordControllerSignIn,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _signIn,
                      child: Text('Sign In'),
                    ),
                    TextButton(
                      onPressed: _toggleMode,
                      child: Text('Don\'t have an account? Sign Up'),
                    ),
                  ],
                )
              else
                // SignUp Fields
                Column(
                  children: [
                    TextField(
                      controller: _emailControllerSignUp,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _passwordControllerSignUp,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _phoneControllerSignUp,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _ageControllerSignUp,
                      decoration: InputDecoration(
                        labelText: 'Age',
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    // Gender Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      items: ['Male', 'Female']
                          .map((gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Marital Status Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedMaritalStatus,
                      items: ['Single', 'Married']
                          .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMaritalStatus = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Marital Status',
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Terms and Conditions Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _isAcceptedTerms,
                          onChanged: (bool? value) {
                            setState(() {
                              _isAcceptedTerms = value!;
                            });
                          },
                        ),
                        Text('I accept the terms and conditions'),
                      ],
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _signUp,
                      child: Text('Sign Up'),
                    ),
                    TextButton(
                      onPressed: _toggleMode,
                      child: Text('Already have an account? Sign In'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
