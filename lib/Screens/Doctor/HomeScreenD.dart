import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreenD extends StatefulWidget {
  const HomeScreenD({super.key});

  @override
  State<HomeScreenD> createState() => _HomeScreenDState();
}

class _HomeScreenDState extends State<HomeScreenD> {

  @override
  void initState() {
    super.initState();
    OnBoaringCompleted();
  }

 Future<void>  OnBoaringCompleted() async {
   SharedPreferences prefs = await SharedPreferences.getInstance();
   await prefs.setBool('onboardingCompleted',true);
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Doctor HomeScreen")),
    );
  }
}
