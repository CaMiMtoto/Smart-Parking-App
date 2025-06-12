import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = 'http://your-laravel-backend.test/api';

  static Future<bool> checkInCar(String plate, String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/parking/check-in'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'plate_number': plate, 'phone_number': phone}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Check-in error: $e');
      return false;
    }
  }
}
