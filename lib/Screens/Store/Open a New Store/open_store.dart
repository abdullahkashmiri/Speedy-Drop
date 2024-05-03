import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speedydrop/Screens/Home/Seller/homeSeller.dart';
import 'package:speedydrop/Screens/Loading/loading.dart';
import 'package:speedydrop/Services/Database/database.dart';
import '../../../../Services/Auth/auth.dart';
import '../../Account/user_account.dart';
import '../../Authentication/Sign In/signin.dart';
import '../../Home/Buyer/homeBuyer.dart';
import '../../Home/Rider/homeRider.dart';
import 'dart:developer' as dev;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';




class OpenStore extends StatefulWidget {
  const OpenStore({Key? key}) : super(key: key);

  @override
  State<OpenStore> createState() => _OpenStoreState();
}

class _OpenStoreState extends State<OpenStore> {
  // Variables
  final Color _orangeColor = Colors.orange.shade800;
  String _error = '';
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _storeDescriptionController = TextEditingController();

  final Auth_Service _auth_service = Auth_Service();
  String _storeName = '';
  String _storeDescription = '';
  File? storeImage;
  List<String> _selectedDays = [];
  String _selectedOpeningHour = '9:00 AM';
  String _selectedClosingHour = '6:00 PM';


  final List<String> _daysOfWeek = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  final List<String> _hoursOfDay = [
    '12:00 AM',
    '1:00 AM',
    '2:00 AM',
    '3:00 AM',
    '4:00 AM',
    '5:00 AM',
    '6:00 AM',
    '7:00 AM',
    '8:00 AM',
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
    '6:00 PM',
    '7:00 PM',
    '8:00 PM',
    '9:00 PM',
    '10:00 PM',
    '11:00 PM',
  ];

  final String _profileImage = 'assets/images/speedyLogov1.png';
  bool isLoading = true;



  LatLng _initialLocation = LatLng(0, 0); // Initial location at (0, 0)
  MapController _mapController = MapController();
  late LatLng _currentLocation;
  late LatLng _markerLocation;
  String _locationName = '';
  ScrollController _scrollController = ScrollController();

// Functions

  void initState() {
    super.initState();
    _getCurrentLocation(); // Fetch the user's current location when the widget initializes

  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        storeImage = File(pickedFile.path);
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
              const Expanded(
                child: Row(
                  children: [
                    SizedBox(width: 20.0,),
                    Center(
                      child: Text(
                        'Open Your Store',
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

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserAccount()),
                  );
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage(_profileImage),
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
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                  return const HomeScreenBuyer();
                }));
              }  else if (value == 'rider-mode') {
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

            },

          ),
        ),


        body: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              const SizedBox(height: 10.0,),
              Text('Store Details',
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
                  child: storeImage != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      storeImage!,
                      fit: BoxFit.cover,
                    ),
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
                          'Add Store Image',
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
                        controller: _storeNameController,
                        decoration: InputDecoration(
                          hintText: 'your_store_name',
                          labelText: 'Store Name',
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
                          return value!.isEmpty ? 'Enter Store Name' : null;
                        },
                      ),
                      const SizedBox(height: 10.0,),
                      TextFormField(
                        controller: _storeDescriptionController,
                        decoration: InputDecoration(
                          hintText: 'product_description',
                          labelText: 'Description',
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
                          return value!.isEmpty ? 'Enter Description' : null;
                        },
                      ),
                      const SizedBox(height: 10.0,),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Days Open:',
                            style: TextStyle(fontSize: 16.0,
                            fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10.0),
                          Wrap(
                            spacing: 10.0,
                            children: _daysOfWeek.map((String day) {
                              return FilterChip(
                                label: Text(day),
                                selected: _selectedDays.contains(day),
                                onSelected: (bool selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedDays.add(day);
                                    } else {
                                      _selectedDays.remove(day);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          Row(
                            children: [
                              const Text(
                                'Opening Hour:',
                                style: TextStyle(fontSize: 16.0),
                              ),
                              const SizedBox(width: 10.0,),
                              DropdownButton<String>(
                                value: _selectedOpeningHour,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedOpeningHour = newValue!;
                                  });
                                },
                                items: _hoursOfDay.map((String hour) {
                                  return DropdownMenuItem<String>(
                                    value: hour,
                                    child: Text(hour),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text(
                                'Closing Hour:',
                                style: TextStyle(fontSize: 16.0),
                              ),
                              const SizedBox(width: 10.0,),
                              DropdownButton<String>(
                                value: _selectedClosingHour,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedClosingHour = newValue!;
                                  });
                                },
                                items: _hoursOfDay.map((String hour) {
                                  return DropdownMenuItem<String>(
                                    value: hour,
                                    child: Text(hour),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 5.0,),
                      const Text(
                        'Tap on Your Store Location',
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

                      const SizedBox(height: 15.0,),
                      ElevatedButton(
                        onPressed: () async {
                          print('Create Store Button');

                          _storeName = _storeNameController.text;
                          _storeDescription = _storeDescriptionController.text;
                          if (_storeName.isNotEmpty && _storeDescription.isNotEmpty && _selectedDays.isNotEmpty &&
                              storeImage != null && File(storeImage!.path).existsSync()) {
                            setState(() {
                              _error = '';
                              isLoading = true;
                            });
                            String isPhoneValid = await Database_Service(
                                userId: _auth_service.getUserId())
                                .getPhoneNumberOfUser();
                            print('phone valid');

                            if (isPhoneValid == '') {
                              setState(() {
                                _error =
                                'Please Add Phone Number in Manage Accounts.';
                                isLoading = false;
                              });
                              _scrollController.animateTo(
                                0.0,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                              return;
                            }
                            bool isStoreAdded = await Database_Service(
                                userId: _auth_service.getUserId())
                                .createSellerMode
                              (
                                _storeName,
                                _storeDescription,
                                _selectedDays,
                                _selectedOpeningHour,
                                _selectedClosingHour,
                                _markerLocation,
                                isPhoneValid,
                                storeImage!);
                            if (isStoreAdded == true) {
                              dev.log('Store created SuccessFully');
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => HomeScreenSeller(previousScreen: 'home-screen')),
                                    (route) => false, // Remove all routes in the stack
                              );


                              isLoading = false;
                              setState(() {

                              });
                            } else {
                              _error = 'Unable to create A Store';
                            }
                            setState(() {
                              isLoading = false;
                            });
                            _scrollController.animateTo(
                              0.0,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          }
                          else {
                            setState(() {
                              _error = 'Please Fill All Fields';
                            });
                            _scrollController.animateTo(
                              0.0,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          }
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: _orangeColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40.0, vertical: 10.0),
                          elevation: 4.0,
                        ),
                        child: const Text('Open Store',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold
                          ),),
                      ),
                      SizedBox(height: 50.0,),
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
    _storeNameController.dispose();
    _storeDescriptionController.dispose();

  }

}