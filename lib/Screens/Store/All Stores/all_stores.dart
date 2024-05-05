import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:speedydrop/Screens/Account/user_account.dart';
import 'package:speedydrop/Screens/Authentication/Sign%20In/signin.dart';
import 'package:speedydrop/Screens/Loading/loading.dart';
import 'package:speedydrop/Screens/Products/All%20Products%20In%20Store/productsInStore.dart';
import 'package:speedydrop/Services/Auth/auth.dart';
import 'package:speedydrop/Services/Database/database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class AllStoreScreen extends StatefulWidget {
  const AllStoreScreen({super.key});

  @override
  State<AllStoreScreen> createState() => _AllStoreScreenState();
}

class _AllStoreScreenState extends State<AllStoreScreen> {

  //Variables
  Color _orangeColor = Colors.orange.shade800;
  final Auth_Service _auth_service = Auth_Service();
  String _currentAddress = '';
  String _profileImage = 'assets/images/speedyLogov1.png';
  String profilePhoto = '';
  bool isLoading = true;
  String userId = '';
  double latitude = 0.0;
  double longitude = 0.0;
  int popularStoreMinSales = 35;
  int deliveryTimePerKm = 8;

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

  double calculateRadius(double currentLat, double currentLng, double targetLat, double targetLng) {
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

            IconButton(onPressed: () async {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AllStoreScreen()));
            },
                icon: const Icon(Icons.refresh)),


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
              Navigator.pop(context);
            }  else if (value == 'logout') {
              dev.log('logout');
              _auth_service.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => SignIn()),
                    (route) => false, // This condition removes all routes from the stack
              );

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
                return Container(
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
                            Expanded(
                              child: ListView.builder(
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
                                  double val = storeRadius * deliveryTimePerKm;
                                  int deliveryTime = val.toInt();
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
                                         Navigator.push(context, MaterialPageRoute(builder: (context) {
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
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        subtitle: Text(
                                          storeDesc,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 3,
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
                            ),
                          ]
                      ),
                    )
                );
              }
            }
          }
      ),
    );
  }
}
