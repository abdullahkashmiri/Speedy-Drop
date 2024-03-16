import 'dart:developer';
import 'package:flutter/material.dart';
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
            [
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
              if (value == 'seller-mode') {
                log('seller-mode');
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                  return const HomeScreenSeller();
                }));
              } else if (value == 'rider-mode') {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                  return const HomeScreenRider();
                }));
                log('rider-mode');
              } else if (value == 'logout') {
                log('logout');
                _auth_service.signOut();
              }
              setState(() {
                _orangeColor = Colors.orange.shade800;
              });
            },
          ),
        ],
      ),

      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_filled,
              color: _orangeColor,
              size: 35,),
            const SizedBox(width: 5.0,),
            Text(
              'Home Buyer',
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


