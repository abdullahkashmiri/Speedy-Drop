import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:speedydrop/Screens/Account/user_account.dart';
import 'package:speedydrop/Screens/Home/Buyer/homeBuyer.dart';
import 'package:speedydrop/Screens/Loading/loading.dart';
import 'package:speedydrop/Services/Database/database.dart';
import '../../../Services/Auth/auth.dart';
import '../../Authentication/Sign In/signin.dart';
import '../../Products/New Product/new_product.dart';
import '../../Store/Open a New Store/open_store.dart';
import '../Rider/homeRider.dart';

class HomeScreenSeller extends StatefulWidget {
  final String previousScreen;
  const HomeScreenSeller({Key? key, required this.previousScreen});

  @override
  State<HomeScreenSeller> createState() => _HomeScreenSellerState();
}

class _HomeScreenSellerState extends State<HomeScreenSeller> {

  //Variables
  String previousScreen = '';
  Color _orangeColor = Colors.orange.shade800;
  final Auth_Service _auth_service = Auth_Service();
  String _profileImage = 'assets/images/speedyLogov1.png';
  bool isSeller = true;
  bool isLoading = true;
  double isDeleting = 0.0;
  bool isDataLoaded = true;
  late List<Map<String, dynamic>> products;
  String deleteProductId = '';
  String deleteCategory = '';


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
  String ?locationName = 'Unable to get Store Location';
  String profilePhoto = '';

  //Functions

  @override
  void initState() {
    super.initState();
    previousScreen = widget.previousScreen;
    isUserASeller();
  }


  Future<void> isUserASeller() async {
    isSeller =
    await Database_Service(userId: _auth_service.getUserId()).isUserASeller();

    if(isSeller) {
      await storeDataInitialized();
      await productDataInitialized();
    }
      setState(() {
      isLoading = false;
    });
  }
  Future<void> storeDataInitialized() async {
    try {
      // Fetch store data
      Map<String, dynamic>? storeData = await Database_Service(userId: _auth_service.getUserId()).fetchStoreData();

      if (storeData != null) {
        // Extract data into variables
        ownerId = storeData['owner-id'];
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
        setState(() {

        });
      } else {
        print('Failed to fetch store data');
      }
    } catch (e) {
      print('Error occurred while initializing and fetching store data: $e');
    }
  }
  Future<void> productDataInitialized() async {
    products = await Database_Service(userId: _auth_service.getUserId())
        .fetchAllProductsOfSeller();
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
                  locationName!,
                  style: const TextStyle(
                    fontSize: 14.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // IconButton(
              //   icon: const Icon(Icons.keyboard_arrow_down, size: 30.0,),
              //   onPressed: () {
              //     // ----------------------------- location update
              //   },
              // ),
              IconButton(onPressed: () async {
                isLoading = true;
                isDataLoaded = false;
                setState(() {

                });
                await productDataInitialized();
                isLoading = false;
                isDataLoaded = true;
                setState(() {

                });
              },
                  icon: Icon(Icons.refresh)),
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
                ) ,
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

        body: isSeller ? Stack(
          children: [
            isDataLoaded ?
            Padding(
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
                    child: Center(
                      child: Text(
                        storeName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ) : Container(),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Your Products',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),),
                  ),
                  isLoading == false ?
                  Expanded(
                    child: ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> product = products[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              isDeleting = 1.0;
                              deleteProductId = product['product-id'];
                              deleteCategory = product['category'];
                            });
                          },
                          child: Card(
                            elevation: 4,
                            // Add elevation for a shadow effect
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0), // Rounded corners
                            ),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Display product image (assuming 'images' is a list of image URLs)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      product['images'][0], // Assuming the first image URL is used
                                      width: 90.0,
                                      height: 90.0,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 8.0), // Add some space between image and text
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['product-name'],
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          product['description'],
                                          style: const TextStyle(
                                            fontSize: 12.0,
                                          ),
                                          maxLines: 2, // Display only two lines for description
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Category: ${product['category']}',
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: _orangeColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Price: ${product['price']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),


                    // child: GridView.builder(
                    //   itemCount: products.length,
                    //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    //     crossAxisCount: 3, // Two products per row
                    //     mainAxisSpacing: 5.0,
                    //     crossAxisSpacing: 5.0,
                    //     childAspectRatio: 0.7, // Aspect ratio for better layout
                    //   ),
                    //   itemBuilder: (context, index) {
                    //     Map<String,
                    //         dynamic> product = products[index];
                    //     return Card(
                    //       elevation: 4,
                    //       // Add elevation for a shadow effect
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(
                    //             10.0), // Rounded corners
                    //       ),
                    //       color: Colors.white,
                    //       child: Column(
                    //         crossAxisAlignment: CrossAxisAlignment
                    //             .start,
                    //         children: [
                    //           // Display product image (assuming 'images' is a list of image URLs)
                    //           ClipRRect(
                    //             borderRadius: const BorderRadius
                    //                 .vertical(
                    //                 top: Radius.circular(10.0)),
                    //             child: Image.network(
                    //               product['images'][0],
                    //               // Assuming the first image URL is used
                    //               width: double.infinity,
                    //               height: 90.0,
                    //               fit: BoxFit.cover,
                    //             ),
                    //           ),
                    //           Padding(
                    //             padding: const EdgeInsets.all(3.0),
                    //             child: Column(
                    //               crossAxisAlignment: CrossAxisAlignment
                    //                   .start,
                    //               children: [
                    //                 Text(
                    //                   product['product-name'],
                    //                   style: const TextStyle(
                    //                     fontSize: 12.0,
                    //                     fontWeight: FontWeight.bold,
                    //                   ),
                    //                 ),
                    //                 Text(
                    //                   '${product['category']}',
                    //                   style: TextStyle(
                    //                       fontSize: 10.0,
                    //                       color: _orangeColor,
                    //                       fontWeight: FontWeight.bold
                    //                   ),
                    //                   maxLines: 1, // Display only one line
                    //                   overflow: TextOverflow.ellipsis,
                    //                 ),
                    //                 Text(
                    //                   'Price: ${product['price']}',
                    //                   style: const TextStyle(
                    //                     fontSize: 10.0,
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         ],
                    //       ), // Set the background color of the card
                    //     );
                    //   },
                    // ),
                  ) : Container()
                ],
              ),
            ) : Container(),
            Positioned(
              bottom: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  // Navigator.push(
                  //     context, MaterialPageRoute(builder: (context) {
                  //   return const ManageStore();
                 // }));
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const NewProductScreen();
                  }));
                  },
                style: ElevatedButton.styleFrom(
                    backgroundColor: _orangeColor,
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0)
                ),
                child:   Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 16, // Adjust the size of the circle avatar as needed
                      backgroundImage: NetworkImage(storeImageLink!),
                    ),
                    const SizedBox(width: 8.0),
                    const Text('Add New Products',
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      ),
                    ),
                    const SizedBox(width: 2.0,),
                    const Icon(Icons.store,
                      color: Colors.white,),
                  ],
                ),),
            ),
            Opacity(
              opacity: isDeleting,
              child: Center(
                child: Container(
                  child:  Container(
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
                            Icon(Icons.production_quantity_limits,
                              color: _orangeColor,
                              size: 30.0,),
                            const SizedBox(width: 10.0,),
                            const Text(
                              'Delete this Product', style: TextStyle(
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
                              onPressed: () async {
                                setState(() {
                                  isLoading = true;
                                  isDataLoaded = false;
                                });
                                await Database_Service(userId: _auth_service.getUserId()).deleteProduct(deleteCategory, deleteProductId);
                                // redirect to page first for adding necessary details of the store -------------------
                                // Navigator.push(context,
                                //     MaterialPageRoute(builder: (context) {
                                //       return const OpenStore();
                                //     }));
                                //Database_Service(userId: _auth_service.getUserId()).createSellerMode();
                                await productDataInitialized();
                                setState(() {
                                  isDeleting = 0.0;
                                  deleteCategory = '';
                                  deleteProductId = '';
                                  isDataLoaded = true;
                                  isLoading = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Delete',
                                style: TextStyle(color: Colors.white,),
                              ),
                            ),
                            const SizedBox(width: 10.0,),
                            ElevatedButton(
                              onPressed: () {
                               setState(() {
                                 isDeleting = 0.0;
                                 deleteCategory = '';
                                 deleteProductId = '';
                               });
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: _orangeColor
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
              ),
            )
          ],
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
                    Icon(Icons.store,
                      color: _orangeColor,
                      size: 30.0,),
                    const SizedBox(width: 10.0,),
                    const Text(
                      'Open your Store Now', style: TextStyle(
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
                        // redirect to page first for adding necessary details of the store -------------------
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return const OpenStore();
                            }));
                        //Database_Service(userId: _auth_service.getUserId()).createSellerMode();
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('Open Store',
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
                        } else if (previousScreen == 'homeRider') {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                                return const HomeScreenRider();
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
