import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/dashboard_data.dart';
import '../utils/constants.dart';

class DashboardService {
  Future<DashboardData> fetchDashboardData(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard'),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return DashboardData.fromJson(json);
    } else {
      throw Exception('Failed to load dashboard data');
    }
  }
}
