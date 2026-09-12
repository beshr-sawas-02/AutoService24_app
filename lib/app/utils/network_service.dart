import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'helpers.dart';

class NetworkService extends GetxService {
  var isConnected = true.obs;
  late StreamSubscription _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _initNetworkMonitoring();
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }

  void _initNetworkMonitoring() {
    // Simple network monitoring using periodic checks
    Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkNetworkStatus();
    });
  }

  Future<void> _checkNetworkStatus() async {
    try {

      final result = await InternetAddress.lookup('google.com');

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {

        if (!isConnected.value) {
          isConnected.value = true;
          Helpers.showSuccessSnackbar('Back online');
        }
      } else {

        if (isConnected.value) {
          isConnected.value = false;
          Helpers.showErrorSnackbar('No internet connection');
        }
      }
    } on SocketException catch (_) {
      if (isConnected.value) {
        isConnected.value = false;
        Helpers.showErrorSnackbar('No internet connection');
      }
    }
  }
}
