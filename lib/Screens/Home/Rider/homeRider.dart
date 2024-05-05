import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speedydrop/Screens/Delivery/Job%20Page/jobToSelect.dart';
import 'package:speedydrop/Screens/Home/Seller/homeSeller.dart';
import 'package:speedydrop/Screens/Loading/loading.dart';
import '../../../Services/Auth/auth.dart';
import '../../../Services/Database/database.dart';
import '../../Account/user_account.dart';
import '../../Authentication/Sign In/signin.dart';
import '../Buyer/homeBuyer.dart';

class HomeScreenRider extends StatefulWidget {
  final String previousScreen;
  const HomeScreenRider({Key? key,  required this.previousScreen});

  @override
  State<HomeScreenRider> createState() => _HomeScreenRiderState();
}

class _HomeScreenRiderState extends State<HomeScreenRider> {


  //Variables
  String previousScreen = '';
  Color _orangeColor = Colors.orange.shade800;
  final Auth_Service _auth_service = Auth_Service();
  String _profileImage = 'assets/images/speedyLogov1.png';
  bool isRider = true;
  bool isLoading = true;
  String _currentAddress = '';


  String ?ownerId;
  String ?storeName;
  String ?storeDescription;
  List<String> ?selectedDays;
  String ?openingHours;
  String ?closingHours;
  double ?latitude;
  double ?longitude;
  String ?contactNumber;
  String ?storeImageLink;
  String ?locationName = 'Fetching Your Current Location';
  String profilePhoto = '';
  double areaRadius = 35; // in kilometers

  late List<Map<String, dynamic>> avaliableJobs;

  //Functions


  @override
  void initState() {
    super.initState();
    previousScreen = widget.previousScreen;
    _getCurrentLocation();
    isUserARider();
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

  Future<void> isUserARider() async {
    isRider =
    await Database_Service(userId: _auth_service.getUserId()).isUserARider();
  }

  Future<void> initializeData() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    avaliableJobs =
    await Database_Service(userId: _auth_service.getUserId()).fetchNearbyAvailableJobs(
        position, areaRadius);
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

  Future<bool> isOnGoingJob() async {
    late Map<String, dynamic> j;
    j = await Database_Service(userId: _auth_service.getUserId()).fetchRiderJobData();
    if(j.isEmpty) {
      return false;
    }
    return true;
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
                value: 'buyer-mode',
                child: Row(
                  children: [
                    Icon(Icons.switch_account,
                      color: _orangeColor,),
                    const SizedBox(width: 10.0,),
                    const Text('Buyer',
                      style: TextStyle(
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'seller-mode',
                child: Row(
                  children: [
                    Icon(Icons.store, color: _orangeColor,),
                    const SizedBox(width: 10.0,),
                    const Text(
                        'Seller',
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
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) {
                  return const HomeScreenBuyer();
                }));
              } else if (value == 'seller-mode') {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) {
                  return const HomeScreenSeller(previousScreen: 'homeRider');
                }));
                dev.log('seller-mode');
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


        body: isRider ? Container(
          margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10
          ),
          child: Column(
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Jobs',
                      style: TextStyle(
                          color: _orangeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0
                      ),
                    ),
                    const TextSpan(
                      text: ' Available Near You!',
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.black
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8.0,),
              Expanded(
                child: ListView.builder(
                  itemCount: avaliableJobs.length,
                  itemBuilder: (context, index) {
                    final job = avaliableJobs[index];

                    Map<String, dynamic> storeLocation = {
                      'latitude': job['storeLocation']['latitude'],
                      'longitude': job['storeLocation']['longitude'],
                    };

                    Map<String, dynamic> customerLocation = {
                      'latitude': job['customerLocation']['latitude'],
                      'longitude': job['customerLocation']['longitude'],
                    };

                    int deliveryCharges = job['deliveryCharges'];
                    int totalCharges = job['totalCharges'];
                    String storeName = job['storeName'];
                    int deliveryTime = job['deliveryTime'];
                    String creationTime = job['creationTime'];
                    String storeImageLink = job['storeImageLink'];
                    String currentStage = job['currentStage'];
                    String rider = job['rider'];
                    double storeRadius = double.parse(calculateRadius(latitude!, longitude!,storeLocation['latitude'] , storeLocation['longitude'] ).toStringAsFixed(1));

                    if(currentStage == 'placed') {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          // Rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              // Shadow color
                              spreadRadius: 2,
                              // Spread radius
                              blurRadius: 5,
                              // Blur radius
                              offset: const Offset(0, 2), // Shadow position
                            ),
                          ],
                        ),
                        child: ListTile(
                          onTap: () {
                            // Navigator.push(context, MaterialPageRoute(builder: (context) {
                            //   return ProductsInStore(owner_id: ownerId,delivery_time: deliveryTime,);
                            // }));

                            Navigator.push(
                                context, MaterialPageRoute(builder: (context) {
                              return JobSelection(job: job,);
                            }));
                          },
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              storeImageLink,
                              fit: BoxFit.cover,
                              width: 70,
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
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                creationTime,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12
                                ),
                              ),
                              Text(
                                'Del: $deliveryTime mins',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  color: _orangeColor,
                                ),
                              ),
                            ],
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
                              const SizedBox(height: 2.0,),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.motorcycle,
                                    color: _orangeColor,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 1),
                                  Text(
                                    '$deliveryCharges',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    Icons.currency_rupee,
                                    color: _orangeColor,
                                    size: 16,
                                  ),

                                ],
                              ),
                              const SizedBox(height: 2.0,),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.local_grocery_store,
                                    color: _orangeColor,
                                    size: 16,
                                  ),
                                  Text(
                                    '$totalCharges',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    Icons.currency_rupee,
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
                      return Container();
                    }
                  },
                ),
              ),

            ],
          ),
        ) : Center(
          child: Container(
            width: 280.0,
            height: 120.0,
            padding: const EdgeInsets.symmetric(horizontal: 20.0,
                vertical: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              color: Colors.grey.shade300,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.motorcycle,
                      color: _orangeColor,
                      size: 30.0,),
                    const SizedBox(width: 10.0,),
                    const Text(
                      'Become a Rider with Us', style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0
                    ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Database_Service(userId: _auth_service.getUserId())
                            .createRiderMode();
                        setState(() {
                          isRider = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('Continue',
                        style: TextStyle(color: Colors.white,),
                      ),
                    ),
                    const SizedBox(width: 10.0,),
                    ElevatedButton(
                      onPressed: () {
                        if (previousScreen == 'homeBuyer') {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                                return const HomeScreenBuyer();
                              }));
                        } else if (previousScreen == 'homeSeller') {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                                return const HomeScreenSeller(
                                  previousScreen: 'homeRider',);
                              }));
                        } else if (previousScreen == 'userAccount') {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                                return const UserAccount();
                              }));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red
                      ),
                      child: const Text('Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                )
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

