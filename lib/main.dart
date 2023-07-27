import 'package:diabetes_ms/Screens/Doctor/HomeScreenD.dart';
import 'package:diabetes_ms/Screens/OnBoarding/SignInPage.dart';
import 'package:diabetes_ms/Screens/Patient/HomeScreenP.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Providers/UserInfo.dart';
import 'Screens/Patient/GraphsScreen.dart';


late bool onboardingCompleted;
late bool isDoctor;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  onboardingCompleted = await prefs.getBool('onboardingCompleted') ?? false;
  isDoctor = await prefs.getBool('isDoctor') ?? false;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: onboardingCompleted ? isDoctor ? HomeScreenD() : HomeScreenP() : SignInPage() ,
        // home: HomeScreenD(),
      ),
    );
  }
}
