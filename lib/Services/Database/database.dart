import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
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

  Future<bool> createSellerMode(String storeName, String storeDescription,
      List<String> selectedDays, String openingHours,
      String closingHours, LatLng storeLocation, String contactNumber,
      File storeImage) async {
    try {
      String ownerId = userId;
      int sales = 0;
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
          'sales': sales
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

  Future<bool> createNewProduct(List<File> images, String productName,
      String description, double price, int quantity, String category) async {
    try {
      String uniqueProductId = const Uuid().v4();
      List<String> imagesUrls = await uploadImagesOfProduct(
          images, uniqueProductId); // Upload images and get URLs
      if (imagesUrls.isNotEmpty) {
        await storeCollection.doc(userId).collection(category).doc(
            uniqueProductId).set({
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

  Future<List<Map<String, dynamic>>> fetchAllProductsOfSeller() async {
    List<Map<String, dynamic>> allProducts = [];

    try {
      for (String category in categories) {
        // Fetch all documents within the current category subcollection
        QuerySnapshot querySnapshot = await storeCollection.doc(userId)
            .collection(category)
            .get();

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
        Map<String, dynamic>? userData = snapshot.data() as Map<String,
            dynamic>?;
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

  Future<bool> updateUserDataOnCloud(String userName, String phoneNumber,
      LatLng markerLocation, String profileImage,) async {
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
        return doc['phone-number'];
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  }

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
        Map<String, dynamic>? storeData = snapshot.data() as Map<String,
            dynamic>?;
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
        return doc['profileImage'];
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  }

  Future<Map<String, dynamic>> fetchAllStoreData() async {
    try {
      QuerySnapshot<Object?> snapshot = await storeCollection.get();

      Map<String, dynamic> allStoreData = {};

      for (DocumentSnapshot<Object?> doc in snapshot.docs) {
        if (doc.exists) {
          // Convert the snapshot data to a map
          Map<String, dynamic>? userData = doc.data() as Map<String, dynamic>?;

          // Add the user data to the map using user ID as the key
          if (userData != null) {
            String userId = doc.id;
            allStoreData[userId] = userData;
          }
        }
      }

      return allStoreData;
    } catch (e) {
      // Error occurred while fetching store data
      print('Error occurred while fetching store data: $e');
      return {};
    }
  }

  Future<bool> uploadDataInCartOnCloud(String productId, String vendorId,
      String category, int selectedQuantity) async {
    try {
      // Reference to the user's cart collection
      final CollectionReference cartCollection = accountsCollection.doc(userId)
          .collection('Cart');

      // Create a map containing the values
      Map<String, dynamic> cartItem = {
        'productId': productId,
        'vendorId': vendorId,
        'category': category,
        'selectedQuantity': selectedQuantity,
      };

      // Add the map to the Firestore collection
      await cartCollection.add(cartItem);

      // Data uploaded successfully
      return true;
    } catch (error) {
      // Error occurred while uploading data
      print('Error uploading data to Firestore: $error');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchCartDataFromCloud() async {
    try {
      // Reference to the user's cart collection
      final CollectionReference cartCollection = accountsCollection.doc(userId)
          .collection('Cart');

      // Get all documents from the cart collection
      QuerySnapshot querySnapshot = await cartCollection.get();

      // Convert documents to a list of maps
      List<Map<String, dynamic>> cartData = querySnapshot.docs.map((doc) =>
      doc.data() as Map<String, dynamic>)
          .toList();

      return cartData;
    } catch (error) {
      // Error occurred while fetching data
      print('Error fetching data from Firestore: $error');
      return [];
    }
  }

  Future<Map<int, Map<String, dynamic>>> fetchAllProductDetailsOfCart() async {
    try {
      List<Map<String,
          dynamic>> cartData = await fetchCartDataFromCloud();
      Map<int, Map<String, dynamic>> cartProducts = {};

      int index = 0;
      for (var item in cartData) {
        final String productId = item['productId'];
        final String vendorId = item['vendorId'];
        final String category = item['category'];
        final int selectedQuantity = item['selectedQuantity'];

        DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
            .collection('Store')
            .doc(vendorId)
            .collection(category)
            .doc(productId)
            .get();

        if (productSnapshot.exists) {
          Map<String, dynamic> productData = productSnapshot.data() as Map<
              String,
              dynamic>;

          cartProducts[index] = {
            'product-id': productId,
            'vendor-id': vendorId,
            'product-name': productData['product-name'],
            'description': productData['description'],
            'price': productData['price'],
            'quantity': productData['quantity'],
            'availability': productData['availability'],
            'images': List<String>.from(productData['images']),
            'selected-quantity': selectedQuantity,
            'category' : category
          };
          index++;
        }
      }

      return cartProducts;
    } catch (error) {
      print('Error fetching or processing cart data: $error');
      return {}; // Returning an empty map as a default value
    }
  }

  Future<bool> updateProductDetailsOfCart(
      Map<int, Map<String, dynamic>> cartProducts,
      Map<int, Map<String, dynamic>> orderProducts, int deliveryCharges,
      int totalCharges, int deliveryTime, String storeName,
      String storeImageLink, String vendorId) async {
    try {
      final CollectionReference cartCollection = accountsCollection
          .doc(userId)
          .collection('Cart');

      // Get all documents from the cart collection
      QuerySnapshot querySnapshot = await cartCollection.get();

      // Iterate through each document in the cart collection
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        // Get the product ID of the current document
        String productId = doc['productId'];
        String docId = doc.id;
        print('Product id: $productId');
        // Check if the product ID is in the cartProducts map
        for (int i = 0; i < cartProducts.length; i++) {
          if (cartProducts[i]?['product-id'] == productId) {
            print('found product');
            await cartCollection.doc(docId).delete();
          }
        }
      }

      bool isOrderCreated = await uploadDataInOrderOnCloud(
          orderProducts,
          deliveryCharges,
          totalCharges,
          deliveryTime,
          storeName,
          storeImageLink,
          vendorId);
      if (isOrderCreated) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      print('Error in processing cart data: $error');
      return false;
    }
  }

  Future<bool> uploadDataInOrderOnCloud(
      Map<int, Map<String, dynamic>> orderProducts, int deliveryCharges,
      int totalCharges, int deliveryTime, String storeName,
      String storeImageLink, String vendorId) async {
    try {
      // Reference to the user's cart collection
      final CollectionReference orderCollection = accountsCollection
          .doc(userId) // Assuming userId is accessible
          .collection('Order');

      List<Map<String, dynamic>> confirmOrder = [];


      for (int i = 0; i < orderProducts.length; i++) {
        confirmOrder.add(orderProducts[i]!);
      }

      for (int i = 0; i < orderProducts.length; i++) {
        String productId = orderProducts[i]?['product-id'];
        String vendorId = orderProducts[i]?['vendor-id'];
        int selectedQuantity = orderProducts[i]?['selected-quantity'];
        String category = orderProducts[i]?['category'];
        if(await updateProductQuantity(vendorId, category, productId, selectedQuantity)==false){
          print("Unable to update quantity");
          return false;
        }
      }
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('dd/MM/yyyy hh:mm a').format(now);
      // Combine all data into a single map
      Map<String, dynamic> orderData = {
        'orderProducts': confirmOrder,
        'deliveryCharges': deliveryCharges.toInt(),
        'totalCharges': totalCharges.toInt(),
        'deliveryTime': deliveryTime.toInt(),
        'storeName': storeName,
        'storeImageLink': storeImageLink,
        'orderCreationTime': formattedDate,
        'currentStage': 'placed'
      };

      // placed, delivering, delivered.

      // Add the map to the Firestore collection
      await orderCollection.add(orderData);
      await incrementStoreSales(vendorId);
      // Data uploaded successfully
      return true;
    } catch (error) {
      // Error occurred while uploading data
      print('Error uploading data to Firestore: $error');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchOrdersFromCloud() async {
    try {
      // Reference to the user's Order collection
      final CollectionReference orderCollection = accountsCollection
          .doc(userId) // Assuming userId is accessible
          .collection('Order');

      // Retrieve documents from the Order collection
      QuerySnapshot querySnapshot = await orderCollection.get();
      int i = 0;
      List<Map<String, dynamic>> allOrders = [];

      querySnapshot.docs.forEach((doc) {
        String orderId = doc.id; // Using document ID as string
        Map<String, dynamic> orderData = doc.data() as Map<String, dynamic>;
        allOrders.add(orderData);
        i++;
      });
      return allOrders;
    } catch (error) {
      // Error occurred while fetching data
      print('Error fetching data from Firestore: $error');
      return [];
    }
  }

  Future<void> deleteProduct(String category, String uniqueProductId) async {
    try {
      await storeCollection
          .doc(userId)
          .collection(category)
          .doc(uniqueProductId)
          .delete();
      print("Product deleted successfully.");
    } catch (error) {
      print("Error deleting product: $error");
    }
  }

  Future<void> incrementStoreSales(String vendorUserId) async {
    try {
      // Fetch the document snapshot
      DocumentSnapshot<Map<String, dynamic>> snapshot = await storeCollection
          .doc(vendorUserId).get() as DocumentSnapshot<Map<String, dynamic>>;

      if (snapshot.exists) {
        // Access the data from the snapshot
        Map<String, dynamic> storeData = snapshot.data()!;

        // Get the current sales value
        int currentSales = storeData['store-details']['sales'] ?? 0;

        // Increment sales by 1
        int updatedSales = currentSales + 1;

        // Update the sales value in Firestore
        await storeCollection.doc(vendorUserId).update({
          'store-details.sales': updatedSales,
        });
      } else {
        print('Document does not exist.');
      }
    } catch (e) {
      print('Error incrementing store sales: $e');
    }
  }

  Future<bool> updateProductQuantity(String vendorId, String category, String uniqueProductId, int selectedQuantity) async {
    try {
      // Fetch current quantity of the product
      DocumentSnapshot productSnapshot = await storeCollection.doc(vendorId).collection(category).doc(uniqueProductId).get();
      int currentQuantity = productSnapshot.exists ? productSnapshot['quantity'] ?? 0 : 0;
      int newQuantity = currentQuantity - selectedQuantity;

      if(newQuantity>0) {
        // Update quantity in Firestore
        await storeCollection.doc(vendorId).collection(category).doc(
            uniqueProductId).set({
          'quantity': newQuantity,
        }, SetOptions(
            merge: true)); // Merge option updates only the specified fields without overwriting others
      } else {
        return false;
      }
      // Return true if update successful
      return true;
    } catch (error) {
      // Return false if there's an error
      print("Error updating quantity: $error");
      return false;
    }
  }

}