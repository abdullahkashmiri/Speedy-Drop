import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:speedydrop/Screens/Account/user_account.dart';
import 'package:speedydrop/Screens/Authentication/Sign%20In/signin.dart';
import 'package:speedydrop/Screens/Home/homeSeller.dart';
import 'package:speedydrop/Screens/Loading/loading.dart';
import 'package:speedydrop/Screens/Products/All%20Products%20In%20Store/productsInStore.dart';
import 'package:speedydrop/Services/Auth/auth.dart';
import 'package:speedydrop/Services/Database/database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../Home/homeRider.dart';



class AllStore extends StatefulWidget {
  const AllStore({super.key});

  @override
  State<AllStore> createState() => _AllStoreState();
}

class _AllStoreState extends State<AllStore> {

  //Variables
  Color _orangeColor = Colors.orange.shade800;
  final Auth_Service _auth_service = Auth_Service();
  String _currentAddress = '';
  String _profileImage = 'assets/images/speedyLogov1.png';
  final List<Map<String, String>> itemList = [
    {
      "name": 'Nike',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg'
    },
    {
      "name": 'Adidas',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg'
    },
    {
      "name": 'Apple',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg'
    },
    {
      "name": 'Samsung',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg'
    },
    {
      "name": 'Gucci',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg'
    },
    {
      "name": 'Louis Vuitton',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg'
    },
    {
      "name": 'H&M',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg'
    },
    {
      "name": 'Zara',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg'
    },
    {
      "name": 'Amazon',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg'
    },
    {
      "name": 'Sony',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg'
    },
  ];
  final List<Map<String, dynamic>> itemList2 = [
    {
      "name": 'Nike',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg',
      "rating": 4.5,
      "category": "Sports"
    },
    {
      "name": 'Adidas',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg',
      "rating": 4.3,
      "category": "Sports"
    },
    {
      "name": 'Apple',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg',
      "rating": 4.8,
      "category": "Electronics"
    },
    {
      "name": 'Samsung',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg',
      "rating": 4.4,
      "category": "Electronics"
    },
    {
      "name": 'Gucci',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg',
      "rating": 4.7,
      "category": "Fashion"
    },
    {
      "name": 'Louis Vuitton',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg',
      "rating": 4.9,
      "category": "Fashion"
    },
    {
      "name": 'H&M',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg',
      "rating": 4.2,
      "category": "Fashion"
    },
    {
      "name": 'Zara',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg',
      "rating": 4.6,
      "category": "Fashion"
    },
    {
      "name": 'Amazon',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg',
      "rating": 4.8,
      "category": "Online Store"
    },
    {
      "name": 'Sony',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg',
      "rating": 4.5,
      "category": "Electronics"
    },
  ];
  String profilePhoto = '';
  bool isLoading = true;
  String userId = '';
  double latitude = 0.0;
  double longitude = 0.0;
  int popularStoreMinSales = 35;


  //Functions
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    initializedData();
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
        print('loc: $_currentAddress');
        setState(() {
          isLoading = false;
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

  Future<void> initializedData() async {
    Map<String, dynamic>? userData = await Database_Service(
        userId: _auth_service.getUserId()).fetchUserDataFromCloud();

    userId = userData?['user-id'] ?? '';
    profilePhoto = userData?['profileImage'] ?? '';
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

    return distance ;
  }

  double degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  @override
  Widget build(BuildContext context) {
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
              child: profilePhoto == '' ? CircleAvatar(
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
              value: 'buyer-mode',
              child: Row(
                children: [
                  Icon(Icons.switch_account, color: _orangeColor,),
                  const SizedBox(width: 10.0,),
                  const Text('Home',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'seller-mode',
              child: Row(
                children: [
                  Icon(Icons.store, color: _orangeColor,),
                  const SizedBox(width: 10.0,),
                  const Text('Seller',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'rider-mode',
              child: Row(
                children: [
                  Icon(Icons.motorcycle_sharp, color: _orangeColor,),
                  const SizedBox(width: 10.0,),
                  const Text(
                      'Rider', style: TextStyle(fontWeight: FontWeight.bold)),
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
            if (value == 'buyer-mode') {
              dev.log('buyer-mode');
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) {
                return const HomeScreenSeller(previousScreen: 'allStore',);
              }));
            } else if (value == 'seller-mode') {
              dev.log('seller-mode');
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) {
                return const HomeScreenSeller(previousScreen: 'homeBuyer',);
              }));
            } else if (value == 'rider-mode') {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) {
                return const HomeScreenRider();
              }));
              dev.log('rider-mode');
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

      body: FutureBuilder(
          future: Database_Service(userId: _auth_service.getUserId())
              .fetchAllStoreData(),
          builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loading_Screen();
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              Map<String, dynamic>? allStoreData = snapshot.data;
              if (allStoreData == null || allStoreData.isEmpty) {
                return const Center(child: Text('No store data available.'));
              } else {
                return SingleChildScrollView(
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20), // Rounded corners
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2), // Shadow color
                            spreadRadius: 2, // Spread radius
                            blurRadius: 5, // Blur radius
                            offset: const Offset(0, 2), // Shadow position
                          ),
                        ],
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10.0,),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Stores',
                                      style: TextStyle(
                                          color: _orangeColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25.0
                                      ),
                                    ),
                                    const TextSpan(
                                      text: ' Currently Open!',
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          color: Colors.black
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10.0,),
                              ListView.builder(
                                shrinkWrap: true, // Add this line
                                scrollDirection: Axis.vertical,
                                itemCount: allStoreData.length,
                                itemBuilder: (context, index) {
                                  String userId = allStoreData.keys.elementAt(index);
                                  Map<String, dynamic> userData = allStoreData[userId]!;
                                  String ownerId = '';
                                  ownerId = userData['owner-id'];
                                  var storeName = userData['store-details']['store-name'];
                                  var storeDesc = userData['store-details']['store-description'];
                                  var selectedDays = List<String>.from(userData['store-details']['selectedDays']);
                                  var openHours = userData['store-details']['openingHours'];
                                  var closeHours = userData['store-details']['closingHours'];
                                  var lat = userData['store-details']['address']['latitude'];
                                  var long = userData['store-details']['address']['longitude'];
                                  var contactNum = userData['store-details']['contact-number'];
                                  var storeImgLink = userData['store-details']['store-image'];
                                  var sales = userData['store-details']['sales'];

                                  // Get the current date and time
                                  DateTime now = DateTime.now();
                                  String dayAbbreviation = DateFormat.E().format(now); // "E" gives the abbreviated day name
                                  String formattedDay = dayAbbreviation.substring(0, 3); // Take the first three characters
                                  bool isDaySelected = selectedDays.contains(formattedDay);
                                  String formattedTime = DateFormat('h:mm a').format(now);
                                  DateTime openTime = DateFormat('h:mm a').parse(openHours);
                                  DateTime closeTime = DateFormat('h:mm a').parse(closeHours);
                                  DateTime parsedTime = DateFormat('h:mm a').parse(formattedTime);
                                  bool isOpen = ((parsedTime.isAfter(openTime) && parsedTime.isBefore(closeTime)) ||
                                      (parsedTime.isAtSameMomentAs(openTime) || parsedTime.isAtSameMomentAs(closeTime)));
                                  bool isOpenTimeMidnight = openTime.hour == 0 && openTime.minute == 0 && openTime.second == 0;
                                  bool isCloseTimeMidnight = closeTime.hour == 0 && closeTime.minute == 0 && closeTime.second == 0;
                                  if (isOpenTimeMidnight && isCloseTimeMidnight) {
                                    isOpen = true;
                                  }
                                  double storeRadius = double.parse(calculateRadius(latitude, longitude, lat, long).toStringAsFixed(1));
                                  double deliveryTime = storeRadius * 8;
                                  if(deliveryTime < 30){
                                    deliveryTime = 30;
                                  }

                                  if (isDaySelected && isOpen) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(vertical: 5.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10), // Rounded corners
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.2), // Shadow color
                                            spreadRadius: 2, // Spread radius
                                            blurRadius: 5, // Blur radius
                                            offset: const Offset(0, 2), // Shadow position
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        onTap: () {
                                          print('User Id: $ownerId');
                                         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                                           return ProductsInStore(owner_id: ownerId,delivery_time: deliveryTime,);
                                         }));
                                        },
                                        leading: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            storeImgLink,
                                            fit: BoxFit.cover,
                                            width: 100,
                                            height: 100,
                                          ),
                                        ),
                                        title: Text(
                                          storeName,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        subtitle: Text(
                                          storeDesc,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        trailing: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '$storeRadius Km',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                            const SizedBox(height: 5.0,),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  '($sales)',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(
                                                  Icons.local_grocery_store,
                                                  color: _orangeColor,
                                                  size: 16,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                },
                              ),
                            ]
                        ),
                      )
                  ),
                );
              }
            }
          }
      ),
    );
  }
}
