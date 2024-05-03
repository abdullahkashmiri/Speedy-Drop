import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:speedydrop/Screens/Home/Buyer/homeBuyer.dart';
import 'package:speedydrop/Screens/Loading/loading.dart';
import 'package:speedydrop/Services/Database/database.dart';
import '../../../Services/Auth/auth.dart';
import '../../Authentication/Sign In/signin.dart';

class ProductScreen extends StatefulWidget {
  final String locationName; // Add locationName
  final Map<String, dynamic> product; // Add product
  final String storeImage; // Add storeImage

  const ProductScreen({
    Key? key,
    required this.locationName,
    required this.product,
    required this.storeImage,
  }) : super(key: key);
  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {

  //Variables
  Color _orangeColor = Colors.orange.shade800;
  final Auth_Service _auth_service = Auth_Service();
  final String _profileImage = 'assets/images/speedyLogov1.png';
  bool isLoading = true;

  late String locationName;
  late String storeImage;
  late Map<String, dynamic> product;
  late String productId;
  late String vendorId;
  late String productName;
  late String description;
  late String category;
  late double price;
  late int quantity;
  late bool availability;
  late List<String> imagesUrls;
  int selectedQuantity = 0;
  int subTotal = 0;
  String _error = '';


  //Functions

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    locationName = widget.locationName;
    storeImage = widget.storeImage;
    product = widget.product;

    productId = product['product-id'];
    vendorId = product['vendor-id'];
    productName = product['product-name'];
    description = product['description'];
    price = product['price'];
    quantity = product['quantity'];
    availability = product['availability'];
    imagesUrls = List<String>.from(product['images']);
    category = product['category'];

    setState(() {
      isLoading = false;
    });
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
                child: Text(
                  locationName,
                  style: const TextStyle(
                    fontSize: 14.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),



              ClipRRect(
                borderRadius: BorderRadius.circular(10), // Adjust the border radius as needed
                child: storeImage == ''
                    ? Container( // Placeholder container if storeImageLink is empty
                  width: 40, // Adjust the width as needed
                  height: 40, // Adjust the height as needed
                  color: Colors.blue, // Set background color if storeImageLink is empty
                  child: Center(
                    child: Image.asset(_profileImage), // Use default image
                  ),
                )
                    : Image.network(
                  storeImage!,
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
                    Icon(Icons.switch_account,
                      color: _orangeColor,),
                    const SizedBox(width: 10.0,),
                    const Text('Home',
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
              if (value == 'buyer-mode') {
                dev.log('buyer-mode');
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) {
                  return const HomeScreenBuyer();
                }));
              }  else if (value == 'logout') {
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

        body:   Stack(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 20.0),
                    height: 300, // Adjust height as needed
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imagesUrls.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: Image.network(imagesUrls[index],
                                width: 300.0,
                                fit: BoxFit.cover,),
                          ),
                        );
                      },
                    ),
                  ),
                  // Product Name
                  const SizedBox(height: 2.0,),
                  Center(
                    child: Text(_error, style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),),
                  ),
                  const SizedBox(height: 2.0,),
                  Text(
                    productName,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Rs. $price' ,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,

                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const Expanded(child: SizedBox(width: 1.0,)),
                          Container(
                            decoration: BoxDecoration(
                                color: _orangeColor,
                                borderRadius: BorderRadius.circular(40.0)
                            ),
                            height: 40.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  padding: const EdgeInsets.all(0),
                                  // Adjust padding as needed
                                  onPressed: () {
                                    // Handle decrease quantity
                                    if(selectedQuantity > 0) {
                                      setState(() {
                                        selectedQuantity -= 1;
                                        double val = selectedQuantity * price;
                                        subTotal = val.toInt() ;
                                      });
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                    size: 20, // Adjust size as needed
                                  ),
                                ),
                                Text(
                                  selectedQuantity.toString(),
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                  ),
                                ),
                                IconButton(
                                  padding: const EdgeInsets.all(0),
                                  // Adjust padding as needed
                                  onPressed: () {
                                    // Handle increase quantity
                                    if(quantity > selectedQuantity) {
                                      setState(() {
                                        selectedQuantity += 1;
                                        double val = selectedQuantity * price;
                                        subTotal = val.toInt() ;
                                      });
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 20, // Adjust size as needed
                                  ),
                                ),
                              ],
                            ),
                          ),

                        ]
                    ),
                  ),
                  Text(
                    category,
                    style: TextStyle(
                        color: _orangeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.0,),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey.shade700
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),

                ],
              ),

            ),



            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 20.0),
                  child: Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'SubTotal Rs: ',
                              style: TextStyle(
                                color: _orangeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            TextSpan(
                              text: '$subTotal',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: SizedBox(width: 1.0,)),
                      ElevatedButton(
                        onPressed: () async {
                          // Handle add to cart
                          if(selectedQuantity > 0 && selectedQuantity < quantity && subTotal > 0){
                            setState(() {
                              _error = '';
                              isLoading = true;
                            });
                              await Database_Service(userId: _auth_service.getUserId()).uploadDataInCartOnCloud(productId, vendorId, category, selectedQuantity);
                              Navigator.pop(context);
                              setState(() {
                              isLoading = true;
                            });
                          } else {
                            setState(() {
                              _error = 'No Product Selected';
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _orangeColor,
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.shopping_cart,
                            color: Colors.white,),
                            Text("Add to Cart",
                            style: TextStyle(color: Colors.white,
                                fontSize: 16.0, fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),


      );
    } else {
      return const Loading_Screen();
    }
  }
}