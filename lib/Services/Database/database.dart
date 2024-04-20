import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:latlong2/latlong.dart';
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


  Future<bool> initializeUserDataOnCloud(String userId, String userName,
      String email, String password,) async {
    try {
      LatLng defaultLocation = LatLng(0.0, 0.0);

      await accountsCollection.doc(userId).set({
        'user-id': userId,
        'user-name': userName,
        'email': email,
        'password': password,
        'phone-number': '',
        'address': {
          'latitude': defaultLocation.latitude,
          'longitude': defaultLocation.longitude,
        },
        'isBuyer': true,
        'isSeller': false,
        'isRider': false,
        'profileImage': ''
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
  Future<bool> createSellerMode(String storeName, String storeDescription,
      List<String> selectedDays, String openingHours, String closingHours, LatLng storeLocation,
      String contactNumber, File storeImage) async {
    try {
      String ownerId = userId;
      String storeImageLink = await uploadStoreImage(storeImage);
      await storeCollection.doc(userId).set({
        'owner-id': ownerId,
        'store-details': {
          'store-name': storeName,
          'store-description': storeDescription,
          'selectedDays': selectedDays,
          'openingHours': openingHours,
          'closingHours': closingHours,
          'address': {
            'latitude': storeLocation.latitude,
            'longitude': storeLocation.longitude,
          },
          'contact-number': contactNumber,
          'store-image': storeImageLink,
        },
      }, SetOptions(merge: true));

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

  Future<Map<String, dynamic>?> fetchUserDataFromCloud() async {
    try {
      print('Fetching user data from cloud');
      // Get the document snapshot from Firestore
      DocumentSnapshot<Object?> snapshot =
      await accountsCollection.doc(userId).get();

      if (snapshot.exists) {
        // Convert the snapshot data to a map
        Map<String, dynamic>? userData = snapshot.data() as Map<String, dynamic>?;
        return userData;
      } else {
        // Document doesn't exist
        log('User document not found in Firestore');
        return null;
      }
    } catch (e) {
      // Error occurred while fetching user data
      log('Error occurred while fetching user data: $e');
      return null;
    }
  }


  // Upload images of product
  Future<String> uploadProfileImage(File image) async {
    String downloadUrl = '';
    try {
      File imageFile = image;
      String fileName = Path.basename(imageFile.path);
      Reference imageReference = FirebaseStorage.instance.ref().child(
          'profile/$userId/$fileName');
      UploadTask uploadTask = imageReference.putFile(imageFile);
      await uploadTask;
      if (uploadTask.snapshot.state == TaskState.success) {
        downloadUrl = await imageReference.getDownloadURL();
      } else {
        log('Failed to upload image ');
      }
    } catch (e) {
      log('Error uploading images: $e');
    }
    return downloadUrl;
  }



  Future<bool> updateUserDataOnCloud(String userName, String phoneNumber, LatLng markerLocation, String profileImage,
      ) async {
    try {
      await accountsCollection.doc(userId).update({
        'user-name': userName,
        'phone-number': phoneNumber,
        'address': {
          'latitude': markerLocation.latitude,
          'longitude': markerLocation.longitude,
        },
        'profileImage': profileImage,
      });
      return true; // Return true if the operation succeeds
    } catch (e) {
      log('Error Occurred while updating user data on cloud : $e');
      return false; // Return false if an error occurs
    }
  }

  Future<String> getPhoneNumberOfUser() async {
    try {
      DocumentSnapshot doc = await accountsCollection.doc(userId).get();
      // Check if the phone number exists in the document
      if (doc.exists && doc['phone-number'] != '') {
        return  doc['phone-number'];
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  }


  // Upload images of product
  Future<String> uploadStoreImage(File image) async {
    String downloadUrl = '';
    try {
      File imageFile = image;
      String fileName = Path.basename(imageFile.path);
      Reference imageReference = FirebaseStorage.instance.ref().child(
          'store/$userId/$fileName');
      UploadTask uploadTask = imageReference.putFile(imageFile);
      await uploadTask;
      if (uploadTask.snapshot.state == TaskState.success) {
        downloadUrl = await imageReference.getDownloadURL();
      } else {
        log('Failed to upload image ');
      }
    } catch (e) {
      log('Error uploading images: $e');
    }
    return downloadUrl;
  }



  Future<Map<String, dynamic>?> fetchStoreData() async {
    try {
      DocumentSnapshot<Object?> snapshot =
      await storeCollection.doc(userId).get();

      if (snapshot.exists) {
        // Convert the snapshot data to a map
        Map<String, dynamic>? storeData = snapshot.data() as Map<String, dynamic>?;
        return storeData;
      } else {
        // Document doesn't exist
        print('Store document not found in Firestore');
        return null;
      }
    } catch (e) {
      // Error occurred while fetching store data
      print('Error occurred while fetching store data: $e');
      return null;
    }
  }




  Future<String> fetchUserProfilePhoto() async {
    try {
      DocumentSnapshot doc = await accountsCollection.doc(userId).get();
      // Check if the phone number exists in the document
      if (doc.exists && doc['profileImage'] != '') {
        return  doc['profileImage'];
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  }


}