import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speedydrop/Screens/Loading/loading.dart';
import 'package:speedydrop/Screens/Order/Order%20Details/orderDetailsScreen.dart';
import 'package:speedydrop/Services/Database/database.dart';

import '../../../Services/Auth/auth.dart';
import '../../Account/user_account.dart';
import '../../Authentication/Sign In/signin.dart';
import '../../Home/Buyer/homeBuyer.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {

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
  bool isLoading = true;
  List<Map<String, dynamic>> orders = [];
  String _error = '';

  //Functions
  @override
  void initState() {
    super.initState();
    initializeData();
  }


  Future<void> initializeData() async {
    // Fetch
    orders = await Database_Service(userId: _auth_service.getUserId()).fetchOrdersFromCloud();
    print("Orders");
    print(orders.length);
    setState(() {
      isLoading = false;
    });
  }



  @override
  Widget build(BuildContext context) {
    if(isLoading == false) {
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
                            text: 'Order',
                            style: TextStyle(
                                color: _orangeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 25.0
                            ),
                          ),
                          const TextSpan(
                            text: ' to view Details!',
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
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            // Assuming orders is your List<Map<String, dynamic>>
                            orders.sort((a, b) {
                              // Extract orderCreationTime from each map
                              String orderTimeA = a['orderCreationTime'];
                              String orderTimeB = b['orderCreationTime'];

                              // Convert orderCreationTime strings to DateTime objects
                              DateTime dateTimeA = DateFormat('dd/MM/yyyy hh:mm a').parse(orderTimeA);
                              DateTime dateTimeB = DateFormat('dd/MM/yyyy hh:mm a').parse(orderTimeB);

                              // Compare the DateTime objects in descending order
                              return dateTimeB.compareTo(dateTimeA);
                            });


                            if(orders.isNotEmpty) {
                              Map<String, dynamic> order = orders[index];

                              if (order.isNotEmpty && order['storeName'] != null && order['storeImageLink'] != null && order['totalCharges'] != null && order['deliveryTime'] != null && order['orderCreationTime'] != null && order['currentStage'] != null) {
                                String storeName = order['storeName'] as String;
                                String storeImageLink = order['storeImageLink'] as String;
                                int totalCharges = order['totalCharges'] as int;
                                int deliveryTime = order['deliveryTime'] as int;
                                String orderPlace = order['orderCreationTime'];
                                String status = order['currentStage'];
                                return Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      decoration: BoxDecoration(
                                        color: status == 'placed' ? Colors.white : (status == 'delivering' ? Colors.orange.shade100 : Colors.grey.shade300),
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
                                          Map<String, dynamic> currentOrder = orders[index];
                                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                                            return OrderDetailsScreen(currentOrder: currentOrder, status: status,);
                                          }));
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
                                                  storeImageLink,
                                                  fit: BoxFit.cover,
                                                  width: 110,
                                                  height: 110,
                                                ),
                                              ),
                                              const SizedBox(width: 12.0),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    Text(
                                                      storeName,
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
                                                      'Est. $deliveryTime mins',
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                      style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 14.0,
                                                      ),
                                                    ),
                                                    Text(
                                                      '$orderPlace',
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14.0,
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          'Charges: $totalCharges',
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
                                                    Row(
                                                      children: [
                                                        Text(status == 'placed' ? 'Placed' : (status == 'delivering' ? 'Delivering' :   'Delivered'  ),
                                                        style: TextStyle(
                                                          color: status == 'placed' ? _orangeColor : (status == 'delivering' ? Colors.green : (status == 'delivered' ? Colors.blue : Colors.white)),
                                                        fontWeight: FontWeight.bold),),
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

                                    );
                              }
                              else{
                                return Container();
                              }
                            }
                           else {
                             return Container();
                            }


                          }

                      ),
                    ),

                    // ElevatedButton(
                    //   onPressed: () async {},
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: _orangeColor,
                    //   ),
                    //   child: const Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       Icon(Icons.shopping_cart,
                    //         color: Colors.white,),
                    //       SizedBox(width: 10.0),
                    //       Text("CheckOut!",
                    //         style: TextStyle(color: Colors.white,
                    //             fontSize: 16.0, fontWeight: FontWeight.bold),),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(height: 5.0,),
                  ]
              ),
            )
        ),

      );
    } else {
      return Loading_Screen();
    }
  }

}
