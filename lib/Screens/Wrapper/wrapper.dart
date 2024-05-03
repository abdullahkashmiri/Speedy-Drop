import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speedydrop/Models/User/user.dart';
import 'package:speedydrop/Screens/Authentication/Sign%20In/signin.dart';
import 'package:speedydrop/Screens/Home/Buyer/homeBuyer.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<Current_User?>(context);
    if(user == null) {
      return const SignIn();
    } else {
      return const HomeScreenBuyer();
    }
  }
}
