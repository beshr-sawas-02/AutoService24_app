import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';

/// Blocks guests and non-owners from owner-only screens.
class OwnerAuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthController>()) {
      return const RouteSettings(name: AppRoutes.login);
    }

    final auth = Get.find<AuthController>();

    if (!auth.isLoggedIn.value) {
      return const RouteSettings(name: AppRoutes.login);
    }

    if (!auth.isOwner) {
      return const RouteSettings(name: AppRoutes.userHome);
    }

    return null;
  }
}

/// Blocks guests from screens that require a logged-in user.
class AuthRequiredMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthController>()) {
      return const RouteSettings(name: AppRoutes.login);
    }

    final auth = Get.find<AuthController>();

    if (!auth.isLoggedIn.value) {
      return const RouteSettings(name: AppRoutes.login);
    }

    return null;
  }
}
