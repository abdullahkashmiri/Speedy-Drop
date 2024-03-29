import 'package:flutter/material.dart';

import '../Products/New Product/new_product.dart';

class ManageStore extends StatefulWidget {
  const ManageStore({Key? key}) : super(key: key);

  @override
  State<ManageStore> createState() => _ManageStoreState();
}

class _ManageStoreState extends State<ManageStore> {
  final Color _orangeColor = Colors.orange.shade800;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Management',
          style: TextStyle(
              color: Colors.white
          ),),
        backgroundColor: _orangeColor,
        iconTheme: const IconThemeData(
          color: Colors.white,
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
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
