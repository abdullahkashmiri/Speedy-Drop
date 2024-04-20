import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speedydrop/Screens/Account/user_account.dart';
import 'package:speedydrop/Screens/Home/homeBuyer.dart';
import 'package:speedydrop/Screens/Loading/loading.dart';
import 'package:speedydrop/Screens/Manage%20Store/manage_store.dart';
import 'package:speedydrop/Services/Database/database.dart';
import '../../../Services/Auth/auth.dart';
import '../../Authentication/Sign In/signin.dart';
import '../../Home/homeRider.dart';
import '../../Home/homeSeller.dart';

class ProductsInStore extends StatefulWidget {
  final String owner_id;
  final double delivery_time;
  const ProductsInStore({Key? key, required this.owner_id,  required this.delivery_time});

  @override
  State<ProductsInStore> createState() => _ProductsInStoreState();
}

class _ProductsInStoreState extends State<ProductsInStore> {

  //Variables
  String previousScreen = '';
  Color _orangeColor = Colors.orange.shade800;
  final Auth_Service _auth_service = Auth_Service();
  String _profileImage = 'assets/images/speedyLogov1.png';
  bool isLoading = true;
  String _currentAddress = '';

  late String ownerId;
  String ?storeName;
  String ?storeDescription;
  List<String> ?selectedDays;
  String ?openingHours;
  String ?closingHours;
  double ?latitude;
  double ?longitude;
  String ?contactNumber;
  String ?storeImageLink;
  String ?locationName = 'Unable to get Store Location';
  String profilePhoto = '';
  double deliveryTime = 0.0;

  //Functions

  @override
  void initState() {
    super.initState();
    ownerId = widget.owner_id;
    deliveryTime = widget.delivery_time;
    storeDataInitialized();
    _getCurrentLocation();
  }


  //Functions
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


  Future<void> storeDataInitialized() async {
    try {
      // Fetch store data
      Map<String, dynamic>? storeData = await Database_Service(userId: ownerId).fetchStoreData();

      if (storeData != null) {
        // Extract data into variables
        storeName = storeData['store-details']['store-name'];
        storeDescription = storeData['store-details']['store-description'];
        selectedDays = List<String>.from(storeData['store-details']['selectedDays']);
        openingHours = storeData['store-details']['openingHours'];
        closingHours = storeData['store-details']['closingHours'];
        latitude = storeData['store-details']['address']['latitude'];
        longitude = storeData['store-details']['address']['longitude'];
        contactNumber = storeData['store-details']['contact-number'];
        storeImageLink = storeData['store-details']['store-image'];

        List<Placemark> placemarks = await placemarkFromCoordinates(
          latitude!,
          longitude!,
        );
        locationName = placemarks[0].name ?? '';
        profilePhoto = await Database_Service(userId: _auth_service.getUserId()).fetchUserProfilePhoto();
        print('proifilelel');
        print(profilePhoto);
        setState(() {
          isLoading = false;
        });
      } else {
        print('Failed to fetch store data');
      }
    } catch (e) {
      print('Error occurred while initializing and fetching store data: $e');
    }
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

              ClipRRect(
                borderRadius: BorderRadius.circular(10), // Adjust the border radius as needed
                child: storeImageLink == ''
                    ? Container( // Placeholder container if storeImageLink is empty
                  width: 40, // Adjust the width as needed
                  height: 40, // Adjust the height as needed
                  color: Colors.blue, // Set background color if storeImageLink is empty
                  child: Center(
                    child: Image.asset(_profileImage), // Use default image
                  ),
                )
                    : Image.network(
                  storeImageLink!,
                  width: 40, // Adjust the width as needed
                  height: 40, // Adjust the height as needed
                  fit: BoxFit.cover,
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
                  return const HomeScreenBuyer();
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

        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: Database_Service(userId: ownerId)
              .fetchAllProductsOfSeller(),
          builder: (BuildContext context,
              AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loading_Screen();
            } else {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                List<Map<String, dynamic>> products = snapshot.data ?? [];
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      storeName != null ?
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: _orangeColor,
                          borderRadius: BorderRadius.circular(20.0), // Adjust the radius for smoother edges
                        ),
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                storeName!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2.0,),
                            Text('Contact Us : $contactNumber',style: const TextStyle(color: Colors.white),),
                            const SizedBox(height: 2.0,),
                            Text('Estimated Delivery : $deliveryTime mins',style: const TextStyle(color: Colors.white),)
                          ],
                        ),
                      ) : Container(),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Store Products',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24.0,
                          ),),
                      ),
                      Expanded(
                        child: GridView.builder(
                          itemCount: products.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // Two products per row
                            mainAxisSpacing: 5.0,
                            crossAxisSpacing: 5.0,
                            childAspectRatio: 0.7, // Aspect ratio for better layout
                          ),
                          itemBuilder: (context, index) {
                            Map<String,
                                dynamic> product = products[index];
                            return Card(
                              elevation: 4,
                              // Add elevation for a shadow effect
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0), // Rounded corners
                              ),
                              color: Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment
                                    .start,
                                children: [
                                  // Display product image (assuming 'images' is a list of image URLs)
                                  ClipRRect(
                                    borderRadius: const BorderRadius
                                        .vertical(
                                        top: Radius.circular(10.0)),
                                    child: Image.network(
                                      product['images'][0],
                                      // Assuming the first image URL is used
                                      width: double.infinity,
                                      height: 105.0,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: [
                                        Text(
                                          product['product-name'],
                                          style: const TextStyle(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Price: ${product['price']}',
                                          style: const TextStyle(
                                            fontSize: 10.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ), // Set the background color of the card
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }
            }
          },
        ) ,

      );
    } else {
      return const Loading_Screen();
    }
  }
}
