import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:speedydrop/Screens/Home/Seller/homeSeller.dart';
import 'package:speedydrop/Screens/Loading/loading.dart';
import 'package:speedydrop/Services/Database/database.dart';
import '../../../Services/Auth/auth.dart';
import '../Home/Buyer/homeBuyer.dart';
import '../Home/Rider/homeRider.dart';
import 'dart:developer' as dev;


class UserAccount extends StatefulWidget {
  const UserAccount({Key? key}) : super(key: key);

  @override
  State<UserAccount> createState() => _UserAccountState();
}

class _UserAccountState extends State<UserAccount> {
  // Variables
  final Color _orangeColor = Colors.orange.shade800;
  String _error = '';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  final Auth_Service _auth_service = Auth_Service();
  String _name = '';
  String _email = '';
  String _phoneNumber = '';
  File? profileImage;
  String userId = '';
  String _profileImage = 'assets/images/speedyLogov1.png';
  bool isLoading = true;
  bool imageUpdated = false;

  LatLng _initialLocation = LatLng(0, 0); // Initial location at (0, 0)
  MapController _mapController = MapController();
  late LatLng _currentLocation;
  late LatLng _markerLocation;
  String _locationName = '';
  bool isBuyer = true;
  bool isSeller = false;
  bool isRider = false;
  ScrollController _scrollController = ScrollController();




// Functions
  @override
  void initState() {
    super.initState();
    _loadUserData(); // Call a function to load user data
  }


  Future<void> _loadUserData() async {
    // Fetch user data from Firestore
    Map<String, dynamic>? userData = await Database_Service(userId: Auth_Service().getUserId()).fetchUserDataFromCloud();
    // Initialize text fields with user data
    await initallizeTextFields(userData);
    // Set isLoading to false to indicate that data has been loaded
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
        imageUpdated = true;
      });
    }
  }


  Future<void> initallizeTextFields(Map<String, dynamic>? userData) async {

    String userIdFromFirestore = userData?['user-id'] ?? '';
    String userNameFromFirestore = userData?['user-name'] ?? '';
    String emailFromFirestore = userData?['email'] ?? '';
    String phoneNumberFromFirestore = userData?['phone-number'] ?? '';
    double latitudeFromFirestore = userData?['address']?['latitude'] ?? 0.0;
    double longitudeFromFirestore = userData?['address']?['longitude'] ?? 0.0;
    bool isBuyerFromFirestore = userData?['isBuyer'] ?? false;
    bool isSellerFromFirestore = userData?['isSeller'] ?? false;
    bool isRiderFromFirestore = userData?['isRider'] ?? false;
    String profileImageFromFirestore = userData?['profileImage'] ?? '';

    userId = userIdFromFirestore;
    _nameController.text = userNameFromFirestore;
    _emailController.text = emailFromFirestore;
    _phoneNumberController.text = phoneNumberFromFirestore;
    isBuyer = isBuyerFromFirestore;
    isSeller = isSellerFromFirestore;
    isRider = isRiderFromFirestore;
    _profileImage = profileImageFromFirestore;
    if (latitudeFromFirestore == 0.0 && longitudeFromFirestore == 0.0) {
      await _getCurrentLocation();
    } else {
      await _getCurrentLocation();
      await _initialPosition(LatLng(latitudeFromFirestore, longitudeFromFirestore));
    }
  }


  Future<void> _initialPosition(LatLng? latLng) async {
    if (latLng != null) {
      // Fetch address based on tapped coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      String locationName = placemarks.isNotEmpty ? placemarks[0].name ?? '' : '';
      setState(() {
        _currentLocation = latLng;
        _initialLocation = latLng;
        _markerLocation = latLng;
        _locationName = locationName;
      });
    }
  }


  void _handleTap(TapPosition? position, LatLng? latLng) async {
    if (latLng != null) {
      // Fetch address based on tapped coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      String locationName = placemarks.isNotEmpty ? placemarks[0].name ?? '' : '';
      setState(() {
        _initialLocation = latLng;
        _markerLocation = latLng;
        _locationName = locationName;
      });
    }
  }

  // Function to get current location
  // Update the _getCurrentLocation method
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    String locationName = placemarks[0].name ?? '';
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _initialLocation = _currentLocation;
      _markerLocation = _currentLocation;
      _locationName = locationName;
    });
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading == false) {
      return Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    SizedBox(width: 20.0,),
                    Center(
                      child: Text(
                        'Manage Your Account',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),


            ],
          ),
          leading: PopupMenuButton(
            icon: const Icon(Icons.menu),
            itemBuilder: (BuildContext context) =>
            [
              PopupMenuItem(
                value: 'return',
                child: Row(
                  children: [
                    Icon(Icons.arrow_back_ios,
                      color: _orangeColor,),
                    const SizedBox(width: 10.0,),
                    const Text('Return',
                      style: TextStyle(
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (String value) {
              if (value == 'return') {
                dev.log('Return');
                Navigator.pop(context);
              }
            },

          ),
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              const SizedBox(height: 10.0,),
              Text('Account Details',
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: _orangeColor
                ),),
              const SizedBox(height: 10.0,),
              GestureDetector(
                onTap: () {
                  _getImage();
                },
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _profileImage.isNotEmpty && !imageUpdated
                      ? Image.network(
                    _profileImage,
                    fit: BoxFit.cover,
                  )
                      : imageUpdated
                      ? Image.file(
                    profileImage!,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20.0),
                    color: Colors.grey.shade300,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 10.0),
                        Icon(Icons.add, size: 30.0),
                        Text(
                          'Add Profile Image',
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),


              Text(_error, style: const TextStyle(
                  color: Colors.red, fontWeight: FontWeight.bold),),
              const SizedBox(height: 5.0,),
              Form(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 60.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'your_name',
                          labelText: 'Name',
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                                width: 2.0,
                              )
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _orangeColor,
                              width: 2.0,
                            ),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          labelStyle: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.bold
                          ),
                          hintStyle: TextStyle(
                            color: Colors.grey.withOpacity(0.7),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 15.0),
                        ),
                        validator: (value) {
                          return value!.isEmpty ? 'Enter your Name' : null;
                        },
                      ),
                      const SizedBox(height: 10.0,),
                      TextFormField(
                        readOnly: true,
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'your_email@gmail.com',
                          labelText: 'Email',
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                                width: 2.0,
                              )
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _orangeColor,
                              width: 2.0,
                            ),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          labelStyle: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.bold
                          ),
                          hintStyle: TextStyle(
                            color: Colors.grey.withOpacity(0.7),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 15.0),
                        ),
                        validator: (value) {
                          return value!.isEmpty ? 'Enter Email' : null;
                        },
                      ),
                      const SizedBox(height: 10.0,),
                      TextFormField(
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\+|\d')),
                          LengthLimitingTextInputFormatter(12),
                        ],
                        decoration: InputDecoration(
                          hintText: '+923001234567',
                          labelText: 'Phone Number',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.shade400,
                              width: 2.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _orangeColor,
                              width: 2.0,
                            ),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          labelStyle: TextStyle(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                          hintStyle: TextStyle(
                            color: Colors.grey.withOpacity(0.7),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15.0,
                            horizontal: 15.0,
                          ),
                        ),
                        validator: (value) {
                          return value!.isEmpty ? 'Enter Phone Number' : null;
                        },
                      ),
                      const SizedBox(height: 10.0,),
                      const Text(
                        'User Account Roles',
                        style: TextStyle(fontSize: 16.0,
                            fontWeight: FontWeight.bold),
                      ),
                      Column(
                        children: [
                          // Other widgets...
                          Row(
                            children: [
                              Checkbox(
                                value: isBuyer,
                                onChanged: null, // Disable user interaction
                              ),
                              const Text('Buyer'),
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: isSeller,
                                onChanged: null, // Disable user interaction
                              ),
                              const Text('Seller'),
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: isRider,
                                onChanged: null, // Disable user interaction
                              ),
                              const Text('Rider'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0,),
                      const Text(
                        'Tap to Update Your Location',
                        style: TextStyle(fontSize: 16.0,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10.0),
                      Text(_locationName,style: const TextStyle(color: Colors.black),),
                      const SizedBox(height: 10.0),
                      SizedBox(
                        height: 200,
                        width: 300,
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            center: _currentLocation,
                            zoom: 13.0,
                            onTap: _handleTap,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                              // subdomains: ['a', 'b', 'c'],
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _initialLocation,
                                  width: 80.0,
                                  height: 80.0,
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: Colors.red,
                                    size: 50.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10.0,),
                      ElevatedButton(
                        onPressed: () async {
                          _name = _nameController.text;
                          _email = _emailController.text;
                          _phoneNumber = _phoneNumberController.text;
                          if (_name.isEmpty) {
                            // Handle the case where any of the fields are empty

                            _scrollController.animateTo(
                              0.0,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                            setState(() {
                              _error = 'Username is Mandatory!';
                            });

                          } else {
                            String link = _profileImage;
                            if (imageUpdated == true) {
                              setState(() {
                                _error = '';
                                isLoading = true;
                              });
                              link = await Database_Service(userId: userId)
                                  .uploadProfileImage(profileImage!);
                              if (link == '') {
                                setState(() {
                                  _error = 'Unable to upload Profile Photo';
                                  isLoading = false;
                                });
                                _scrollController.animateTo(
                                  0.0,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                                return;
                              }
                            }

                            bool isAccountUpdated = await Database_Service(
                                userId: userId).updateUserDataOnCloud(
                                _name, _phoneNumber, _markerLocation, link);
                            if (isAccountUpdated == true) {
                              dev.log('Account Updated Successfully');
                              Navigator.pop(context);
                              setState(() {
                                isLoading = false;
                              });

                            } else {
                              setState(() {
                                _error = 'Unable to Update Account';
                                isLoading = false;

                              });
                              _scrollController.animateTo(
                                0.0,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            }
                          }
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: _orangeColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40.0, vertical: 10.0),
                          elevation: 4.0,
                        ),
                        child: const Text('Update Profile',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold
                          ),),
                      ),
                      const SizedBox(height: 50.0,),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
    } else {
      return const Loading_Screen();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
  }


}