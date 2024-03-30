import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:speedydrop/Screens/Account/buyer_account.dart';
import 'package:speedydrop/Screens/Authentication/Sign%20In/signin.dart';
import 'package:speedydrop/Screens/Home/homeSeller.dart';
import 'package:speedydrop/Services/Auth/auth.dart';
import 'homeRider.dart';


class HomeScreenBuyer extends StatefulWidget {
  const HomeScreenBuyer({super.key});

  @override
  State<HomeScreenBuyer> createState() => _HomeScreenBuyerState();
}

class _HomeScreenBuyerState extends State<HomeScreenBuyer> {

  //Variables
  Color _orangeColor = Colors.orange.shade800;
  final Auth_Service _auth_service = Auth_Service();
  String _currentLocation = 'DHA EME Society, Lahore';
  String _profileImage = 'assets/images/speedyLogov1.png';
  String _userName = 'Usman Faisal';
  final List<Map<String, String>> itemList = [
    {
      "name": 'Nike',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg'
    },
    {
      "name": 'Adidas',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg'
    },
    {
      "name": 'Apple',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg'
    },
    {
      "name": 'Samsung',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg'
    },
    {
      "name": 'Gucci',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg'
    },
    {
      "name": 'Louis Vuitton',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg'
    },
    {
      "name": 'H&M',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg'
    },
    {
      "name": 'Zara',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg'
    },
    {
      "name": 'Amazon',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg'
    },
    {
      "name": 'Sony',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg'
    },
  ];
  final List<Map<String, dynamic>> itemList2 = [
    {
      "name": 'Nike',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg',
      "rating": 4.5,
      "category": "Sports"
    },
    {
      "name": 'Adidas',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg',
      "rating": 4.3,
      "category": "Sports"
    },
    {
      "name": 'Apple',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg',
      "rating": 4.8,
      "category": "Electronics"
    },
    {
      "name": 'Samsung',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg',
      "rating": 4.4,
      "category": "Electronics"
    },
    {
      "name": 'Gucci',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg',
      "rating": 4.7,
      "category": "Fashion"
    },
    {
      "name": 'Louis Vuitton',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg',
      "rating": 4.9,
      "category": "Fashion"
    },
    {
      "name": 'H&M',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg',
      "rating": 4.2,
      "category": "Fashion"
    },
    {
      "name": 'Zara',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg',
      "rating": 4.6,
      "category": "Fashion"
    },
    {
      "name": 'Amazon',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg',
      "rating": 4.8,
      "category": "Online Store"
    },
    {
      "name": 'Sony',
      "imageUrl": 'https://st3.depositphotos.com/10665628/32088/v/1600/depositphotos_320884562-stock-illustration-supermarket-building-entrance-concept-vector.jpg',
      "rating": 4.5,
      "category": "Electronics"
    },
  ];
  int _currentIndex = 0;

  // final double sourceLatitude = 40.7128; // Latitude of source location
  // final double sourceLongitude = -74.0060; // Longitude of source location
  // final double destinationLatitude = 34.0522; // Latitude of destination location
  // final double destinationLongitude = -118.2437; // Longitude of destination location
  // use geolocator to find distance

  //Functions
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.location_on_outlined, color: _orangeColor,),
            const SizedBox(width: 5.0,),
            Expanded(
              child: Text(
                _currentLocation,
                style: const TextStyle(
                  fontSize: 14.0,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_down, size: 30.0,),
              onPressed: () {
                // ----------------------------- location update
              },
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BuyerAccount()),
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
            ) :  const Icon(
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
            ) :  const Icon(
              Icons.shopping_basket,
              color: Colors.grey,
              size: 30.0,
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
            ) :  const Icon(
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
            ) :  const Icon(
              Icons.account_circle,
              color: Colors.grey,
              size: 30.0,
            ),
            label: '',
          ),
        ]
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Good Morning,'),
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
              height: 120, // Adjust height as needed
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: itemList.length,
                itemBuilder: (context, index) {
                  return Container(
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
                              itemList[index]["name"]!,
                              style: const TextStyle(color: Colors.black,
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
                                itemList[index]["imageUrl"]!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
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
                itemCount: itemList2.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 170,
                    height: 100,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20), // Adjust the curve amount as needed
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 3,
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                                child: Image.network(
                                  itemList2[index]["imageUrl"]!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      itemList2[index]["name"]!,
                                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      itemList2[index]["category"]!,
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 60,
                          left: 10,
                          child: Row(
                            children: [
                              Text(
                                itemList2[index]["rating"]?.toString() ?? 'N/A',
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.star,
                                color: Colors.yellow,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
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
