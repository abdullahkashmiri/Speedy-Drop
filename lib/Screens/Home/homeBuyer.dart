import 'dart:developer';
import 'package:flutter/material.dart';

class HomeScreenBuyer extends StatefulWidget {
  const HomeScreenBuyer({super.key});

  @override
  State<HomeScreenBuyer> createState() => _HomeScreenBuyerState();
}

class _HomeScreenBuyerState extends State<HomeScreenBuyer> {

  //Variables
  Color _orangeColor = Colors.orange.shade800;


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
              } else if (value == 'rider-mode') {
                log('rider-mode');
              } else if (value == 'logout') {
                log('logout');
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
            Icon(Icons.home,
              color: _orangeColor,
              size: 35,),
            SizedBox(width: 5.0,),
            Text(
              'Home',
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


