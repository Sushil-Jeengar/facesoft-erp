import 'dart:async';
import 'package:facesoft/screens/complete_profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:facesoft/providers/auth_provider.dart';
import 'package:facesoft/screens/login.dart';
import 'package:facesoft/screens/home_screen.dart';
import 'package:facesoft/API_services/user_api.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {

    // Timer(Duration(seconds: 1), () {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) => const CompleteProfile()),
    //   );
    // });


    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loadAuthData();
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (authProvider.authData != null) {
      print("Local storage data: ${authProvider.authData?.user.id} ");
      // Data available → Home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // Null → Fetch IDs and then go to Login screen
      try {
        final ids = await UserService.fetchUserIds;
        print("Fetched user IDs: $ids");
      } catch (e) {
        print("Error fetching IDs: $e");
      }
      // Navigate to Login screen after fetching IDs (or if fetching fails)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: Colors.white),
        child: Image.asset(
          'assets/images/FaceLogoE.png',
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
