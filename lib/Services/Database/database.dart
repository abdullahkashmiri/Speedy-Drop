import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class Database_Service {
  final String userId;

  Database_Service({required this.userId});

  // Collection Reference
  final CollectionReference accountsCollection = FirebaseFirestore.instance
      .collection('Accounts');


  // Functions

  // Initialize user data on the cloud used when user account is created.
  Future<bool> initializeUserDataOnCloud(String userId, String userName,
      String email, String password) async {
    try {
      await accountsCollection.doc(userId).set({
        'user-id': userId,
        'user-name': userName,
        'email': email,
        'password': password,
        'phone-number': '',
        'address': '',
        'isBuyer': true,
        'isSeller': false,
        'isRider': false,
      });
      return true; // Return true if the operation succeeds
    } catch (e) {
      log('Error Occurred while updating user data on cloud : $e');
      return false; // Return false if an error occurs
    }
  }

  // Checking is seller mode exists.
  Future<bool> isUserASeller() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('Accounts').doc(userId).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        dynamic isSeller = data['isSeller'];
        if (isSeller == true) {
          return true;
        } else {
          return false;
        }
      } else {
        // Document doesn't exist, user is not a seller
        return false;
      }
    } catch (e) {
      log('Error Occurred while checking if seller mode exists: $e');
      return false;
    }
  }

  // Creating seller mode
  Future<bool> createSellerMode() async {
    try {
      await accountsCollection.doc(userId).update({
        'isSeller' : true,
      });
      return true;
    } catch(e) {
      log('Error Occurred while creating seller mode : $e');
      return false; // Return false if an error occurs
    }
  }

}