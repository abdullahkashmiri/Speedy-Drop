import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../Constants/constants.dart';

class Database_Service {
  final String userId;

  Database_Service({required this.userId});

  // -------------------------------------------------------------------------------------------------

  // Collection Reference
  // accounts
  final CollectionReference accountsCollection = FirebaseFirestore.instance
      .collection('Accounts');

  // products
  final CollectionReference storeCollection = FirebaseFirestore.instance
      .collection('Store');


  // Firebase Storage
  FirebaseStorage storage = FirebaseStorage.instance;

  // -------------------------------------------------------------------------------------------------
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
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Accounts').doc(userId).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<
            String,
            dynamic>;
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
        'isSeller': true,
      });
      return true;
    } catch (e) {
      log('Error Occurred while creating seller mode : $e');
      return false; // Return false if an error occurs
    }
  }

  // Creating a new product
  Future<bool> createNewProduct(List<File> images, String productName,
      String description, double price, int quantity, String category) async {
    try {
      String uniqueProductId = const Uuid().v4();
      List<String> imagesUrls = await uploadImagesOfProduct(
          images, uniqueProductId); // Upload images and get URLs
      if (imagesUrls.isNotEmpty) {
        await storeCollection.doc(userId).collection(category).add({
          'product-id': uniqueProductId,
          'vendor-id': userId,
          'product-name': productName,
          'description': description,
          'price': price,
          'quantity': quantity,
          'availability': true,
          'images': imagesUrls,
        });
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log('Unable to create a product : $e');
      return false;
    }
  }

  // Upload images of product
  Future<List<String>> uploadImagesOfProduct(List<File> images,
      String uniqueProductId) async {
    List<String> downloadUrls = [];
    try {
      if (images.isEmpty) {
        log('No images provided for upload.');
        return downloadUrls;
      }
      for (int i = 0; i < images.length; i++) {
        File imageFile = images[i];
        String fileName = Path.basename(imageFile.path);
        Reference imageReference = FirebaseStorage.instance.ref().child(
            'products/$userId/$uniqueProductId/$fileName');
        UploadTask uploadTask = imageReference.putFile(imageFile);
        await uploadTask;
        if (uploadTask.snapshot.state == TaskState.success) {
          String downloadUrl = await imageReference.getDownloadURL();
          downloadUrls.add(downloadUrl);
        } else {
          log('Failed to upload image $i. State: ${uploadTask.snapshot.state}');
        }
      }
    } catch (e) {
      log('Error uploading images: $e');
    }
    return downloadUrls;
  }






  // Fetching all products of a seller
  Future<List<Map<String, dynamic>>> fetchAllProductsOfSeller() async {
    List<Map<String, dynamic>> allProducts = [];

    try {
      for (String category in categories) {
        // Fetch all documents within the current category subcollection
        QuerySnapshot querySnapshot = await storeCollection.doc(userId).collection(category).get();

        // Iterate over each document in the category subcollection
        for (QueryDocumentSnapshot doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          // Add document data as a product entry
          allProducts.add({
            'product-id': data['product-id'],
            'vendor-id': data['vendor-id'],
            'product-name': data['product-name'],
            'description': data['description'],
            'price': data['price'],
            'quantity': data['quantity'],
            'availability': data['availability'],
            'images': data['images'],
            'category': category, // Add the category to the product entry
          });
        }
      }
    } catch (e) {
      log("Error fetching products for user $userId: $e");
    }

    return allProducts;
  }





}