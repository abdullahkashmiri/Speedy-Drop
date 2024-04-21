import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:speedydrop/Screens/Account/user_account.dart';
import 'package:speedydrop/Screens/Authentication/Sign%20In/signin.dart';
import 'package:speedydrop/Screens/Cart/cart_screen.dart';
import 'package:speedydrop/Screens/Home/homeSeller.dart';
import 'package:speedydrop/Screens/Loading/loading.dart';
import 'package:speedydrop/Screens/Manage%20Store/All%20Stores/all_stores.dart';
import 'package:speedydrop/Services/Auth/auth.dart';
import 'package:speedydrop/Services/Database/database.dart';
import '../Cart/display_cart_screen.dart';
import '../Products/All Products In Store/productsInStore.dart';
import 'homeRider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';





class HomeScreenBuyer extends StatefulWidget {
  const HomeScreenBuyer({super.key});

  @override
  State<HomeScreenBuyer> createState() => _HomeScreenBuyerState();
}

class _HomeScreenBuyerState extends State<HomeScreenBuyer> {

  //Variables
  Color _orangeColor = Colors.orange.shade800;
  final Auth_Service _auth_service = Auth_Service();
  String _currentAddress = '';
  String _profileImage = 'assets/images/speedyLogov1.png';
  int _currentIndex = 0;
  String profilePhoto = '';
  String _userName = '';
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
    _userName = userData?['user-name'] ?? '';
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

    return distance;
  }


  bool isWithinRadius(double currentLat, double currentLng, double targetLat,
      double targetLng, double radiusInKm) {
    const double earthRadius = 6371.0; // Earth's radius in kilometers

    double dLat = degreesToRadians(targetLat - currentLat);
    double dLng = degreesToRadians(targetLng - currentLng);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(degreesToRadians(currentLat)) * cos(degreesToRadians(targetLat)) *
            sin(dLng / 2) * sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance <= radiusInKm;
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
              if (value == 'seller-mode') {
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
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: _currentIndex == 0 ? Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == 0 ? _orangeColor : Colors.grey,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: const Icon(
                    Icons.home,
                    color: Colors.white,
                  ),
                ) : const Icon(
                  Icons.home,
                  color: Colors.grey,
                  size: 30.0,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: _currentIndex == 1 ? Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == 1 ? _orangeColor : Colors.grey,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: const Icon(
                    Icons.shopping_basket,
                    color: Colors.white,
                  ),
                ) : GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return const DisplayCartScreen();
                    }));
                  },
                  child: const Icon(
                    Icons.shopping_basket,
                    color: Colors.grey,
                    size: 30.0,
                  ),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: _currentIndex == 2 ? Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == 2 ? _orangeColor : Colors.grey,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: const Icon(
                    Icons.messenger,
                    color: Colors.white,
                  ),
                ) : const Icon(
                  Icons.messenger,
                  color: Colors.grey,
                  size: 30.0,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: _currentIndex == 3 ? Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == 3 ? _orangeColor : Colors.grey,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: const Icon(
                    Icons.account_circle,
                    color: Colors.white,
                  ),
                ) : const Icon(
                  Icons.account_circle,
                  color: Colors.grey,
                  size: 30.0,
                ),
                label: '',
              ),
            ]
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
                    margin: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Welcome Back,'),
                        Text(_userName,
                          style: TextStyle(
                              color: _orangeColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                          ),),
                        const SizedBox(height: 10.0,),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                    hintText: 'Search for shops',
                                    prefixIcon: const Icon(Icons.search),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12.0, horizontal: 16.0),
                                    filled: true,
                                    fillColor: Colors.white
                                ),
                                onChanged: (value) {
                                  // Implement search functionality here
                                  print('Search query: $value');
                                },
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            // Add spacing between search box and settings button
                            SettingsButton(),
                          ],
                        ),
                        const SizedBox(height: 10.0,),
                        Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Shops',
                                    style: TextStyle(
                                        color: _orangeColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25.0
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' near you',
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.black
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            // Add spacer to push the More button to the end
                            TextButton(
                              onPressed: () {
                                // Add functionality for More button here
                                print('More button pressed');
                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (context) {
                                      return AllStoreScreen();
                                    }));
                              },
                              child: Text(
                                'More',
                                style: TextStyle(
                                  color: Colors.grey
                                      .shade600, // Set color for More button text
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0,),
                        // SizedBox(
                        //   height: 120, // Adjust height as needed
                        //   child: ListView.builder(
                        //     scrollDirection: Axis.horizontal,
                        //     itemCount: itemList.length,
                        //     itemBuilder: (context, index) {
                        //       return Container(
                        //         width: 120,
                        //         height: 100,
                        //         margin: const EdgeInsets.all(8),
                        //         decoration: BoxDecoration(
                        //           color: Colors.white,
                        //           borderRadius: BorderRadius.circular(
                        //               10), // Adjust the curve amount as needed
                        //         ),
                        //         child: Stack(
                        //           children: [
                        //             Positioned(
                        //               top: 4,
                        //               left: 4,
                        //               child: Padding(
                        //                 padding: const EdgeInsets.all(8.0),
                        //                 child: Text(
                        //                   itemList[index]["name"]!,
                        //                   style: const TextStyle(color: Colors.black,
                        //                       fontWeight: FontWeight.w500),
                        //                 ),
                        //               ),
                        //             ),
                        //             Positioned(
                        //               bottom: -30,
                        //               right: -10,
                        //               child: ClipOval(
                        //                 child: Container(
                        //                   width: 100,
                        //                   // Adjust width to control the size of the circular portion
                        //                   height: 100,
                        //                   // Adjust height to control the size of the circular portion
                        //                   color: Colors.blueGrey,
                        //                   // Match the container's color
                        //                   child: Image.network(
                        //                     itemList[index]["imageUrl"]!,
                        //                     fit: BoxFit.cover,
                        //                   ),
                        //                 ),
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       );
                        //     },
                        //   ),
                        // ),

                        SizedBox(
                          height: 120, // Adjust height as needed
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: allStoreData.length,
                            itemBuilder: (context, index) {
                              String userId = allStoreData.keys.elementAt(
                                  index);
                              Map<String,
                                  dynamic> userData = allStoreData[userId]!;
                              var ownerId = userData['owner-id'];
                              var storeName = userData['store-details']['store-name'];
                              var storeDesc = userData['store-details']['store-description'];
                              var selectedDays = List<String>.from(
                                  userData['store-details']['selectedDays']);
                              var openHours = userData['store-details']['openingHours'];
                              var closeHours = userData['store-details']['closingHours'];
                              var lat = userData['store-details']['address']['latitude'];
                              var long = userData['store-details']['address']['longitude'];
                              var contactNum = userData['store-details']['contact-number'];
                              var storeImgLink = userData['store-details']['store-image'];
                              var sales = userData['store-details']['sales'];

                              // Get the current date and time
                              DateTime now = DateTime.now();
                              String dayAbbreviation = DateFormat.E().format(
                                  now); // "E" gives the abbreviated day name
                              String formattedDay = dayAbbreviation.substring(
                                  0, 3); // Take the first three characters
                              bool isDaySelected = selectedDays.contains(
                                  formattedDay);
                              String formattedTime = DateFormat('h:mm a')
                                  .format(now);
                              DateTime openTime = DateFormat('h:mm a').parse(
                                  openHours);
                              DateTime closeTime = DateFormat('h:mm a').parse(
                                  closeHours);
                              DateTime parsedTime = DateFormat('h:mm a').parse(
                                  formattedTime);
                              bool isOpen = ((parsedTime.isAfter(openTime) &&
                                  parsedTime.isBefore(closeTime)) ||
                                  (parsedTime.isAtSameMomentAs(openTime) ||
                                      parsedTime.isAtSameMomentAs(closeTime)));
                              bool isOpenTimeMidnight = openTime.hour == 0 &&
                                  openTime.minute == 0 && openTime.second == 0;
                              bool isCloseTimeMidnight = closeTime.hour == 0 &&
                                  closeTime.minute == 0 &&
                                  closeTime.second == 0;
                              if (isOpenTimeMidnight && isCloseTimeMidnight) {
                                isOpen = true;
                              }

                              bool withinRadius = isWithinRadius(
                                  latitude, longitude, lat, long, 50.0);
                              if (isDaySelected && isOpen && withinRadius) {
                                double val = calculateRadius(
                                    latitude, longitude, lat, long) * 8;
                                int deliveryTime = val.toInt();
                                if (deliveryTime < 30) {
                                  deliveryTime = 30;
                                }

                                return GestureDetector(
                                  onTap: () {
                                    print('User Id: $ownerId');
                                    Navigator.pushReplacement(context,
                                        MaterialPageRoute(builder: (context) {
                                          return ProductsInStore(
                                            owner_id: ownerId,
                                            delivery_time: deliveryTime,);
                                        }));
                                  },
                                  child: Container(
                                    width: 120,
                                    height: 100,
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                          10), // Adjust the curve amount as needed
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: 4,
                                          left: 4,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              storeName,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: -30,
                                          right: -10,
                                          child: ClipOval(
                                            child: Container(
                                              width: 100,
                                              // Adjust width to control the size of the circular portion
                                              height: 100,
                                              // Adjust height to control the size of the circular portion
                                              color: Colors.blueGrey,
                                              // Match the container's color
                                              child: Image.network(
                                                storeImgLink,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
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

                        const SizedBox(height: 10.0,),
                        Row(
                          children: [
                            Text('Popular',
                              style: TextStyle(
                                  color: _orangeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25.0
                              ),),
                            const Spacer(),
                            // Add spacer to push the More button to the end
                            TextButton(
                              onPressed: () {
                                // Add functionality for More button here
                                print('More button pressed');
                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (context) {
                                      return AllStoreScreen();
                                    }));
                              },
                              child: Text(
                                'More',
                                style: TextStyle(
                                  color: Colors.grey
                                      .shade600, // Set color for More button text
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0,),
                        SizedBox(
                          height: 250, // Adjust height as needed
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: allStoreData.length,
                            itemBuilder: (context, index) {
                              String userId = allStoreData.keys.elementAt(
                                  index);
                              Map<String,
                                  dynamic> userData = allStoreData[userId]!;
                              var ownerId = userData['owner-id'];
                              var storeName = userData['store-details']['store-name'];
                              var storeDesc = userData['store-details']['store-description'];
                              var selectedDays = List<String>.from(
                                  userData['store-details']['selectedDays']);
                              var openHours = userData['store-details']['openingHours'];
                              var closeHours = userData['store-details']['closingHours'];
                              var lat = userData['store-details']['address']['latitude'];
                              var long = userData['store-details']['address']['longitude'];
                              var contactNum = userData['store-details']['contact-number'];
                              var storeImgLink = userData['store-details']['store-image'];
                              var sales = userData['store-details']['sales'];

                              // Get the current date and time
                              DateTime now = DateTime.now();
                              String dayAbbreviation = DateFormat.E().format(
                                  now); // "E" gives the abbreviated day name
                              String formattedDay = dayAbbreviation.substring(
                                  0, 3); // Take the first three characters
                              bool isDaySelected = selectedDays.contains(
                                  formattedDay);
                              String formattedTime = DateFormat('h:mm a')
                                  .format(
                                  now);
                              DateTime openTime = DateFormat('h:mm a').parse(
                                  openHours);
                              DateTime closeTime = DateFormat('h:mm a').parse(
                                  closeHours);
                              DateTime parsedTime = DateFormat('h:mm a').parse(
                                  formattedTime);
                              bool isOpen = ((parsedTime.isAfter(openTime) &&
                                  parsedTime.isBefore(closeTime)) ||
                                  (parsedTime.isAtSameMomentAs(openTime) ||
                                      parsedTime.isAtSameMomentAs(closeTime)));
                              bool isOpenTimeMidnight = openTime.hour == 0 &&
                                  openTime.minute == 0 && openTime.second == 0;
                              bool isCloseTimeMidnight = closeTime.hour == 0 &&
                                  closeTime.minute == 0 &&
                                  closeTime.second == 0;
                              if (isOpenTimeMidnight && isCloseTimeMidnight) {
                                isOpen = true;
                              }


                              if (isDaySelected && isOpen &&
                                  sales > popularStoreMinSales) {
                                double val = calculateRadius(
                                    latitude, longitude, lat, long) * 8;
                                int deliveryTime = val.toInt();
                                if (deliveryTime < 30) {
                                  deliveryTime = 30;
                                }

                                return GestureDetector(
                                  onTap: () {
                                    print('User Id: $ownerId');
                                    Navigator.pushReplacement(context,
                                        MaterialPageRoute(builder: (context) {
                                          return ProductsInStore(
                                            owner_id: ownerId,
                                            delivery_time: deliveryTime,);
                                        }));
                                  },
                                  child: Container(

                                    width: 170,
                                    height: 100,
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                          20), // Adjust the curve amount as needed
                                    ),
                                    child: Stack(
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .stretch,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: ClipRRect(
                                                borderRadius: const BorderRadius
                                                    .only(
                                                  topLeft: Radius.circular(20),
                                                  topRight: Radius.circular(20),
                                                ),
                                                child: Image.network(
                                                  storeImgLink,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                    8.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    Text(
                                                      storeName,
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontWeight: FontWeight
                                                              .w500),
                                                    ),
                                                    Text(
                                                      storeDesc,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          color: Colors.grey),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Positioned(
                                          bottom: 58.5,
                                          left: 50,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: const BorderRadius
                                                  .only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                              ),
                                              // Adjust the curve amount as needed
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  spreadRadius: 1,
                                                  blurRadius: 3,
                                                  offset: const Offset(0,
                                                      2), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2, horizontal: 6),
                                            child: Row(
                                              children: [
                                                Text(
                                                  '($sales)'.toString() ??
                                                      'N/A',
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight
                                                          .bold),
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(
                                                  Icons.local_grocery_store,
                                                  color: _orangeColor,
                                                  size: 16,
                                                ),
                                              ],
                                            ),
                                          ),
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
                        )
                      ],
                    ),
                  ),
                );
              }
            }
          },
        ),

      );
    }
    else {
      return const Loading_Screen();
    }
  }
}
class SettingsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.0, // Set the same height as the search box
      width: 48.0, // Set a fixed width for the square-shaped button
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all( // Add border
          color: Colors.black54, // Choose your border color
          width: 1.0, // Choose your border width
        ),
        color: Colors.white,
      ),
      child: IconButton(
        icon: const Icon(Icons.adjust),
        onPressed: () {
          // Add functionality for settings button here
          print('Settings button pressed');
        },
      ),
    );
  }
}
