import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:speedydrop/Screens/Home/homeBuyer.dart';
import 'package:speedydrop/Screens/Loading/loading.dart';
import 'package:speedydrop/Services/Database/database.dart';
import '../../Services/Auth/auth.dart';
import '../Authentication/Sign In/signin.dart';
import 'homeRider.dart';


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

  @override
  void initState() {

    super.initState();
    previousScreen = widget.previousScreen;
  }
  //Functions

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speedy Drop',
          style: TextStyle(
            color: Colors.white,
          ),),
        centerTitle: true,
        backgroundColor: _orangeColor,

        actions: [
          PopupMenuButton(
            iconColor: Colors.white,
            onOpened: () {
              setState(() {
                _orangeColor = Colors.orange.shade900;
              });
            },
            onCanceled: () {
              setState(() {
                _orangeColor = Colors.orange.shade800;
              });
            },
            itemBuilder: (BuildContext context) =>
            [PopupMenuItem(
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
                    Icon(Icons.motorcycle_sharp,
                      color: _orangeColor,),
                    const SizedBox(width: 10.0,),
                    const Text('Rider',
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
                    Icon(Icons.logout,
                      color: _orangeColor,),
                    const SizedBox(width: 10.0,),
                    const Text('LogOut',
                      style: TextStyle(
                          fontWeight: FontWeight.bold
                      ),
                    ),
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
              } else if (value == 'rider-mode') {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) {
                  return const HomeScreenRider();
                }));
                log('rider-mode');
              } else if (value == 'logout') {
                log('logout');
                _auth_service.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (
                    context) {
                  return const SignIn();
                }));
              }
              setState(() {
                _orangeColor = Colors.orange.shade800;
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<bool>(
        future: Database_Service(userId: _auth_service.getUserId())
            .isUserASeller(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loading_Screen();
          } else {
            if (snapshot.hasError) {
              // If an error occurs, display an error message
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              bool isSeller = snapshot.data ?? false;
              if (isSeller) {
                log('You are a seller');
                return Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sell,
                        color: _orangeColor,
                        size: 35,),
                      const SizedBox(width: 5.0,),
                      Text(
                        'Home Seller',
                        style: TextStyle(
                          color: _orangeColor,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                log('You are not a seller');
                return Center(
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
                            const Text('Open your Store Now', style: TextStyle(
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
                                Database_Service(userId: _auth_service.getUserId()).createSellerMode();
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
                                if(previousScreen == 'homeBuyer') {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                                    return const HomeScreenBuyer();
                                  }));
                                } else if(previousScreen == 'homeRider') {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                                    return const HomeScreenRider();
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
                );
              }
            }
          }
        },
      ),
    );
  }
}
