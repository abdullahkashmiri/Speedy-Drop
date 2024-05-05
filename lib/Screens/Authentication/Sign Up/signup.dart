import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:speedydrop/Constants/constants.dart';
import 'package:speedydrop/Screens/Loading/loading.dart';
import 'package:speedydrop/Services/Auth/auth.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  // Variables
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  final Auth_Service _auth_service = Auth_Service();
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _error = '';
  final Color _orangeColor = Colors.orange.shade800;
  bool _isSigningUp = false;

  //Functions
  @override
  Widget build(BuildContext context) {
    if (_isSigningUp == false) {
      return Scaffold(
        backgroundColor: Colors.orange.shade50,
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Form(
                child: Column(
                  children: [
                    const SizedBox(height: 70.0,),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 70.0),
                      child: Image.asset('assets/images/speedyLogov1.png'),
                    ),
                    const SizedBox(height: 30.0,),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                          hintText: 'your_email@ext.com',
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email, color: _orangeColor,),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100.0),
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 2.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100.0),
                            borderSide: BorderSide(
                                color: _orangeColor, width: 2.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          labelStyle: TextStyle(color: Colors.grey.shade800,),
                          hintStyle: TextStyle(color: Colors.grey.withOpacity(
                              0.7),),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15.0)
                      ),
                      validator: (value) {
                        return value!.isEmpty ? 'Enter an email' : null;
                      },
                    ),
                    const SizedBox(height: 20.0,),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: Icon(Icons.lock, color: _orangeColor,),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white,
                            width: 2.0,),
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: _orangeColor,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        labelStyle: TextStyle(
                          color: Colors.grey.shade800,
                        ),
                        hintStyle: TextStyle(color: Colors.grey.withOpacity(
                            0.7),),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15.0),
                      ),
                      validator: (value) {
                        return value!.length < 6
                            ? 'Enter a password at least 6 characters long'
                            : null;
                      },
                      obscuringCharacter: '*',
                      obscureText: true,
                    ),
                    const SizedBox(height: 20.0,),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Confirm your password',
                        prefixIcon: Icon(Icons.lock, color: _orangeColor,),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: const BorderSide(color: Colors.white,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: _orangeColor,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(
                          color: Colors.grey.shade800,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey.withOpacity(0.7),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15.0),
                      ),
                      validator: (value) {
                        return value!.length < 6
                            ? 'Enter a password at least 6 character long'
                            : null;
                      },
                      obscureText: true,
                      obscuringCharacter: '*',
                    ),
                    const SizedBox(height: 10.0,),
                    Text(_error,
                      style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 10.0,),
                    ElevatedButton(
                      onPressed: () async {
                        _email = _emailController.text.trim();
                        _password = _passwordController.text.trim();
                        _confirmPassword =
                            _confirmPasswordController.text.trim();
                        if (_email == '' || _password == '' ||
                            _confirmPassword == '') {
                          log('Enter all values');
                          setState(() {
                            _error = 'Fill all fields';
                          });
                        } else {
                          if (_password != _confirmPassword) {
                            log('Password and Confirm Password do no match');
                            setState(() {
                              _error = 'Passwords do not match';
                            });
                          } else {
                            setState(() {
                              _error = '';
                              _isSigningUp = true;
                            });
                            // signing up with email and password.
                            dynamic result = await _auth_service
                                .signUpWithEmailAndPassword(_email, _password);
                            setState(() {
                              _isSigningUp = false;
                            });
                            if (result == null) {
                              setState(() {
                                _error = Global_error;
                                Global_error = '';
                              });
                            } else {
                              setState(() {
                                _error = '';
                              });
                              _emailController.clear();
                              _passwordController.clear();
                              _confirmPasswordController.clear();
                              Navigator.pop(context);
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 80.0),
                        primary: _orangeColor,
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35.0),
                        ),
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0,),
                    TextButton(
                      onPressed: () async {
                        setState(() {
                          _isSigningUp = true;
                        });
                        // Introduce 1 secs delay before moving to next screen
                        await Future.delayed(const Duration(milliseconds: 500));
                        Navigator.pop(context);
                        setState(() {
                          _isSigningUp = false;
                          _error = '';
                        });
                        _emailController.clear();
                        _passwordController.clear();
                        _confirmPasswordController.clear();
                      },
                      child: Text('Already have an account? Login',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.50,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40.0,),
                    Text('Speedy delivery, satisfaction assured!',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 15.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return const Loading_Screen();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }
}