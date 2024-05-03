import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speedydrop/Screens/Loading/loading.dart';

import '../../../Services/Auth/auth.dart';
import '../../Account/user_account.dart';
import '../../Authentication/Sign In/signin.dart';
import '../../Home/Buyer/homeBuyer.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> currentOrder;
  final String status;

  const OrderDetailsScreen({Key? key, required this.currentOrder, required this.status}) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}


class _OrderDetailsScreenState extends State<OrderDetailsScreen> {

  //Variables
  Color _orangeColor = Colors.orange.shade800;
  final Auth_Service _auth_service = Auth_Service();
  String _currentAddress = '';
  final String _profileImage = 'assets/images/speedyLogov1.png';
  String profilePhoto = '';
  String userId = '';
  double latitude = 0.0;
  double longitude = 0.0;
  bool isLoading = true;
  late Map<String, dynamic> currentOrderData;
  late List<Map<String, dynamic>> orderProducts;
  late int deliveryCharges;
  late int totalCharges;
  late int deliveryTime;
  late String storeName;
  late String storeImageLink;
  late String orderCreationTime;
  late String status;


  //Functions
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    initializeData();
  }

  Future<void> initializeData() async {
    // Fetch
    currentOrderData = widget.currentOrder;
    status = widget.status;
    // Assign the values from currentOrderData to variables
    orderProducts = (currentOrderData['orderProducts'] as List<dynamic>).cast<Map<String, dynamic>>();;
    deliveryCharges = currentOrderData['deliveryCharges'];
    totalCharges = currentOrderData['totalCharges'];
    deliveryTime = currentOrderData['deliveryTime'];
    storeName = currentOrderData['storeName'];
    storeImageLink = currentOrderData['storeImageLink'];
    orderCreationTime = currentOrderData['orderCreationTime'];

    // fetching in a loop all order products
    // Map<String, dynamic>? product = orderProducts[index];
    // String productId = product?['product-id'];
    // String vendorId = product?['vendor-id'];
    // String productName = product?['product-name'];
    // String productDescription = product?['description'];
    // double price = product?['price'];
    // int productQuantity = product?['quantity'];
    // bool availability = product?['availability'];
    // List<String> productImages = List<
    //     String>.from(product?['images']);
    // int selectedQuantity = product?['selected-quantity'];
    // double val = selectedQuantity * price;
    // int calculatedPrice = val.toInt();

    setState(() {
      isLoading = false;
    });

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
              log('buyer-mode');
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) {
                return const HomeScreenBuyer();
              }));
            } else if (value == 'logout') {
              log('logout');
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

      body: isLoading ? const Loading_Screen() :


      Container(
        margin: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: status == 'placed' ? Colors.white : (status == 'delivering' ? Colors.orange.shade100 : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 100,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          image: NetworkImage(storeImageLink),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      storeName,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    SizedBox(
                      width: 270,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 16.0, color: Colors.black),
                                  children: [
                                    const TextSpan(text: 'Date: '),
                                    TextSpan(
                                      text: orderCreationTime,
                                      style: TextStyle(color: _orangeColor, fontWeight: FontWeight.bold), // Use orange color for the value
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.calendar_month, color: _orangeColor,),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 16.0, color: Colors.black),
                                  children: [
                                    const TextSpan(text: 'Est. Delivery Time: '),
                                    TextSpan(
                                      text: '$deliveryTime',
                                      style: TextStyle(color: _orangeColor, fontWeight: FontWeight.bold), // Use orange color for the value
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.timer, color: _orangeColor,),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Order Status: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _orangeColor,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    TextSpan(
                                      text: status == 'placed' ? 'Placed' : (status == 'delivering' ? 'Delivering' : 'Delivered'),
                                      style: TextStyle(
                                        color: status == 'placed' ? _orangeColor : (status == 'delivering' ? Colors.green : (status == 'delivered' ? Colors.blue : Colors.white)),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 5.0,),
                              Icon(
                                status == 'placed' ? Icons.check_circle_outline : (status == 'delivering' ? Icons.directions_bike_outlined : (status == 'delivered' ? Icons.check_circle : Icons.cabin)),
                                color: status == 'placed' ? _orangeColor : (status == 'delivering' ? Colors.green : (status == 'delivered' ? Colors.blue : Colors.white)),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5.0,),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: orderProducts.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic>? product = orderProducts[index];

                  String productId = product['product-id'];
                  String vendorId = product['vendor-id'];
                  String productName = product['product-name'];
                  String productDescription = product['description'];
                  double price = product['price'];
                  int productQuantity = product['quantity'];
                  bool availability = product['availability'];
                  List<String> productImages = List<String>.from(product['images']);
                  int selectedQuantity = product['selected-quantity'];
                  double val = selectedQuantity * price;
                  int calculatedPrice = val.toInt();

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 5.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              productImages[0],
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: _orangeColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  productDescription,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14.0,
                                  ),
                                ),
                                RichText(
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14.0,
                                    ),
                                    children: [
                                      const TextSpan(text: 'Sub.T Price:  ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                      TextSpan(text: '$calculatedPrice', style: TextStyle(color: _orangeColor, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                RichText(
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14.0,
                                    ),
                                    children: [
                                      const TextSpan(text: 'Quantity:      ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                      TextSpan(text: '$selectedQuantity', style: TextStyle(color: _orangeColor, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: status == 'placed' ? Colors.white : (status == 'delivering' ? Colors.orange.shade100 : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: 270,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 16.0, color: Colors.black),
                                  children: [
                                    const TextSpan(text: 'Total Charges: '),
                                    TextSpan(
                                      text: '$totalCharges',
                                      style: TextStyle(color: _orangeColor, fontWeight: FontWeight.bold), // Use orange color for the value
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.currency_rupee, color: _orangeColor,),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 16.0, color: Colors.black),
                                  children: [
                                    const TextSpan(text: 'Delivery Charges: '),
                                    TextSpan(
                                      text: '$deliveryCharges',
                                      style: TextStyle(color: _orangeColor, fontWeight: FontWeight.bold), // Use orange color for the value
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.currency_rupee, color: _orangeColor,),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),


    );
  }

}
