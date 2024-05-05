// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'dart:developer' as dev;
// import '../../../Services/Auth/auth.dart';
// import '../../../Services/Database/database.dart';
// import '../../Account/user_account.dart';
// import '../../Authentication/Sign In/signin.dart';
// import '../../Home/Rider/homeRider.dart';
// import '../../Loading/loading.dart';
//
// class OnGoingJobScreen extends StatefulWidget {
//
//   const OnGoingJobScreen({super.key});
//
//   @override
//   State<OnGoingJobScreen> createState() => _OnGoingJobScreenState();
// }
//
// class _OnGoingJobScreenState extends State<OnGoingJobScreen> {
//
//
//   //Variables
//   String previousScreen = '';
//   Color _orangeColor = Colors.orange.shade800;
//   final Auth_Service _auth_service = Auth_Service();
//   final String _profileImage = 'assets/images/speedyLogov1.png';
//   bool isRider = true;
//   bool isLoading = true;
//   String _currentAddress = '';
//   late Map<String, dynamic> job;
//   String _error = '';
//
//   String ?ownerId;
//   String ?storeName;
//   String ?storeDescription;
//   List<String> ?selectedDays;
//   String ?openingHours;
//   String ?closingHours;
//   double ?latitude;
//   double ?longitude;
//   String ?contactNumber;
//   String ?locationName = 'Fetching Your Current Location';
//   String profilePhoto = '';
//   double areaRadius = 35; // in kilometers
//
//   late Map<String, dynamic> storeLocation;
//   late Map<String, dynamic> customerLocation;
//   late int deliveryCharges;
//   late int totalCharges;
//   late int deliveryTime;
//   late String creationTime;
//   late String deliveryCreationTime;
//   late String storeImageLink;
//   late String currentStage;
//   late String rider;
//   late double storeRadius;
//   late double rideRadius;
//   late String customerAddress;
//   late String storeAddress;
//   int storeMaxLines = 1;
//   int deliverMaxLines = 1;
//   late List<dynamic> productDetails;
//   late String jobId;
//   late String customerId;
//   late String orderId;
//   LatLng _initialLocation = LatLng(0, 0); // Initial location at (0, 0)
//   late LatLng customerLocationLatLng;
//   late LatLng storeLocationLatLng;
//
//   //Functions
//   @override
//   void initState() {
//     super.initState();
//     initializeData();
//   }
//
//   Future<void> _getCurrentLocation() async {
//     // Check if the location permission is granted
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
//
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
//   Future<String> getLocationAddress(double latitude, double longitude) async {
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//           latitude, longitude);
//       Placemark placemark = placemarks.first;
//
//       String address = placemark.name ?? '';
//       String city = placemark.locality ?? '';
//       String country = placemark.country ?? '';
//
//       return '$address, $city, $country';
//     } catch (e) {
//       return '';
//     }
//   }
//
//
//   Future<void> initializeData() async {
//     job = await Database_Service(userId: _auth_service.getUserId()).fetchRiderJobData();
//     await _getCurrentLocation();
//     storeLocation = {
//       'latitude': job['storeLocation']['latitude'],
//       'longitude': job['storeLocation']['longitude'],
//     };
//     customerLocation = {
//       'latitude': job['customerLocation']['latitude'],
//       'longitude': job['customerLocation']['longitude'],
//     };
//     deliveryCreationTime = job['deliveryStartTime'];
//     deliveryCharges = job['deliveryCharges'];
//     totalCharges = job['totalCharges'];
//     storeName = job['storeName'];
//     deliveryTime = job['deliveryTime'];
//     creationTime = job['creationTime'];
//     storeImageLink = job['storeImageLink'];
//     currentStage = job['currentStage'];
//     productDetails = job['productsName'];
//     customerId = job['customerId'];
//     orderId = job['orderId'];
//     rider = job['rider'];
//     storeRadius = double.parse(calculateRadius(
//         latitude!, longitude!, storeLocation['latitude'],
//         storeLocation['longitude']).toStringAsFixed(1));
//     rideRadius = double.parse(calculateRadius(
//         customerLocation['latitude'], customerLocation['longitude'],
//         storeLocation['latitude'], storeLocation['longitude']).toStringAsFixed(
//         1));
//     customerAddress = await getLocationAddress(
//         customerLocation['latitude'], customerLocation['longitude']);
//     storeAddress = await getLocationAddress(
//         storeLocation['latitude'], storeLocation['longitude']);
//     jobId = job['jobId'];
//     customerLocationLatLng = LatLng(customerLocation['latitude'], customerLocation['longitude']);
//     storeLocationLatLng = LatLng(storeLocation['latitude'], storeLocation['longitude']);
//     setState(() {
//       isLoading = false;
//     });
//   }
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
//               GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => const UserAccount()),
//                   );
//                 },
//                 child: profilePhoto == '' ?
//                 CircleAvatar(
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
//               PopupMenuItem(
//                 value: 'rider-mode',
//                 child: Row(
//                   children: [
//                     Icon(Icons.motorcycle_outlined,
//                       color: _orangeColor,),
//                     const SizedBox(width: 10.0,),
//                     const Text('Rider',
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
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
//               if (value == 'rider-mode') {
//                 dev.log('buyer-mode');
//                 Navigator.pushReplacement(
//                     context, MaterialPageRoute(builder: (context) {
//                   return const HomeScreenRider(previousScreen: 'homeBuyer');
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
//
//         body: Container(
//           margin: const EdgeInsets.only(
//               top: 0, bottom: 10.0, left: 20.0, right: 20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10.0),
//                   // Smooth edges
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.5),
//                       spreadRadius: 2,
//                       blurRadius: 5,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 padding: const EdgeInsets.all(10.0),
//                 // Add padding around the content
//                 child: Row(
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(10.0),
//                       child: Image.network(
//                         storeImageLink,
//                         height: 100, // Adjust image height as needed
//                         width: 100, // Adjust image width as needed
//                         fit: BoxFit.cover, // Cover the entire space
//                       ),
//                     ),
//                     const SizedBox(width: 16.0),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             storeName!,
//                             style: const TextStyle(
//                               fontSize: 16.0,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                             maxLines: 2,
//                           ),
//                           const SizedBox(height: 3.0),
//                           Row(
//                             children: [
//                               Icon(Icons.store, color: _orangeColor),
//                               const SizedBox(width: 2.0,),
//                               Text(
//                                 'Just $storeRadius Km Away',
//                                 style: const TextStyle(
//                                   fontSize: 12.0,
//                                   color: Colors.grey,
//                                 ),
//
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 3.0),
//                           Row(
//                             children: [
//                               Icon(Icons.motorcycle, color: _orangeColor),
//                               const SizedBox(width: 4.0,),
//                               Text(
//                                 'Est Delivery $deliveryTime mins',
//                                 style: const TextStyle(
//                                   fontSize: 12.0,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 3.0),
//                           Row(
//                             children: [
//                               Icon(Icons.map, color: _orangeColor),
//                               const SizedBox(width: 2.0,),
//                               Text(
//                                 'Just $rideRadius Km Del. Ride',
//                                 style: TextStyle(
//                                   fontSize: 12.0,
//                                   color: _orangeColor,
//                                 ),
//
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Center(
//                 child: Text(_error, style: const TextStyle(
//                     color: Colors.red, fontWeight: FontWeight.bold),),
//               ),
//               const Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 8.0),
//                 child: Text('Order Details',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 25.0,
//                     color: Colors.black,
//                   ),),
//               ),
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10.0),
//                   // Smooth edges
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.5),
//                       spreadRadius: 2,
//                       blurRadius: 5,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 padding: const EdgeInsets.all(15.0),
//                 child: Column(
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.location_pin, color: _orangeColor),
//                         const SizedBox(width: 5.0),
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () {
//                               if (storeMaxLines == 1) {
//                                 storeMaxLines = 2;
//                               } else {
//                                 storeMaxLines = 1;
//                               }
//                               setState(() {
//
//                               });
//                             },
//                             child: RichText(
//                               overflow: TextOverflow.ellipsis,
//                               maxLines: storeMaxLines,
//                               text: TextSpan(
//                                 children: [
//                                   const TextSpan(
//                                     text: 'Store Location: ',
//                                     style: TextStyle(
//                                       fontSize: 16.0,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                   TextSpan(
//                                     text: storeAddress,
//                                     style: TextStyle(
//                                         fontSize: 16.0,
//                                         color: _orangeColor,
//                                         fontWeight: FontWeight.bold
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                     const SizedBox(height: 2.0,),
//                     Row(
//                       children: [
//                         Icon(Icons.house, color: _orangeColor,),
//                         const SizedBox(width: 5.0,),
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () {
//                               if (deliverMaxLines == 1) {
//                                 deliverMaxLines = 2;
//                               } else {
//                                 deliverMaxLines = 1;
//                               }
//                               setState(() {
//
//                               });
//                             },
//                             child: RichText(
//                               overflow: TextOverflow.ellipsis,
//                               maxLines: deliverMaxLines,
//                               text: TextSpan(
//                                 children: [
//                                   const TextSpan(
//                                     text: 'Delivery Location: ',
//                                     style: TextStyle(
//                                       fontSize: 16.0,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                   TextSpan(
//                                     text: customerAddress,
//                                     style: TextStyle(
//                                         fontSize: 16.0,
//                                         color: _orangeColor,
//                                         fontWeight: FontWeight.bold
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 2.0,),
//                     Row(
//                       children: [
//                         Icon(Icons.point_of_sale, color: _orangeColor,),
//                         const SizedBox(width: 5.0,),
//                         RichText(
//                           text: TextSpan(
//                             children: [
//                               const TextSpan(
//                                 text: 'Delivery Charges: ',
//                                 style: TextStyle(
//                                   fontSize: 16.0,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                               TextSpan(
//                                 text: '$deliveryCharges',
//                                 style: TextStyle(
//                                     fontSize: 16.0,
//                                     color: _orangeColor,
//                                     fontWeight: FontWeight.bold
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 5.0,),
//                         Icon(Icons.currency_rupee, color: _orangeColor,),
//                       ],
//                     ),
//                     const SizedBox(height: 2.0,),
//                     Row(
//                       children: [
//                         Icon(Icons.point_of_sale, color: _orangeColor,),
//                         const SizedBox(width: 5.0,),
//                         RichText(
//                           text: TextSpan(
//                             children: [
//                               const TextSpan(
//                                 text: 'Total Charges: ',
//                                 style: TextStyle(
//                                   fontSize: 16.0,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                               TextSpan(
//                                 text: '$totalCharges',
//                                 style: TextStyle(
//                                     fontSize: 16.0,
//                                     color: _orangeColor,
//                                     fontWeight: FontWeight.bold
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 5.0,),
//                         Icon(Icons.currency_rupee, color: _orangeColor,),
//                       ],
//                     ),
//                     const SizedBox(height: 2.0,),
//                     Row(
//                       children: [
//                         Icon(Icons.calendar_month, color: _orangeColor,),
//                         const SizedBox(width: 5.0,),
//                         RichText(
//                           text: TextSpan(
//                             children: [
//                               const TextSpan(
//                                 text: 'Order: ',
//                                 style: TextStyle(
//                                   fontSize: 16.0,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                               TextSpan(
//                                 text: '$creationTime',
//                                 style: TextStyle(
//                                     fontSize: 16.0,
//                                     color: _orangeColor,
//                                     fontWeight: FontWeight.bold
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 2.0,),
//                     Row(
//                       children: [
//                         Icon(Icons.receipt, color: _orangeColor,),
//                         const SizedBox(width: 5.0,),
//                         RichText(
//                           text: TextSpan(
//                             children: [
//                               const TextSpan(
//                                 text: 'Payment Mode: ',
//                                 style: TextStyle(
//                                   fontSize: 16.0,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                               TextSpan(
//                                 text: 'Cash On Delivery',
//                                 style: TextStyle(
//                                     fontSize: 16.0,
//                                     color: _orangeColor,
//                                     fontWeight: FontWeight.bold
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 2.0,),
//               const Padding(
//                 padding: EdgeInsets.all(8.0),
//                 child: Text('Products in Order!',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 20.0,
//                     color: Colors.black,
//                   ),),
//               ),
//               Expanded(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10.0),
//                     // Smooth edges
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.5),
//                         spreadRadius: 2,
//                         blurRadius: 5,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   padding: const EdgeInsets.all(10.0),
//
//                   child: ListView.builder(
//                     itemCount: productDetails.length,
//                     itemBuilder: (context, index) {
//                       Map<String, dynamic> product = productDetails[index];
//                       String productName = product['productName'];
//                       int selectedQuantity = product['selectedQuantity'];
//
//                       return Container(
//                         margin: const EdgeInsets.all(5.0),
//                         padding: const EdgeInsets.all(8.0),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(10.0),
//                           // Smooth edges
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.5),
//                               spreadRadius: 2,
//                               blurRadius: 5,
//                               offset: const Offset(0, 3),
//                             ),
//                           ],
//                         ),
//                         child: RichText(
//                           textAlign: TextAlign.justify,
//                           text: TextSpan(
//                             children: [
//                               TextSpan(
//                                 text: ' ${index + 1}.   ',
//                                 style: TextStyle(
//                                   color: _orangeColor,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16.0,
//                                 ),
//                               ),
//                               TextSpan(
//                                 text: productName,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                               TextSpan(
//                                 text: '    Qty: $selectedQuantity',
//                                 style: TextStyle(
//                                   color: _orangeColor,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//
//                 ),
//               ),
//               const SizedBox(height: 10.0,),
//               SizedBox(
//                 height: 200,
//                 width: 300,
//                 child: FlutterMap(
//                   options: MapOptions(
//                     center: storeLocationLatLng,
//                     zoom: 12.0,
//                   ),
//                   children: [
//                     TileLayer(
//                       urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
//                       // subdomains: ['a', 'b', 'c'],
//                     ),
//                     MarkerLayer(
//                       markers: [
//                         Marker(
//                           point: storeLocationLatLng,
//                           width: 80.0,
//                           height: 80.0,
//                           child: const Icon(
//                             Icons.location_pin,
//                             color: Colors.blue,
//                             size: 50.0,
//                           ),
//                         ),
//                         Marker(
//                           point: customerLocationLatLng,
//                           width: 80.0,
//                           height: 80.0,
//                           child: const Icon(
//                             Icons.location_pin,
//                             color: Colors.green,
//                             size: 50.0,
//                           ),
//                         ),
//                       ],
//                     ),
//                     PolylineLayer(polylines: [
//                       Polyline(points: [storeLocationLatLng, customerLocationLatLng],
//                       color: Colors.green,
//                       strokeWidth: 5.0),
//                     ])
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 10.0,),
//               ElevatedButton(
//                 onPressed: () async {
//                   setState(() {
//                     isLoading = true;
//                   });
//                   bool isJobAssigned = false;
//
//                   // bool isJobAssigned = await Database_Service(
//                   //     userId: _auth_service.getUserId()).acceptRideJobAsRider(
//                   //     jobId, customerId, orderId);
//                   if (isJobAssigned) {
//                     Navigator.pop(context);
//
//                     setState(() {
//                       isLoading = false;
//                     });
//                   } else {
//                     setState(() {
//                       _error = 'Unable to Pick This Job!';
//                       isLoading = false;
//                     });
//                     // Pop the screen after 3 seconds
//                     await Future.delayed(const Duration(seconds: 3), () {
//                       Navigator.pop(context);
//                     });
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: _orangeColor,
//                 ),
//                 child: const Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.motorcycle_outlined,
//                       color: Colors.white,),
//                     SizedBox(width: 10.0),
//                     Text("Order Delivered",
//                       style: TextStyle(color: Colors.white,
//                           fontSize: 16.0, fontWeight: FontWeight.bold),),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     } else {
//       return const Loading_Screen();
//     }
//   }
// }



import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as dev;
import '../../../Services/Auth/auth.dart';
import '../../../Services/Database/database.dart';
import '../../Account/user_account.dart';
import '../../Authentication/Sign In/signin.dart';
import '../../Home/Rider/homeRider.dart';
import '../../Loading/loading.dart';

class OnGoingJobScreen extends StatefulWidget {

  const OnGoingJobScreen({super.key});

  @override
  State<OnGoingJobScreen> createState() => _OnGoingJobScreenState();
}

class _OnGoingJobScreenState extends State<OnGoingJobScreen> {


  //Variables
  String previousScreen = '';
  Color _orangeColor = Colors.orange.shade800;
  final Auth_Service _auth_service = Auth_Service();
  final String _profileImage = 'assets/images/speedyLogov1.png';
  bool isRider = true;
  bool isLoading = true;
  String _currentAddress = '';
  late Map<String, dynamic> job;
  String _error = '';
  late int remainingTime;
  bool noJobFound = false;

  String ?ownerId;
  String ?storeName;
  String ?storeDescription;
  List<String> ?selectedDays;
  String ?openingHours;
  String ?closingHours;
  double ?latitude;
  double ?longitude;
  String ?contactNumber;
  String ?locationName = 'Fetching Your Current Location';
  String profilePhoto = '';
  double areaRadius = 35; // in kilometers

  late Map<String, dynamic> storeLocation;
  late Map<String, dynamic> customerLocation;
  late int deliveryCharges;
  late int totalCharges;
  late int deliveryTime;
  late String creationTime;
  late String deliveryCreationTime;
  late String storeImageLink;
  late String currentStage;
  late String rider;
  late double storeRadius;
  late double rideRadius;
  late String customerAddress;
  late String storeAddress;
  int storeMaxLines = 1;
  int deliverMaxLines = 1;
  late List<dynamic> productDetails;
  late String jobId;
  late String customerId;
  late String orderId;
  late LatLng customerLocationLatLng;
  late LatLng storeLocationLatLng;

  //Functions
  @override
  void initState() {
    super.initState();
    initializeData();
  }



  void infiniteLoopForClock() {
    Future.delayed(Duration(seconds: 60), () {
      setState(() {
        remainingTime = calculateRemainingTime();
      });
      // Call the function again to create an infinite loop
      infiniteLoopForClock();
    });
  }

  Future<void> _getCurrentLocation() async {
    // Check if the location permission is granted
    var permissionStatus = await Permission.location.status;
    if (permissionStatus.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        latitude = position.latitude;
        longitude = position.longitude;
        List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
        String address = placemarks.first.name ?? '';
        setState(() {
          _currentAddress = address;
        });

      } catch (e) {
        print("Error: $e");
      }
    } else {
      // If permission is not granted, request it
      if (permissionStatus.isDenied || permissionStatus.isRestricted) {
        await Permission.location.request();
      }
    }
  }

  Future<String> getLocationAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          latitude, longitude);
      Placemark placemark = placemarks.first;

      String address = placemark.name ?? '';
      String city = placemark.locality ?? '';
      String country = placemark.country ?? '';

      return '$address, $city, $country';
    } catch (e) {
      return '';
    }
  }


  Future<void> initializeData() async {
    await _getCurrentLocation();
    job = await Database_Service(userId: _auth_service.getUserId()).fetchRiderJobData();
    if(job.isEmpty) {
      setState(() {
        noJobFound = true;
        isLoading = false;
      });
      return;
    }
    infiniteLoopForClock();
    storeLocation = {
      'latitude': job['storeLocation']['latitude'],
      'longitude': job['storeLocation']['longitude'],
    };
    customerLocation = {
      'latitude': job['customerLocation']['latitude'],
      'longitude': job['customerLocation']['longitude'],
    };
    deliveryCreationTime = job['deliveryStartTime'];
    deliveryCharges = job['deliveryCharges'];
    totalCharges = job['totalCharges'];
    storeName = job['storeName'];
    deliveryTime = job['deliveryTime'];
    creationTime = job['creationTime'];
    storeImageLink = job['storeImageLink'];
    currentStage = job['currentStage'];
    productDetails = job['productsName'];
    customerId = job['customerId'];
    orderId = job['orderId'];
    rider = job['rider'];
    storeRadius = double.parse(calculateRadius(latitude!, longitude!, storeLocation['latitude'], storeLocation['longitude']).toStringAsFixed(1));
    rideRadius = double.parse(calculateRadius(customerLocation['latitude'], customerLocation['longitude'], storeLocation['latitude'], storeLocation['longitude']).toStringAsFixed(1));
    customerAddress = await getLocationAddress(customerLocation['latitude'], customerLocation['longitude']);
    storeAddress = await getLocationAddress(storeLocation['latitude'], storeLocation['longitude']);
    jobId = job['jobId'];
    customerLocationLatLng = LatLng(customerLocation['latitude'], customerLocation['longitude']);
    storeLocationLatLng = LatLng(storeLocation['latitude'], storeLocation['longitude']);
    remainingTime = calculateRemainingTime();
    setState(() {
      isLoading = false;
    });
  }

  double calculateRadius(double currentLat, double currentLng, double targetLat,
      double targetLng) {
    const double earthRadius = 6371.0; // Earth's radius in kilometers

    double dLat = degreesToRadians(targetLat - currentLat);
    double dLng = degreesToRadians(targetLng - currentLng);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(degreesToRadians(currentLat)) * cos(degreesToRadians(targetLat)) *
            sin(dLng / 2) * sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  double degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  int calculateRemainingTime() {
    DateTime currentTime = DateTime.now();
    DateTime delTime = DateFormat('dd/MM/yyyy hh:mm a').parse(deliveryCreationTime);
    Duration difference = currentTime.difference(delTime);
    int differenceInMinutes = difference.inMinutes;
    return deliveryTime - differenceInMinutes;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading == false) {
      return Scaffold(

        appBar: AppBar(
          title: Row(
            children: [
              Icon(Icons.location_on_outlined, color: _orangeColor,),
              const SizedBox(width: 5.0,),
              Expanded(
                child: _currentAddress.isNotEmpty
                    ? Text(
                  _currentAddress,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                )
                    : const Text(
                  'Fetching Your Current Location',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserAccount()),
                  );
                },
                child: profilePhoto == '' ?
                CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage(_profileImage),
                ) : CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(profilePhoto),
                ),
              ),
            ],
          ),
          leading: PopupMenuButton(
            icon: const Icon(Icons.menu),
            itemBuilder: (BuildContext context) =>
            [
              PopupMenuItem(
                value: 'rider-mode',
                child: Row(
                  children: [
                    Icon(Icons.motorcycle_outlined,
                      color: _orangeColor,),
                    const SizedBox(width: 10.0,),
                    const Text('Rider',
                      style: TextStyle(
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: _orangeColor,),
                    const SizedBox(width: 10.0,),
                    const Text('LogOut',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
            onSelected: (String value) {
              if (value == 'rider-mode') {
                dev.log('buyer-mode');
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) {
                  return const HomeScreenRider(previousScreen: 'homeBuyer');
                }));
              } else if (value == 'logout') {
                dev.log('logout');
                _auth_service.signOut();
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) {
                  return const SignIn();
                }));
              }
              setState(() {
                _orangeColor = Colors.orange.shade800;
              });
            },

          ),
        ),


        body: noJobFound ? Container(
          child: const Center(
            child: Text('No Jobs Found!',
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.black,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ) : SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.only(
                top: 0, bottom: 10.0, left: 20.0, right: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    // Smooth edges
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(10.0),
                  // Add padding around the content
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          storeImageLink,
                          height: 100, // Adjust image height as needed
                          width: 100, // Adjust image width as needed
                          fit: BoxFit.cover, // Cover the entire space
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              storeName!,
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 3.0),
                            Row(
                              children: [
                                Icon(Icons.store, color: _orangeColor),
                                const SizedBox(width: 2.0,),
                                Text(
                                  'Just $storeRadius Km Away',
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey,
                                  ),

                                ),
                              ],
                            ),
                            const SizedBox(height: 3.0),
                            Row(
                              children: [
                                Icon(Icons.motorcycle, color: _orangeColor),
                                const SizedBox(width: 4.0,),
                                Text(
                                  'Est Delivery $deliveryTime mins',
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3.0),
                            Row(
                              children: [
                                Icon(Icons.map, color: _orangeColor),
                                const SizedBox(width: 2.0,),
                                Text(
                                  'Just $rideRadius Km Del. Ride',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: _orangeColor,
                                  ),

                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Text(_error, style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('Order Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0,
                      color: Colors.black,
                    ),),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    // Smooth edges
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_pin, color: _orangeColor),
                          const SizedBox(width: 5.0),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (storeMaxLines == 1) {
                                  storeMaxLines = 2;
                                } else {
                                  storeMaxLines = 1;
                                }
                                setState(() {
          
                                });
                              },
                              child: RichText(
                                overflow: TextOverflow.ellipsis,
                                maxLines: storeMaxLines,
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Store Location: ',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: storeAddress,
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          color: _orangeColor,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 2.0,),
                      Row(
                        children: [
                          Icon(Icons.house, color: _orangeColor,),
                          const SizedBox(width: 5.0,),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (deliverMaxLines == 1) {
                                  deliverMaxLines = 2;
                                } else {
                                  deliverMaxLines = 1;
                                }
                                setState(() {
          
                                });
                              },
                              child: RichText(
                                overflow: TextOverflow.ellipsis,
                                maxLines: deliverMaxLines,
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Delivery Location: ',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: customerAddress,
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          color: _orangeColor,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2.0,),
                      Row(
                        children: [
                          Icon(Icons.point_of_sale, color: _orangeColor,),
                          const SizedBox(width: 5.0,),
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Delivery Charges: ',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: '$deliveryCharges',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: _orangeColor,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 5.0,),
                          Icon(Icons.currency_rupee, color: _orangeColor,),
                        ],
                      ),
                      const SizedBox(height: 2.0,),
                      Row(
                        children: [
                          Icon(Icons.point_of_sale, color: _orangeColor,),
                          const SizedBox(width: 5.0,),
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Total Charges: ',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: '$totalCharges',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: _orangeColor,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 5.0,),
                          Icon(Icons.currency_rupee, color: _orangeColor,),
                        ],
                      ),
                      const SizedBox(height: 2.0,),
                      Row(
                        children: [
                          Icon(Icons.calendar_month, color: _orangeColor,),
                          const SizedBox(width: 5.0,),
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Order: ',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: '$creationTime',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: _orangeColor,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2.0,),
                      Row(
                        children: [
                          Icon(Icons.timer, color: _orangeColor,),
                          const SizedBox(width: 5.0,),
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Del Start: ',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: '$deliveryCreationTime',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: _orangeColor,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2.0,),
                      Row(
                        children: [
                          Icon(Icons.timer, color: _orangeColor,),
                          const SizedBox(width: 5.0,),
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Remaining Time: ',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: '$remainingTime',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: _orangeColor,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                                const TextSpan(
                                  text: ' mins',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2.0,),
                      Row(
                        children: [
                          Icon(Icons.receipt, color: _orangeColor,),
                          const SizedBox(width: 5.0,),
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Payment Mode: ',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Cash On Delivery',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: _orangeColor,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2.0,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          // Smooth edges
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(Icons.store, color: Colors.blue,),
                              Text(' Store  ', style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0
                              ),),
                            ],
                          ),
                        ),
                      ),

                      Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                            // Smooth edges
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(Icons.motorcycle, size: 30.0, color:  Colors.green,),
                          )),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          // Smooth edges
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const SizedBox(width: 2.0,),
                              Icon(Icons.house, color: _orangeColor,),
                              const Text('Customer', style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0
                              ),),
                            ],
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
                const SizedBox(height: 2.0,),
                SizedBox(
                  height: 200,
                  child: FlutterMap(
                    options: MapOptions(
                      center: storeLocationLatLng,
                      zoom: 12.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        // subdomains: ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: storeLocationLatLng,
                            width: 80.0,
                            height: 80.0,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.blue,
                              size: 50.0,
                            ),
                          ),
                          Marker(
                            point: customerLocationLatLng,
                            width: 80.0,
                            height: 80.0,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.orange,
                              size: 50.0,
                            ),
                          ),
                        ],
                      ),
                      PolylineLayer(polylines: [
                        Polyline(points: [storeLocationLatLng, customerLocationLatLng],
                            color: Colors.green,
                            strokeWidth: 5.0),
                      ])
                    ],
                  ),
                ),
                const SizedBox(height: 10.0,),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Products in Order!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.black,
                    ),),
                ),
                Container(
                  height: productDetails.length * 50 + 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    // Smooth edges
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: ListView.builder(
                    itemCount: productDetails.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> product = productDetails[index];
                      String productName = product['productName'];
                      int selectedQuantity = product['selectedQuantity'];

                      return Container(
                        margin: const EdgeInsets.all(5.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          // Smooth edges
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: ' ${index + 1}.   ',
                                style: TextStyle(
                                  color: _orangeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              TextSpan(
                                text: productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: '    Qty: $selectedQuantity',
                                style: TextStyle(
                                  color: _orangeColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                ),
                const SizedBox(height: 10.0,),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });

                    bool isJobCompleted = await Database_Service(
                        userId: _auth_service.getUserId()).orderDeliveredCompleteRide(totalCharges, jobId, orderId, customerId);
                    if (isJobCompleted) {
                      Navigator.pop(context);
          
                      setState(() {
                        isLoading = false;
                      });
                    } else {
                      setState(() {
                        _error = 'Unable to Pick This Job!';
                        isLoading = false;
                      });
                      // Pop the screen after 3 seconds
                      await Future.delayed(const Duration(seconds: 3), () {
                        Navigator.pop(context);
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orangeColor,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.motorcycle_outlined,
                        color: Colors.white,),
                      SizedBox(width: 10.0),
                      Text("Order Delivered",
                        style: TextStyle(color: Colors.white,
                            fontSize: 16.0, fontWeight: FontWeight.bold),),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return const Loading_Screen();
    }
  }
}
