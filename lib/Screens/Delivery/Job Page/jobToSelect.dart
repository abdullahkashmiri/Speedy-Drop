import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speedydrop/Screens/Loading/loading.dart';
import '../../../Services/Auth/auth.dart';
import 'dart:math';
import 'dart:developer' as dev;
import '../../Account/user_account.dart';
import '../../Authentication/Sign In/signin.dart';
import '../../Home/Rider/homeRider.dart';

class JobSelection extends StatefulWidget {
  final Map<String, dynamic> job;

  const JobSelection({Key? key,  required this.job});

  @override
  State<JobSelection> createState() => _JobSelectionState();
}

class _JobSelectionState extends State<JobSelection> {

  //Variables
  String previousScreen = '';
  Color _orangeColor = Colors.orange.shade800;
  final Auth_Service _auth_service = Auth_Service();
  final String _profileImage = 'assets/images/speedyLogov1.png';
  bool isRider = true;
  bool isLoading = true;
  String _currentAddress = '';
  late Map<String, dynamic> job;

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
  late String storeImageLink;
  late String currentStage;
  late String rider;
  late double storeRadius;
  late double rideRadius;

  //Functions
  @override
  void initState() {
    super.initState();
    initializeData();
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


  Future<void> initializeData() async {
    job = widget.job;
    await _getCurrentLocation();
    storeLocation = {
      'latitude': job['storeLocation']['latitude'],
      'longitude': job['storeLocation']['longitude'],
    };
    customerLocation = {
      'latitude': job['customerLocation']['latitude'],
      'longitude': job['customerLocation']['longitude'],
    };
    deliveryCharges = job['deliveryCharges'];
    totalCharges = job['totalCharges'];
    storeName = job['storeName'];
    deliveryTime = job['deliveryTime'];
    creationTime = job['creationTime'];
    storeImageLink = job['storeImageLink'];
    currentStage = job['currentStage'];
    rider = job['rider'];
    storeRadius = double.parse(calculateRadius(latitude!, longitude!,storeLocation['latitude'] , storeLocation['longitude'] ).toStringAsFixed(1));
    rideRadius = double.parse(calculateRadius(customerLocation['latitude'] , customerLocation['longitude'], storeLocation['latitude'] , storeLocation['longitude'] ).toStringAsFixed(1));

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


              IconButton(onPressed: () async {
                isLoading = true;
                setState(() {

                });
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) {
                  return HomeScreenRider(previousScreen: previousScreen);
                }));
                isLoading = false;
                setState(() {

                });
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


        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
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
              const SizedBox(height: 4.0,),

            ],
          ),
        ),
      );
    } else {
      return const Loading_Screen();
    }
  }
}
