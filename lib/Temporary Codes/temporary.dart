// import 'dart:developer' as dev;
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:speedydrop/Screens/Account/user_account.dart';
// import 'package:speedydrop/Screens/Authentication/Sign%20In/signin.dart';
// import 'package:speedydrop/Screens/Home/homeSeller.dart';
// import 'package:speedydrop/Screens/Loading/loading.dart';
// import 'package:speedydrop/Screens/Products/All%20Products%20In%20Store/productsInStore.dart';
// import 'package:speedydrop/Services/Auth/auth.dart';
// import 'package:speedydrop/Services/Database/database.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// import '../Home/homeBuyer.dart';
//
//
// class CartScreen extends StatefulWidget {
//   const CartScreen({
//     Key? key,
//   }) : super(key: key);
//   @override
//   State<CartScreen> createState() => _CartScreenState();
// }
//
// class _CartScreenState extends State<CartScreen> {
//
//   //Variables
//   Color _orangeColor = Colors.orange.shade800;
//   final Auth_Service _auth_service = Auth_Service();
//   String _currentAddress = '';
//   String _profileImage = 'assets/images/speedyLogov1.png';
//   String profilePhoto = '';
//   String userId = '';
//   double latitude = 0.0;
//   double longitude = 0.0;
//   int popularStoreMinSales = 35;
//   late Map<int, Map<String, dynamic>> cartProducts;
//   late Map<int, Map<String, dynamic>> cartProductsSorted = {};
//   bool isLoading = true;
//   late List<bool> isChecked;
//   late List<bool> isDeleteButtonRed;
//
//   //Functions
//   @override
//   void initState() {
//     super.initState();
//     initializeData();
//   }
//
//   Future<void> _getCurrentLocation() async {
//     var permissionStatus = await Permission.location.status;
//     if (permissionStatus.isGranted) {
//       try {
//         Position position = await Geolocator.getCurrentPosition(
//             desiredAccuracy: LocationAccuracy.high);
//         latitude = position.latitude;
//         longitude = position.longitude;
//         List<Placemark> placemarks =
//         await placemarkFromCoordinates(position.latitude, position.longitude);
//         String address = placemarks.first.name ?? '';
//         setState(() {
//           _currentAddress = address;
//         });
//       } catch (e) {
//         print("Error: $e");
//       }
//     } else {
//       // If permission is not granted, request it
//       if (permissionStatus.isDenied || permissionStatus.isRestricted) {
//         await Permission.location.request();
//       }
//     }
//   }
//
//   Future<void> initializeData() async {
//     // Fetch cart products
//     cartProducts = await Database_Service(userId: _auth_service.getUserId())
//         .fetchAllProductDetailsOfCart();
//
//
//     Set<String> uniqueVendorIds = Set();
//
//     cartProducts.values.forEach((productMap) {
//       if (productMap.containsKey('vendor-id')) {
//         uniqueVendorIds.add(productMap['vendor-id']);
//       }
//     });
//
//     List<String> vendorIds = uniqueVendorIds.toList();
//     int k = 0;
//     for (int i = 0; i < vendorIds.length; i++) {
//       for (int j = 0; j < cartProducts.length; j++) {
//         if (cartProducts[j]?['vendor-id'] == vendorIds[i]) {
//           cartProductsSorted[k] = cartProducts[j]!;
//           k++;
//         }
//       }
//     }
//
//
//     isChecked = List.filled(cartProductsSorted.length, false);
//     isDeleteButtonRed =  List.filled(cartProductsSorted.length, false);
//
//     // Get current location
//     await _getCurrentLocation();
//
//     // Update UI state
//     setState(() {
//       isLoading = false;
//     });
//
//     print('Is Loading');
//     print(isLoading);
//   }
//
//
//   double calculateRadius(double currentLat, double currentLng, double targetLat,
//       double targetLng) {
//     const double earthRadius = 6371.0; // Earth's radius in kilometers
//
//     double dLat = degreesToRadians(targetLat - currentLat);
//     double dLng = degreesToRadians(targetLng - currentLng);
//
//     double a = sin(dLat / 2) * sin(dLat / 2) +
//         cos(degreesToRadians(currentLat)) * cos(degreesToRadians(targetLat)) *
//             sin(dLng / 2) * sin(dLng / 2);
//     double c = 2 * atan2(sqrt(a), sqrt(1 - a));
//     double distance = earthRadius * c;
//
//     return distance;
//   }
//
//   double degreesToRadians(double degrees) {
//     return degrees * pi / 180;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (isLoading == false) {
//       return Scaffold(
//
//         appBar: AppBar(
//           title: Row(
//             children: [
//               Icon(Icons.location_on_outlined, color: _orangeColor,),
//               const SizedBox(width: 5.0,),
//
//
//               Expanded(
//                 child: _currentAddress.isNotEmpty
//                     ? Text(
//                   _currentAddress,
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: Colors.black,
//                   ),
//                 )
//                     : const Text(
//                   'Fetching Your Current Location',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//
//               GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => const UserAccount()),
//                   );
//                 },
//                 child: profilePhoto == '' ? CircleAvatar(
//                   radius: 18,
//                   backgroundImage: AssetImage(_profileImage),
//                 ) : CircleAvatar(
//                   radius: 18,
//                   backgroundImage: NetworkImage(profilePhoto),
//                 ),
//               ),
//             ],
//           ),
//           leading: PopupMenuButton(
//             icon: const Icon(Icons.menu),
//             itemBuilder: (BuildContext context) =>
//             [
//
//               PopupMenuItem(
//                 value: 'buyer-mode',
//                 child: Row(
//                   children: [
//                     Icon(Icons.switch_account, color: _orangeColor,),
//                     const SizedBox(width: 10.0,),
//                     const Text('Home',
//                         style: TextStyle(fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//               ),
//
//               PopupMenuItem(
//                 value: 'logout',
//                 child: Row(
//                   children: [
//                     Icon(Icons.logout, color: _orangeColor,),
//                     const SizedBox(width: 10.0,),
//                     const Text('LogOut',
//                         style: TextStyle(fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//               ),
//             ],
//             onSelected: (String value) {
//               if (value == 'buyer-mode') {
//                 dev.log('buyer-mode');
//                 Navigator.pushReplacement(
//                     context, MaterialPageRoute(builder: (context) {
//                   return const HomeScreenBuyer();
//                 }));
//               } else if (value == 'logout') {
//                 dev.log('logout');
//                 _auth_service.signOut();
//                 Navigator.pushReplacement(
//                     context, MaterialPageRoute(builder: (context) {
//                   return const SignIn();
//                 }));
//               }
//               setState(() {
//                 _orangeColor = Colors.orange.shade800;
//               });
//             },
//
//           ),
//         ),
//
//         body: Container(
//             decoration: BoxDecoration(
//               color: Colors.grey.shade100,
//               borderRadius: BorderRadius.circular(20),
//               // Rounded corners
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.2),
//                   // Shadow color
//                   spreadRadius: 2,
//                   // Spread radius
//                   blurRadius: 5,
//                   // Blur radius
//                   offset: const Offset(0, 2), // Shadow position
//                 ),
//               ],
//             ),
//             margin: const EdgeInsets.symmetric(horizontal: 20.0),
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 10.0,),
//                     RichText(
//                       text: TextSpan(
//                         children: [
//                           TextSpan(
//                             text: 'Products',
//                             style: TextStyle(
//                                 color: _orangeColor,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 25.0
//                             ),
//                           ),
//                           const TextSpan(
//                             text: ' In Cart!',
//                             style: TextStyle(
//                                 fontSize: 20.0,
//                                 color: Colors.black
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 10.0,),
//                     const Center(
//                       child: Text('Select Products to Check Out!',
//                         style: TextStyle(fontWeight: FontWeight.bold),),
//                     ),
//                     const SizedBox(height: 10.0,),
//                     Expanded(
//                       child: ListView.builder(
//                           scrollDirection: Axis.vertical,
//                           itemCount: cartProductsSorted.length,
//                           itemBuilder: (context, index) {
//                             Map<String,
//                                 dynamic>? product = cartProductsSorted[index];
//
//
//                             String productId = product?['product-id'];
//                             String vendorId = product?['vendor-id'];
//                             String productName = product?['product-name'];
//                             String productDescription = product?['description'];
//                             double price = product?['price'];
//                             int productQuantity = product?['quantity'];
//                             bool availability = product?['availability'];
//                             List<String> productImages = List<
//                                 String>.from(product?['images']);
//                             int selectedQuantity = product?['selected-quantity'];
//
//
//                             // String userId = allStoreData.keys.elementAt(index);
//                             // Map<String, dynamic> userData = allStoreData[userId]!;
//                             // String ownerId = '';
//                             // ownerId = userData['owner-id'];
//                             // var storeName = userData['store-details']['store-name'];
//                             // var storeDesc = userData['store-details']['store-description'];
//                             // var selectedDays = List<String>.from(userData['store-details']['selectedDays']);
//                             // var openHours = userData['store-details']['openingHours'];
//                             // var closeHours = userData['store-details']['closingHours'];
//                             // var lat = userData['store-details']['address']['latitude'];
//                             // var long = userData['store-details']['address']['longitude'];
//                             // var contactNum = userData['store-details']['contact-number'];
//                             // var storeImgLink = userData['store-details']['store-image'];
//                             // var sales = userData['store-details']['sales'];
//
//                             // // Get the current date and time
//                             // DateTime now = DateTime.now();
//                             // String dayAbbreviation = DateFormat.E().format(now); // "E" gives the abbreviated day name
//                             // String formattedDay = dayAbbreviation.substring(0, 3); // Take the first three characters
//                             // bool isDaySelected = selectedDays.contains(formattedDay);
//                             // String formattedTime = DateFormat('h:mm a').format(now);
//                             // DateTime openTime = DateFormat('h:mm a').parse(openHours);
//                             // DateTime closeTime = DateFormat('h:mm a').parse(closeHours);
//                             // DateTime parsedTime = DateFormat('h:mm a').parse(formattedTime);
//                             // bool isOpen = ((parsedTime.isAfter(openTime) && parsedTime.isBefore(closeTime)) ||
//                             //     (parsedTime.isAtSameMomentAs(openTime) || parsedTime.isAtSameMomentAs(closeTime)));
//                             // bool isOpenTimeMidnight = openTime.hour == 0 && openTime.minute == 0 && openTime.second == 0;
//                             // bool isCloseTimeMidnight = closeTime.hour == 0 && closeTime.minute == 0 && closeTime.second == 0;
//                             // if (isOpenTimeMidnight && isCloseTimeMidnight) {
//                             //   isOpen = true;
//                             // }
//                             // double storeRadius = double.parse(calculateRadius(latitude, longitude, lat, long).toStringAsFixed(1));
//                             // double deliveryTime = storeRadius * 8;
//                             // if(deliveryTime < 30){
//                             //   deliveryTime = 30;
//                             // }
//
//                             if (index == 0 ||
//                                 (cartProductsSorted[index - 1]?['vendor-id'] ==
//                                     vendorId)) {
//                               return Column(
//                                 children: [
//                                   index == 0
//                                       ? Center(child: Text('Products In a Store'))
//                                       : Container(),
//                                   Container(
//                                     margin: const EdgeInsets.symmetric(
//                                         vertical: 5.0),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(
//                                           10),
//                                       // Rounded corners
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.grey.withOpacity(
//                                               0.2),
//                                           // Shadow color
//                                           spreadRadius: 2,
//                                           // Spread radius
//                                           blurRadius: 5,
//                                           // Blur radius
//                                           offset: const Offset(
//                                               0, 2), // Shadow position
//                                         ),
//                                       ],
//                                     ),
//                                     child:      GestureDetector(
//                                       onTap: () {
//                                         // Add your onTap functionality here
//
//                                       },
//                                       child: Container(
//                                         padding: EdgeInsets.all(12.0),
//                                         decoration: BoxDecoration(
//                                           border: Border.all(color: Colors.grey.shade300),
//                                           borderRadius: BorderRadius.circular(12.0),
//                                         ),
//                                         child: Row(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             ClipRRect(
//                                               borderRadius: BorderRadius.circular(8),
//                                               child: Image.network(
//                                                 productImages[0],
//                                                 fit: BoxFit.cover,
//                                                 width: 120,
//                                                 height: 120,
//                                               ),
//                                             ),
//                                             const SizedBox(width: 12.0),
//                                             Expanded(
//                                               child: Column(
//                                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                                 children: [
//                                                   Text(
//                                                     productName,
//                                                     maxLines: 2,
//                                                     overflow: TextOverflow.ellipsis,
//                                                     style: const TextStyle(
//                                                       fontSize: 16.0,
//                                                       color: Colors.black,
//                                                       fontWeight: FontWeight.w500,
//                                                     ),
//                                                   ),
//                                                   const SizedBox(height: 4.0),
//                                                   Text(
//                                                     productDescription,
//                                                     overflow: TextOverflow.ellipsis,
//                                                     maxLines: 2,
//                                                     style: const TextStyle(
//                                                       color: Colors.grey,
//                                                       fontSize: 14.0,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             Column(
//                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                               children: [
//
//                                                 Row(
//                                                   mainAxisSize: MainAxisSize.min,
//                                                   children: [
//                                                     Checkbox(
//                                                       value: isChecked[index],
//                                                       onChanged: (value) {
//                                                         setState(() {
//                                                           if(value == true) {
//                                                             isChecked[index] = true;
//                                                             if(isDeleteButtonRed[index] == true) {
//                                                               isDeleteButtonRed[index] = false;
//                                                             }
//                                                           } else {
//                                                             isChecked[index] = false;
//                                                           }
//                                                         });
//                                                       },
//                                                       activeColor: isChecked[index] ? _orangeColor : Colors.grey,
//                                                     ),
//
//
//                                                     SizedBox(width: 8.0),
//                                                     IconButton(
//                                                       onPressed: () {
//                                                         setState(() {
//                                                           if(isDeleteButtonRed[index] == true){
//                                                             isDeleteButtonRed[index] = false;
//                                                           } else {
//                                                             if(isChecked[index] == true) {
//                                                               isChecked[index] = false;
//                                                             }
//                                                             isDeleteButtonRed[index] = true;
//                                                           }
//
//                                                         });
//                                                       },
//                                                       icon: Icon(
//                                                         Icons.delete,
//                                                         color: isDeleteButtonRed[index] ? Colors.red : Colors.grey,
//                                                         size: 30.0,
//                                                       ),
//                                                     ),
//
//                                                   ],
//                                                 ),
//                                                 const SizedBox(height: 8.0),
//                                                 Text(
//                                                   'Qty: $selectedQuantity',
//                                                   style: const TextStyle(
//                                                     color: Colors.grey,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 ),
//                                                 SizedBox(height: 5.0),
//                                                 Row(
//                                                   mainAxisSize: MainAxisSize.min,
//                                                   children: [
//                                                     Text(
//                                                       '$price',
//                                                       style: TextStyle(
//                                                         color: Colors.black,
//                                                         fontWeight: FontWeight.bold,
//                                                       ),
//                                                     ),
//                                                     SizedBox(width: 4),
//                                                     Icon(
//                                                       Icons.currency_rupee,
//                                                       color: _orangeColor,
//                                                       size: 16,
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//
//                                   )
//
//                                 ],
//                               );
//                             } else {
//                               return Column(
//                                 children: [
//                                   Center(child: const Text('Products In a Store')),
//                                   Container(
//                                     margin: const EdgeInsets.symmetric(
//                                         vertical: 5.0),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(
//                                           10),
//                                       // Rounded corners
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.grey.withOpacity(
//                                               0.2),
//                                           // Shadow color
//                                           spreadRadius: 2,
//                                           // Spread radius
//                                           blurRadius: 5,
//                                           // Blur radius
//                                           offset: const Offset(
//                                               0, 2), // Shadow position
//                                         ),
//                                       ],
//                                     ),
//                                     child:      GestureDetector(
//                                       onTap: () {
//                                         // Add your onTap functionality here
//                                       },
//                                       child: Container(
//                                         padding: EdgeInsets.all(12.0),
//                                         decoration: BoxDecoration(
//                                           border: Border.all(color: Colors.grey.shade300),
//                                           borderRadius: BorderRadius.circular(12.0),
//                                         ),
//                                         child: Row(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             ClipRRect(
//                                               borderRadius: BorderRadius.circular(8),
//                                               child: Image.network(
//                                                 productImages[0],
//                                                 fit: BoxFit.cover,
//                                                 width: 120,
//                                                 height: 120,
//                                               ),
//                                             ),
//                                             const SizedBox(width: 12.0),
//                                             Expanded(
//                                               child: Column(
//                                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                                 children: [
//                                                   Text(
//                                                     productName,
//                                                     maxLines: 2,
//                                                     overflow: TextOverflow.ellipsis,
//                                                     style: const TextStyle(
//                                                       fontSize: 16.0,
//                                                       color: Colors.black,
//                                                       fontWeight: FontWeight.w500,
//                                                     ),
//                                                   ),
//                                                   const SizedBox(height: 4.0),
//                                                   Text(
//                                                     productDescription,
//                                                     overflow: TextOverflow.ellipsis,
//                                                     maxLines: 2,
//                                                     style: const TextStyle(
//                                                       color: Colors.grey,
//                                                       fontSize: 14.0,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             Column(
//                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                               children: [
//                                                 Row(
//                                                   mainAxisSize: MainAxisSize.min,
//                                                   children: [
//                                                     Checkbox(
//                                                       value: isChecked[index],
//                                                       onChanged: (value) {
//                                                         setState(() {
//                                                           if(value == true) {
//                                                             isChecked[index] = true;
//                                                             if(isDeleteButtonRed[index] == true) {
//                                                               isDeleteButtonRed[index] = false;
//                                                             }
//                                                           } else {
//                                                             isChecked[index] = false;
//                                                           }
//                                                         });
//                                                       },
//                                                       activeColor: isChecked[index] ? _orangeColor : Colors.grey,
//                                                     ),
//
//
//                                                     SizedBox(width: 8.0),
//                                                     IconButton(
//                                                       onPressed: () {
//                                                         setState(() {
//                                                           if(isDeleteButtonRed[index] == true){
//                                                             isDeleteButtonRed[index] = false;
//                                                           } else {
//                                                             if(isChecked[index] == true) {
//                                                               isChecked[index] = false;
//                                                             }
//                                                             isDeleteButtonRed[index] = true;
//                                                           }
//
//                                                         });
//                                                       },
//                                                       icon: Icon(
//                                                         Icons.delete,
//                                                         color: isDeleteButtonRed[index] ? Colors.red : Colors.grey,
//                                                         size: 30.0,
//                                                       ),
//                                                     ),
//
//                                                   ],
//                                                 ),
//                                                 const SizedBox(height: 8.0),
//                                                 Text(
//                                                   'Qty: $selectedQuantity',
//                                                   style: const TextStyle(
//                                                     color: Colors.grey,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 ),
//                                                 SizedBox(height: 5.0),
//                                                 Row(
//                                                   mainAxisSize: MainAxisSize.min,
//                                                   children: [
//                                                     Text(
//                                                       '$price',
//                                                       style: TextStyle(
//                                                         color: Colors.black,
//                                                         fontWeight: FontWeight.bold,
//                                                       ),
//                                                     ),
//                                                     SizedBox(width: 4),
//                                                     Icon(
//                                                       Icons.currency_rupee,
//                                                       color: _orangeColor,
//                                                       size: 16,
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//
//                                   )
//                                 ],
//                               );
//                             }
//                           }
//
//                       ),
//                     ),
//
//
//                   ]
//               ),
//             )
//         ),
//       );
//     } else {
//       return const Loading_Screen();
//     }
//   }
// }