import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:parking_system/utils/constants.dart';
import 'dart:convert';
import '../screens/home_shell.dart';

class PaymentStatusPoller {
  Timer? _timer;

  void startPolling(int id, String token) {
    const duration = Duration(seconds: 5);
    int attempts = 0;

    _timer = Timer.periodic(duration, (timer) async {
      attempts++;
      print("Polling attempt $attempts");

      final response = await http.get(
        Uri.parse('$baseUrl/payment-status/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          _timer?.cancel();

          // Switch back to Active Cars tab

        }
      }

      if (attempts >= 12) {
        // stop after 1 minute
        _timer?.cancel();
        print("Stopped polling after timeout");
      }
    });
  }

  void stopPolling() {
    _timer?.cancel();
  }
}
