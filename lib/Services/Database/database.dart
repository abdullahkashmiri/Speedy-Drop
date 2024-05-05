import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' as Path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../Constants/constants.dart';

class Database_Service {
  final String userId;
  Database_Service({required this.userId});
  // Collection Reference
  // accounts
  final CollectionReference accountsCollection = FirebaseFirestore.instance.collection('Accounts');
  // Store for products
  final CollectionReference storeCollection = FirebaseFirestore.instance.collection('Store');
  // Job for delivery Jobs
  final CollectionReference jobCollection = FirebaseFirestore.instance.collection('Job');
  // Firebase Storage for images
  FirebaseStorage storage = FirebaseStorage.instance;

  // Functions

  Future<bool> initializeUserDataOnCloud(String userId, String userName, String email, String password,) async {
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

  Future<bool> isUserARider() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Accounts').doc(userId).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<
            String,
            dynamic>;
        dynamic isRider = data['isRider'];
        if (isRider == true) {
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

  Future<bool> createSellerMode(String storeName, String storeDescription, List<String> selectedDays, String openingHours, String closingHours, LatLng storeLocation,
      String contactNumber, File storeImage) async {
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

  Future<bool> createRiderMode() async {
    try {
      await accountsCollection.doc(userId).update({
        'isRider': true,
      });
      return true;
    } catch (e) {
      log('Error Occurred while creating rider mode : $e');
      return false; // Return false if an error occurs
    }
  }

  Future<bool> createNewProduct(List<File> images, String productName, String description, double price, int quantity, String category) async {
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

  Future<List<String>> uploadImagesOfProduct(List<File> images, String uniqueProductId) async {
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

  Future<Map<String, dynamic>?> fetchAllUserData() async {
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

  Future<String> uploadProfilePhotoOfUser(File image) async {
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

  Future<bool> updateUserData(String userName, String phoneNumber, LatLng markerLocation, String profileImage,) async {
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

  Future<Map<String, dynamic>> fetchAllStoresData() async {
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

  Future<bool> uploadDataInCartOfAnotherProduct(String productId, String vendorId, String category, int selectedQuantity) async {
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

  Future<List<Map<String, dynamic>>> fetchCartData() async {
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

  Future<Map<int, Map<String, dynamic>>> fetchAllProductsOfCartAndTheirDetailsFromRespectiveStores() async {
    try {
      List<Map<String,
          dynamic>> cartData = await fetchCartData();
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

  Future<bool> updateProductDetailsOfCartToMakeAnOrder(Map<int, Map<String, dynamic>> cartProducts, Map<int, Map<String, dynamic>> orderProducts, int deliveryCharges, int totalCharges,
      int deliveryTime, String storeName, String storeImageLink, String vendorId, LatLng customerLocation, LatLng storeLocation) async {
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
            await cartCollection.doc(docId).delete();
          }
        }
      }

      bool isOrderCreated = await uploadDataToCreateAnOrder(
          orderProducts, deliveryCharges, totalCharges, deliveryTime,
          storeName, storeImageLink, vendorId, customerLocation, storeLocation);

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

  Future<bool> uploadDataToCreateAnOrder(Map<int, Map<String, dynamic>> orderProducts, int deliveryCharges, int totalCharges, int deliveryTime, String storeName,
      String storeImageLink, String vendorId, LatLng customerLocation, LatLng storeLocation) async {
    try {
      // Reference to the user's cart collection
      final CollectionReference orderCollection = accountsCollection
          .doc(userId) // Assuming userId is accessible
          .collection('Order');

      List<Map<String, dynamic>> confirmOrder = [];

      for (int i = 0; i < orderProducts.length; i++) {
        confirmOrder.add(orderProducts[i]!);
      }

      List<Map<String, dynamic>> products = [];

      for (int i = 0; i < orderProducts.length; i++) {
        String productId = orderProducts[i]?['product-id'];
        String productName = orderProducts[i]?['product-name'];
        String vendorId = orderProducts[i]?['vendor-id'];
        int selectedQuantity = orderProducts[i]?['selected-quantity'];
        String category = orderProducts[i]?['category'];
        Map<String, dynamic> product = {
          'productName' : productName,
          'selectedQuantity' : selectedQuantity,
        };
        products.add(product);
        if (await updateProductQuantityOnOrderCreation(
            vendorId, category, productId, selectedQuantity) == false) {
          print("Unable to update quantity");
          return false;
        }
      }

      DateTime now = DateTime.now();
      String formattedDate = DateFormat('dd/MM/yyyy hh:mm a').format(now);
      DocumentReference orderDoc = orderCollection.doc();
      String docId = orderDoc.id;
      // Combine all data into a single map
      Map<String, dynamic> orderData = {
        'orderProducts': confirmOrder,
        'deliveryCharges': deliveryCharges.toInt(),
        'totalCharges': totalCharges.toInt(),
        'deliveryTime': deliveryTime.toInt(),
        'storeName': storeName,
        'storeImageLink': storeImageLink,
        'orderCreationTime': formattedDate,
        'currentStage': 'placed',
        'storeLocation': {
          'latitude': storeLocation.latitude,
          'longitude': storeLocation.longitude,
        },
        'customerLocation': {
          'latitude': customerLocation.latitude,
          'longitude': customerLocation.longitude,
        },
      };

      // placed, delivering, delivered.

      // Add the map to the Firestore collection
      await orderCollection.doc(docId).set(orderData);
      await makeDeliveryJobForOrder(storeLocation, customerLocation, products, deliveryCharges,
          totalCharges, storeName, deliveryTime, formattedDate, storeImageLink, docId);
      await incrementStoreSalesOnOrderCreation(vendorId);
      // Data uploaded successfully
      return true;
    } catch (error) {
      // Error occurred while uploading data
      print('Error uploading data to Firestore: $error');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllOrdersOfUser() async {
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

  Future<void> deleteProductOfSeller(String category, String uniqueProductId) async {
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

  Future<void> incrementStoreSalesOnOrderCreation(String vendorUserId) async {
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

  Future<bool> updateProductQuantityOnOrderCreation(String vendorId, String category, String uniqueProductId, int selectedQuantity) async {
    try {
      // Fetch current quantity of the product
      DocumentSnapshot productSnapshot = await storeCollection.doc(vendorId).collection(category).doc(uniqueProductId).get();
      int currentQuantity = productSnapshot.exists ? productSnapshot['quantity'] ?? 0 : 0;
      int newQuantity = currentQuantity - selectedQuantity;

      if(newQuantity>=0) {
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

  Future<LatLng?> fetchUserProfileLocation() async {
    try {
      Map<String, dynamic>? userData = await getUserData();

      if (userData != null && userData.containsKey('address')) {
        double latitude = userData['address']['latitude'];
        double longitude = userData['address']['longitude'];
        return LatLng(latitude, longitude);
      } else {
        return null; // Return null if user data or address is missing
      }
    } catch (e) {
      print('Error fetching user profile location: $e');
      return null; // Return null if an error occurs
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('Accounts').doc(userId).get();

      if (userSnapshot.exists) {
        return userSnapshot.data() as Map<String, dynamic>;
      } else {
        return null; // User document doesn't exist
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null; // Return null if an error occurs
    }
  }

  Future<bool> makeDeliveryJobForOrder(LatLng storeLocation, LatLng customerLocation, List<Map<String, dynamic>> productsDetails, int deliveryCharges, int totalCharges,
      String storeName, int deliveryTime, String creationTime, String storeImageLink, String orderId) async {
    try {
      DocumentReference newJobRef = jobCollection.doc();
      String jobId = newJobRef.id;
      await newJobRef.set({
        'customerId' : userId,
        'orderId' : orderId,
        'storeLocation': {
          'latitude': storeLocation.latitude,
          'longitude': storeLocation.longitude,
        },
        'customerLocation': {
          'latitude': customerLocation.latitude,
          'longitude': customerLocation.longitude,
        },
        'productsName': productsDetails,
        'deliveryCharges': deliveryCharges,
        'totalCharges': totalCharges,
        'storeName': storeName,
        'deliveryTime': deliveryTime,
        'creationTime': creationTime,
        'storeImageLink': storeImageLink,
        'currentStage': 'placed',
        'rider' : '',
        'jobId' : jobId,
        'deliveryStartTime' : ''
      });

      return true; // Job creation successful
    } catch (e) {
      print('Error creating job: $e');
      return false; // Job creation failed
    }

  }

  Future<List<Map<String, dynamic>>> fetchAllJobs() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Job').get();


      List<Map<String, dynamic>> jobs = snapshot.docs.map((doc) {
        Map<String, dynamic> jobData = {
          'storeLocation': {
            'latitude': doc['storeLocation']['latitude'],
            'longitude': doc['storeLocation']['longitude'],
          },
          'customerLocation': {
            'latitude': doc['customerLocation']['latitude'],
            'longitude': doc['customerLocation']['longitude'],
          },
          'deliveryCharges': doc['deliveryCharges'],
          'totalCharges': doc['totalCharges'],
          'productsName': doc['productsName'],
          'storeName': doc['storeName'],
          'deliveryTime': doc['deliveryTime'],
          'customerId': doc['customerId'],
          'orderId':doc['orderId'],
          'creationTime': doc['creationTime'],
          'storeImageLink': doc['storeImageLink'],
          'currentStage': doc['currentStage'],
          'rider': doc['rider'],
          'jobId' : doc['jobId'],
          'deliveryStartTime' : doc['deliveryStartTime']
        };

        return jobData;
      }).toList();

      // Print the mapped jobs
      jobs.forEach((job) {
        print('Job: $job');
      });

      return jobs;
    } catch (e) {
      print('Error fetching jobs: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchNearbyAvailableJobs(Position riderPosition, double radius) async {
    try {
      // Calculate latitude range
      double latRange = radius / 111.12;

      // Calculate longitude range per degree of latitude
      double lonRange = radius / 111.12;

      // Calculate bounding box for adjacent locations
      double latMin = riderPosition.latitude - latRange;
      double latMax = riderPosition.latitude + latRange;
      double lonMin = riderPosition.longitude - lonRange;
      double lonMax = riderPosition.longitude + lonRange;


      // Query Firestore for jobs within the bounding box
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Job')
          .where('storeLocation.latitude', isGreaterThanOrEqualTo: latMin)
          .where('storeLocation.latitude', isLessThanOrEqualTo: latMax)
          .get();

      List<DocumentSnapshot> filteredDocs = snapshot.docs.where((doc) {
        double longitude = doc['storeLocation']['longitude'];
        String currentStage = doc['currentStage'];
        return longitude >= lonMin && longitude <= lonMax && currentStage == 'placed';
      }).toList();

      List<Map<String, dynamic>> nearByJobs = filteredDocs.map((doc) {
        Map<String, dynamic> jobData = {
          'storeLocation': {
            'latitude': doc['storeLocation']['latitude'],
            'longitude': doc['storeLocation']['longitude'],
          },
          'customerLocation': {
            'latitude': doc['customerLocation']['latitude'],
            'longitude': doc['customerLocation']['longitude'],
          },
          'productsName': doc['productsName'],
          'deliveryCharges': doc['deliveryCharges'],
          'totalCharges': doc['totalCharges'],
          'deliveryStartTime' : doc['deliveryStartTime'],
          'storeName': doc['storeName'],
          'deliveryTime': doc['deliveryTime'],
          'creationTime': doc['creationTime'],
          'storeImageLink': doc['storeImageLink'],
          'currentStage': doc['currentStage'],
          'customerId' : doc['customerId'],
          'orderId': doc['orderId'],
          'rider': doc['rider'],
          'jobId' : doc['jobId']
        };

        return jobData;
      }).toList();

      return nearByJobs;
    } catch (e) {
      // Handle exceptions here, you can log the error or return an empty list
      print('Error fetching nearby jobs: $e');
      return [];
    }
  }

  Future<bool> acceptRideJobAsRider(String jobId, String customerId, String orderId) async {
    try {
      // Fetch job details
      DocumentSnapshot jobSnapshot = await jobCollection.doc(jobId).get();

      DateTime now = DateTime.now();
      String formattedDate = DateFormat('dd/MM/yyyy hh:mm a').format(now);

      // Check if currentStage is "placed" and rider is empty
      if (jobSnapshot.exists &&
          (jobSnapshot.data() as Map<String, dynamic>)['currentStage'] == 'placed' &&
          (jobSnapshot.data() as Map<String, dynamic>)['rider'] == '') {
        // Update job document
        await jobCollection.doc(jobId).set(
          {
            'currentStage': 'delivering',
            'rider': userId,
            'deliveryStartTime' : formattedDate
          },
          SetOptions(merge: true), // Merge with existing data
        );

        // Update order document
        final CollectionReference orderCollection = accountsCollection.doc(customerId).collection('Order');
        await orderCollection.doc(orderId).set(
          {
            'currentStage': 'delivering',
          },
          SetOptions(merge: true),
        );

        // If the update operation succeeds, return true
        return true;
      } else {
        // If currentStage is not "placed" or rider is not empty, return false
        return false;
      }
    } catch (e) {
      // If an error occurs during the update operation, print the error and return false
      print('Error accepting ride job: $e');
      return false;
    }
  }

}