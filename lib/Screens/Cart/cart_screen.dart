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

import '../Home/homeBuyer.dart';


class CartScreen extends StatefulWidget {
  final Map<int, Map<String, dynamic>> cart_products;
  final String vendor_id;

  const CartScreen({
    Key? key,
    required this.cart_products,
    required this.vendor_id,
  }) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  //Variables
  Color _orangeColor = Colors.orange.shade800;
  final Auth_Service _auth_service = Auth_Service();
  String _currentAddress = '';
  String _profileImage = 'assets/images/speedyLogov1.png';
  String profilePhoto = '';
  String userId = '';
  double latitude = 0.0;
  double longitude = 0.0;
  int popularStoreMinSales = 35;
  late Map<int, Map<String, dynamic>> cartProducts;
  bool isLoading = true;
  late List<bool> isChecked;
  late String vendorId;
  int subTotal = 0;

  String ?ownerId;
  String ?storeName;
  String ?storeDescription;
  List<String> ?selectedDays;
  String ?openingHours;
  String ?closingHours;
  double ?storeLatitude;
  double ?storeLongitude;
  String ?contactNumber;
  String ?storeImageLink;
  String ?locationName = 'Unable to get Store Location';
  int calculateDistance = 0;
  int estimatedDelivery = 0;
  int deliveryCharges = 0;
  int deliveryChargePerKm = 15;
  int totalCharges = 0;
  String _error = '';
  bool emptyCart = false;


  //Functions
  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> _getCurrentLocation() async {
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


  Future<void> storeDataInitialized() async {
    try {
      // Fetch store data
      Map<String, dynamic>? storeData = await Database_Service(userId: vendorId)
          .fetchStoreData();

      if (storeData != null) {
        // Extract data into variables
        ownerId = storeData['owner-id'];
        storeName = storeData['store-details']['store-name'];
        storeDescription = storeData['store-details']['store-description'];
        selectedDays =
        List<String>.from(storeData['store-details']['selectedDays']);
        openingHours = storeData['store-details']['openingHours'];
        closingHours = storeData['store-details']['closingHours'];
        storeLatitude = storeData['store-details']['address']['latitude'];
        storeLongitude = storeData['store-details']['address']['longitude'];
        contactNumber = storeData['store-details']['contact-number'];
        storeImageLink = storeData['store-details']['store-image'];

        List<Placemark> placemarks = await placemarkFromCoordinates(
          latitude,
          longitude,
        );
        locationName = placemarks[0].name ?? '';
        profilePhoto = await Database_Service(userId: _auth_service.getUserId())
            .fetchUserProfilePhoto();
        setState(() {

        });
      } else {
        print('Failed to fetch store data');
      }
    } catch (e) {
      print('Error occurred while initializing and fetching store data: $e');
    }
  }

  Future<void> initializeData() async {
    // Fetch cart products
    cartProducts = widget.cart_products;
    vendorId = widget.vendor_id;
    for(int i=0; i< cartProducts.length; i++) {
      double val = cartProducts[i]?['price'] * cartProducts[i]?['selected-quantity'];
      subTotal += val.toInt();
    }
    await storeDataInitialized();
    isChecked = List.filled(cartProducts.length, true);
    // Get current location
    await _getCurrentLocation();
    double storeRadius = double.parse(
        calculateRadius(latitude, longitude, storeLatitude!, storeLongitude!)
            .toStringAsFixed(1));
    calculateDistance = storeRadius.toInt();
    double chargeVal = storeRadius * deliveryChargePerKm;
    deliveryCharges = chargeVal.toInt();
    double val = storeRadius * 8;

    totalCharges = subTotal + deliveryCharges;
    int deliveryTime = val.toInt();
    if (deliveryTime < 30) {
      deliveryTime = 30;
    }
    estimatedDelivery = deliveryTime;
    // Update UI state
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
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) {
                  return const HomeScreenBuyer();
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
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
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
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
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
                      padding: const EdgeInsets.all(16.0),
                      // Add padding around the content
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(
                              storeImageLink!,
                              height: 100, // Adjust image height as needed
                              width: 100, // Adjust image width as needed
                              fit: BoxFit.cover, // Cover the entire space
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          // Add horizontal spacing between image and text
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
                                // Add vertical spacing between store name and distance
                                Text(
                                  'Just $calculateDistance Km Away',
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey,
                                  ),

                                ),
                                const SizedBox(height: 4.0),
                                // Add vertical spacing between distance and delivery time
                                Text(
                                  'Est Delivery $estimatedDelivery mins',
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2.0,),
                    Center(
                      child: Text(_error, style: const TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),),
                    ),
                    const SizedBox(height: 2.0,),

                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Select ',
                            style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.black
                            ),
                          ),
                          TextSpan(
                            text: 'Products',
                            style: TextStyle(
                                color: _orangeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 25.0
                            ),
                          ),
                          const TextSpan(
                            text: ' to checkout!',
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
                          itemCount: cartProducts.length,
                          itemBuilder: (context, index) {
                            Map<String,
                                dynamic>? product = cartProducts[index];


                            String productId = product?['product-id'];
                            String vendorId = product?['vendor-id'];
                            String productName = product?['product-name'];
                            String productDescription = product?['description'];
                            double price = product?['price'];
                            int productQuantity = product?['quantity'];
                            bool availability = product?['availability'];
                            List<String> productImages = List<
                                String>.from(product?['images']);
                            int selectedQuantity = product?['selected-quantity'];
                            double val = selectedQuantity * price;
                            int calculatedPrice = val.toInt();

                            // String userId = allStoreData.keys.elementAt(index);
                            // Map<String, dynamic> userData = allStoreData[userId]!;
                            // String ownerId = '';
                            // ownerId = userData['owner-id'];
                            // var storeName = userData['store-details']['store-name'];
                            // var storeDesc = userData['store-details']['store-description'];
                            // var selectedDays = List<String>.from(userData['store-details']['selectedDays']);
                            // var openHours = userData['store-details']['openingHours'];
                            // var closeHours = userData['store-details']['closingHours'];
                            // var lat = userData['store-details']['address']['latitude'];
                            // var long = userData['store-details']['address']['longitude'];
                            // var contactNum = userData['store-details']['contact-number'];
                            // var storeImgLink = userData['store-details']['store-image'];
                            // var sales = userData['store-details']['sales'];

                            // // Get the current date and time
                            // DateTime now = DateTime.now();
                            // String dayAbbreviation = DateFormat.E().format(now); // "E" gives the abbreviated day name
                            // String formattedDay = dayAbbreviation.substring(0, 3); // Take the first three characters
                            // bool isDaySelected = selectedDays.contains(formattedDay);
                            // String formattedTime = DateFormat('h:mm a').format(now);
                            // DateTime openTime = DateFormat('h:mm a').parse(openHours);
                            // DateTime closeTime = DateFormat('h:mm a').parse(closeHours);
                            // DateTime parsedTime = DateFormat('h:mm a').parse(formattedTime);
                            // bool isOpen = ((parsedTime.isAfter(openTime) && parsedTime.isBefore(closeTime)) ||
                            //     (parsedTime.isAtSameMomentAs(openTime) || parsedTime.isAtSameMomentAs(closeTime)));
                            // bool isOpenTimeMidnight = openTime.hour == 0 && openTime.minute == 0 && openTime.second == 0;
                            // bool isCloseTimeMidnight = closeTime.hour == 0 && closeTime.minute == 0 && closeTime.second == 0;
                            // if (isOpenTimeMidnight && isCloseTimeMidnight) {
                            //   isOpen = true;
                            // }
                            // double storeRadius = double.parse(calculateRadius(latitude, longitude, lat, long).toStringAsFixed(1));
                            // double deliveryTime = storeRadius * 8;
                            // if(deliveryTime < 30){
                            //   deliveryTime = 30;
                            // }

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    10),
                                // Rounded corners
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(
                                        0.2),
                                    // Shadow color
                                    spreadRadius: 2,
                                    // Spread radius
                                    blurRadius: 5,
                                    // Blur radius
                                    offset: const Offset(
                                        0, 2), // Shadow position
                                  ),
                                ],
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  // Add your onTap functionality here

                                },
                                child: Container(
                                  padding: EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          productImages[0],
                                          fit: BoxFit.cover,
                                          width: 120,
                                          height: 120,
                                        ),
                                      ),
                                      const SizedBox(width: 12.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            Text(
                                              productName,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 16.0,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4.0),
                                            Text(
                                              productDescription,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceBetween,
                                        children: [

                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Checkbox(
                                                value: isChecked[index],
                                                onChanged: (value) {
                                                  _error = '';
                                                  emptyCart = false;
                                                  setState(() {
                                                    if (value == true) {
                                                      isChecked[index] = true;
                                                      double v =  price * selectedQuantity;
                                                      subTotal += v.toInt();
                                                    } else {
                                                      isChecked[index] = false;
                                                      double v =  price * selectedQuantity;
                                                      subTotal -= v.toInt();
                                                    }
                                                  });
                                                },
                                                activeColor: isChecked[index]
                                                    ? _orangeColor
                                                    : Colors.grey,
                                              ),


                                              SizedBox(width: 8.0),
                                              IconButton(
                                                onPressed: () {
                                                  _error = '';
                                                  emptyCart = false;
                                                  setState(() {
                                                    if (isChecked[index] ==
                                                        true) {
                                                      double v =  price * selectedQuantity;
                                                      subTotal -= v.toInt();
                                                      isChecked[index] = false;
                                                    } else {
                                                      double v =  price * selectedQuantity;
                                                      subTotal += v.toInt();
                                                      isChecked[index] = true;
                                                    }
                                                  });
                                                },
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: !isChecked[index]
                                                      ? Colors.red
                                                      : Colors.grey,
                                                  size: 30.0,
                                                ),
                                              ),

                                            ],
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text(
                                            'Qty: $selectedQuantity',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 5.0),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '$calculatedPrice',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Icon(
                                                Icons.currency_rupee,
                                                color: _orangeColor,
                                                size: 16,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            );
                          }

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
                      child:   Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text('Subtotal: $subTotal',
                            style: const TextStyle(color: Colors.black,
                            fontSize: 16.0, fontWeight: FontWeight.bold),),
                            Text('Delivery Charges: $deliveryCharges',
                              style: const TextStyle(color: Colors.black,
                                  fontSize: 16.0, fontWeight: FontWeight.bold),),
                            Text('Total: $totalCharges',
                              style:  TextStyle(color: _orangeColor,
                                  fontSize: 16.0, fontWeight: FontWeight.bold),),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Now',style: TextStyle(color: _orangeColor, fontWeight: FontWeight.bold, fontSize: 18.0),),
                                const SizedBox(width: 5.0,),
                                const Icon(Icons.currency_rupee),
                                const SizedBox(width: 5.0,),
                                const Text('Cash on Delivery'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5.0,),
                    ElevatedButton(
                      onPressed: () {

                        late Map<int, Map<String, dynamic>> orderProducts = {};
                        int k = 0;
                        for(int i = 0; i < isChecked.length; i++) {
                          if(isChecked[i] == true) {
                            orderProducts[k] = cartProducts[i]!;
                            k++;
                          }
                        }
                        if(orderProducts.isNotEmpty) {
                          setState(() {
                            _error = '';
                          });
                        } else if(emptyCart){
                            Navigator.pop(context);
                        } else {
                          emptyCart = true;
                          setState(() {
                            _error = 'Do you want to Empty Cart!';
                          });
                        }

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _orangeColor,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart,
                            color: Colors.white,),
                          SizedBox(width: 10.0),
                          Text("CheckOut!",
                            style: TextStyle(color: Colors.white,
                                fontSize: 16.0, fontWeight: FontWeight.bold),),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5.0,),
                  ]
              ),
            )
        ),
      );
    } else {
      return const Loading_Screen();
    }
  }
}