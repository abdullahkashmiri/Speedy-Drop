import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading_Screen extends StatelessWidget {
  const Loading_Screen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SpinKitFadingCircle(
          color: Colors.orange.shade600,
          size: 75,
        ),
      ),
    );
  }
}
