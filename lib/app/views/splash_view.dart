import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';

class SplashView extends StatefulWidget {
  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(Duration(seconds: 3));

    if (await authController.isLoggedIn()) {
      final userType = authController.currentUser.value?.userType;

      if (userType == 'owner') {
        Get.offAllNamed(AppRoutes.ownerHome);
      } else {
        Get.offAllNamed(AppRoutes.userHome);
      }
    } else {
      // First time user - show as guest user interface
      Get.offAllNamed(AppRoutes.userHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C1C1C), // خلفية سوداء فاتحة
      body: Center(
        child: Image.asset(
          'assets/images/logo1.png', // ضع هنا مسار صورتك
          width: 150,
          height: 150,
        ),
      ),
    );
  }
}
