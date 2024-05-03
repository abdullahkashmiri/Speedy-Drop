import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:speedydrop/Screens/Home/Seller/homeSeller.dart';
import '../../../Services/Auth/auth.dart';
import '../../Authentication/Sign In/signin.dart';
import '../Buyer/homeBuyer.dart';

class HomeScreenRider extends StatefulWidget {
  const HomeScreenRider({super.key});

  @override
  State<HomeScreenRider> createState() => _HomeScreenRiderState();
}

class _HomeScreenRiderState extends State<HomeScreenRider> {

  //Variables
  Color _orangeColor = Colors.orange.shade800;
  final Auth_Service _auth_service = Auth_Service();
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
                value: 'seller-mode',
                child: Row(
                  children: [
                    Icon(Icons.store,
                      color: _orangeColor,),
                    const SizedBox(width: 10.0,),
                    const Text('Seller',
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
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                  return const HomeScreenBuyer();
                }));
              } else if (value == 'seller-mode') {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                  return const HomeScreenSeller(previousScreen: 'homeRider',);
                }));
                log('seller-mode');
              } else if (value == 'logout') {
                log('logout');
                _auth_service.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
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
      body:  Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.motorcycle,
              color: _orangeColor,
              size: 35,),
            const SizedBox(width: 5.0,),
            Text(
              'Home Rider',
              style: TextStyle(
                color: _orangeColor,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

