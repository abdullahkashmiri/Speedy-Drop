import 'package:flutter/material.dart';
import 'package:speedydrop/Screens/Loading/loading.dart';

class Splash_Screen extends StatefulWidget {
  const Splash_Screen({Key? key});

  @override
  State<Splash_Screen> createState() => _Splash_ScreenState();
}

class _Splash_ScreenState extends State<Splash_Screen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCirc, // Adjust curve for smooth transition
      ),
    );

    _animationController.forward();

    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Loading_Screen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Center(
            child: Transform.scale(
              scale: _animation.value,
              child: Image.asset('assets/images/Speedy.png'),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
