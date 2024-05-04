import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:speedydrop/Screens/Account/user_account.dart';
import 'package:speedydrop/Screens/Authentication/Sign%20In/signin.dart';
import 'package:speedydrop/Screens/Loading/loading.dart';
import 'package:speedydrop/Services/Auth/auth.dart';
import 'package:speedydrop/Services/Database/database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../Home/Buyer/homeBuyer.dart';
import '../Cart Screen/cart_screen.dart';


class DisplayCartScreen extends StatefulWidget {
  const DisplayCartScreen({
    Key? key,
  }) : super(key: key);
  @override
  State<DisplayCartScreen> createState() => _DisplayCartScreenState();
}

class _DisplayCartScreenState extends State<DisplayCartScreen> {

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
  late Map<int, Map<String, dynamic>> cartProductsSorted = {};
  late Map<int, Map<String, dynamic>> cartProductsVendor = {};
  bool isLoading = true;
  late List<bool> isChecked;
  late List<bool> isDeleteButtonRed;

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


  Map<int, Map<String, dynamic>> removeDuplicates() {
    Map<String, Map<String, dynamic>> uniqueProducts = {};

    cartProducts.forEach((index, productData) {
      final String productId = productData['product-id'];
      final int selectedQuantity = productData['selected-quantity'] ?? 0;

      if (uniqueProducts.containsKey(productId)) {
        print("Contained id : $productId");
        uniqueProducts[productId]!['selected-quantity'] = (uniqueProducts[productId]!['selected-quantity'] ?? 0) + selectedQuantity;
      } else {
        uniqueProducts[productId] = {
          'product-id': productId,
          'vendor-id': productData['vendor-id'],
          'product-name': productData['product-name'],
          'description': productData['description'],
          'price': productData['price'],
          'quantity': productData['quantity'],
          'availability': productData['availability'],
          'images': List<String>.from(productData['images']),
          'selected-quantity': selectedQuantity,
          'category': productData['category']
        };
      }
    });

    int index = 0;
    // Create a new map with simple numerical indices
    Map<int, Map<String, dynamic>> newUniqueProducts = {};
    uniqueProducts.forEach((key, value) {
      newUniqueProducts[index++] = value;
    });

    return newUniqueProducts;
  }

  void removeZeroQuantityItems() {
    int newIndex = 0;
    final Map<int, Map<String, dynamic>> updatedCartProducts = {};

    cartProducts.forEach((index, productData) {
      final int quantity = productData['quantity'] ?? 0;

      // Only add items with quantity greater than 0
      if (quantity > 0) {
        updatedCartProducts[newIndex++] = productData;
      }
    });

    // Update the original cartProducts map
    cartProducts = updatedCartProducts;
  }

  Future<void> initializeData() async {
    // Fetch cart products
    cartProducts = await Database_Service(userId: _auth_service.getUserId())
        .fetchAllProductDetailsOfCart();

    cartProducts = removeDuplicates();
    removeZeroQuantityItems();

    Set<String> uniqueVendorIds = Set();

    cartProducts.values.forEach((productMap) {
      if (productMap.containsKey('vendor-id')) {
        uniqueVendorIds.add(productMap['vendor-id']);
      }
    });

    List<String> vendorIds = uniqueVendorIds.toList();
    int k = 0;
    for (int i = 0; i < vendorIds.length; i++) {
      for (int j = 0; j < cartProducts.length; j++) {
        if (cartProducts[j]?['vendor-id'] == vendorIds[i]) {
          cartProductsSorted[k] = cartProducts[j]!;
          k++;
        }
      }
    }


    isChecked = List.filled(cartProductsSorted.length, false);
    isDeleteButtonRed =  List.filled(cartProductsSorted.length, false);

    // Get current location
    await _getCurrentLocation();

    // Update UI state
    setState(() {
      isLoading = false;
    });

  }

  void getVendorProducts(String selectedVendorId) {
    int k = 0;
    for (int j = 0; j < cartProducts.length; j++) {
      if (cartProducts[j]?['vendor-id'] == selectedVendorId) {
        cartProductsVendor[k] = cartProducts[j]!;
        k++;
      }
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


              IconButton(onPressed: () async {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DisplayCartScreen()));
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
                    const SizedBox(height: 10.0,),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Products',
                            style: TextStyle(
                                color: _orangeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 25.0
                            ),
                          ),
                          const TextSpan(
                            text: ' In Cart!',
                            style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.black
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10.0,),
                    const Center(
                      child: Text('Select Store to Proceed!',
                        style: TextStyle(fontWeight: FontWeight.bold),),
                    ),
                    const SizedBox(height: 10.0,),
                    Expanded(
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: cartProductsSorted.length,
                          itemBuilder: (context, index) {
                            Map<String,
                                dynamic>? product = cartProductsSorted[index];


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
                            String category = product?['category'] ?? '';


                            if(selectedQuantity > productQuantity) {
                              selectedQuantity = productQuantity;
                            }
                            cartProducts[index]?['selected-quantity'] = selectedQuantity;

                            if (index == 0 ||
                                (cartProductsSorted[index - 1]?['vendor-id'] ==
                                    vendorId)) {
                              return Column(
                                children: [
                                  index == 0
                                      ?   Center(child:     ElevatedButton(
                                    onPressed: ()  {
                                      cartProductsVendor.clear();
                                      getVendorProducts(vendorId);
                                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                                        return CartScreen(cart_products: cartProductsVendor, vendor_id: vendorId);
                                      }));
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
                                        Text("Continue with this Store",
                                          style: TextStyle(color: Colors.white,
                                              fontSize: 16.0, fontWeight: FontWeight.bold),),
                                      ],
                                    ),
                                  ),)
                                      : Container(),


                                  Container(
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
                                    child:      Container(
                                      padding: EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                                const SizedBox(height: 5.0),
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
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Qty: $selectedQuantity',
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 10.0),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    '$calculatedPrice',
                                                    style: TextStyle(
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

                                  )

                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  Center(child:     ElevatedButton(
                                    onPressed: ()  {
                                      cartProductsVendor.clear();
                                      getVendorProducts(vendorId);
                                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                                        return CartScreen(cart_products: cartProductsVendor, vendor_id: vendorId);
                                      }));
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
                                        Text("Continue with this Store",
                                          style: TextStyle(color: Colors.white,
                                              fontSize: 16.0, fontWeight: FontWeight.bold),),
                                      ],
                                    ),
                                  ),),
                                  Container(
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
                                    child:      Container(
                                      padding: EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                                const SizedBox(height: 5.0),
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
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Qty: $selectedQuantity',
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 10.0),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    '$calculatedPrice',
                                                    style: TextStyle(
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

                                  )
                                ],
                              );
                            }
                          }

                      ),
                    ),


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