import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:parking_system/utils/constants.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  Map<String, dynamic>? reportData;
  bool isLoading = true;
  String? fromDate;
  String? toDate;

  @override
  void initState() {
    super.initState();
    loadReport();
  }

  Future<Map<String, dynamic>> fetchReport({
    String? fromDate,
    String? toDate,
  }) async {
    final queryParameters = <String, String>{};
    if (fromDate != null) queryParameters['from_date'] = fromDate;
    if (toDate != null) queryParameters['to_date'] = toDate;

    // final uri = Uri.parse('$baseUrl/parking-report$queryParameters');
    final uri = Uri(
      scheme: Uri.parse(baseUrl).scheme,
      host: Uri.parse(baseUrl).host,
      port: Uri.parse(baseUrl).port,
      path: '/parking-report',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );


    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load report');
    }
  }

  Future<void> loadReport() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await fetchReport(fromDate: fromDate, toDate: toDate);
      setState(() {
        reportData = data;
      });
    } catch (e) {
      // Handle error properly
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Optionally implement a date picker for filtering

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());

    if (reportData == null) return Center(child: Text('No data available'));

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Cars: ${reportData!['total_cars']}'),
          Text('Active Cars: ${reportData!['active_cars']}'),
          Text('Completed Sessions: ${reportData!['total_completed']}'),
          Text('Total Amount Collected: ${reportData!['total_amount']} RWF'),
          Text(
            'Total Parking Duration: ${reportData!['total_duration_minutes']} minutes',
          ),
          Text(
            'Average Parking Duration: ${reportData!['average_duration_minutes']} minutes',
          ),
        ],
      ),
    );
  }
}
