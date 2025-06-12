import 'package:http/http.dart' as http;
import 'dart:convert';

class FlutterwaveService {
  final String apiUrl = 'https://your-backend.com/api/checkout'; // Laravel route

  Future<void> initiatePayment({
    required String phoneNumber,
    required String email,
    required double amount,
  }) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone_number': phoneNumber,
        'email': email,
        'amount': amount,
      }),
    );

    if (response.statusCode == 302 || response.statusCode == 200) {
      final redirectUrl = jsonDecode(response.body)['redirect_url'];
      // Or extract redirect from Location header if using 302
      // final redirectUrl = response.headers['location'];
      print('Redirect to: $redirectUrl');
      // Open in browser or WebView
    } else {
      throw Exception('Payment initiation failed');
    }
  }
}
