import 'package:flutter/material.dart';
import '../../../Services/Auth/auth.dart';
import '../../Account/user_account.dart';
import '../../Authentication/Sign In/signin.dart';
import '../../Home/Buyer/homeBuyer.dart';
import '../../Home/Rider/homeRider.dart';
import '../../Products/New Product/new_product.dart';
import 'dart:developer' as dev;


class ManageStore extends StatefulWidget {
  const ManageStore({Key? key}) : super(key: key);

  @override
  State<ManageStore> createState() => _ManageStoreState();
}

class _ManageStoreState extends State<ManageStore> {
  final Color _orangeColor = Colors.orange.shade800;
  String _profileImage = 'assets/images/speedyLogov1.png';
  final Auth_Service _auth_service = Auth_Service();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Expanded(
              child: Row(
                children: [
                  Center(
                    child: Text(
                     'Product Management',
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
                return const HomeScreenRider(previousScreen: 'manageStore',);
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

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 220,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                    return const NewProductScreen();
                  }));
                },
                style: ElevatedButton.styleFrom(
                  primary: _orangeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Add Products', style: TextStyle(fontSize: 20,
                    color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 220,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Add your functionality for "Remove Products" here
                },
                style: ElevatedButton.styleFrom(
                  primary: _orangeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Remove Products', style: TextStyle(fontSize: 20,
                    color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 220,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Add your functionality for "Update Products" here
                },
                style: ElevatedButton.styleFrom(
                  primary: _orangeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Update Products', style: TextStyle(fontSize: 20,
                    color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
