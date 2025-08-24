import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
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
    Timer.periodic(Duration(seconds: 10), (timer) {
      _checkNetworkStatus();
    });
  }

  Future<void> _checkNetworkStatus() async {
    try {
      // حاول تعمل lookup على موقع ثابت (مثلاً Google DNS)
      final result = await InternetAddress.lookup('google.com');

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // إذا في انترنت
        if (!isConnected.value) {
          isConnected.value = true;
          Helpers.showSuccessSnackbar('Back online');
        }
      } else {
        // إذا ما في انترنت
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
