import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speedydrop/Constants/constants.dart';
import 'package:speedydrop/Models/User/user.dart';


class Auth_Service {
  //creating and authentication instance for user
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //creating a user object on firebase user
  Current_User? _userFromFirebaseUser(User? user) {
    return user != null ? Current_User(uid: user.uid) : null;
  }

  //Sign up using Email and Password
  Future signUpWithEmailAndPassword(String email, String password) async {
    try {
      //Split email address at @
      List<String> parts = email.split('@');
      String name = 'name';
      //check if there are two parts (username@domian)
      if (parts.length == 2) {
        //name is before @
        name = parts[0];
      }
      // firebase class for authentication and unique id of the user
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      // Create a new record of user in database
      // ---------------

      return _userFromFirebaseUser(user);
    } catch (e) {
      log('Error Signing Up User: $e');
      var errorMessage = e.toString().replaceAll(RegExp(r'\[.*?\]'), '');
      Global_error = errorMessage;
      return null;
    }
  }

  //Sign in using Email and Password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user!);
    } catch (e) {
      log('Error Signing In User: $e');
      var errorMessage = e.toString().replaceAll(RegExp(r'\[.*?\]'), '');
      Global_error = errorMessage;
      return null;
    }
  }

  // Digning Out Function
  Future signOut() async {
    try {
      return _auth.signOut();
    } catch(e) {
      log('Error signing out: $e');
      return null;
    }
  }

}