import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../utils/constants.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController plateController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController entryTimeController = TextEditingController(
    text: DateTime.now().toString().substring(0, 16),
  );
  bool isLoading = false;

  Future<void> submitCheckIn() async {
    // if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    var token = Provider.of<AuthProvider>(context, listen: false).token;
    print("token: $token");
    final response = await http.post(
      Uri.parse('$baseUrl/parking/check-in'),
      headers: {'Authorization': 'Bearer $token', "Accept": "application/json"},
      body: {
        'plate_number': plateController.text,
        'phone_number': phoneController.text,
      },
    );

    setState(() => isLoading = false);
    print("response: ${response.body}");

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('✅ Car checked in successfully!')));
      plateController.clear();
      phoneController.clear();
    } else {
      final error = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error['message'] ?? 'Something went wrong')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFF7F8FC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  "Fill the form below  to save your car",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  )
              ),

              _buildInputField(
                "Car Plate Number",
                plateController,
                context,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a car plate number';
                  }
                  return "";
                },
              ),
              _buildInputField(
                "Phone Number",
                phoneController,
                context,
                inputType: TextInputType.phone,
              ),
              _buildInputField(
                "Entry Time",
                entryTimeController,
                context,
                enabled: false,
              ),
              const SizedBox(height: 30),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1,
                ),
                onPressed: isLoading ? null : submitCheckIn,
                icon: const FaIcon(FontAwesomeIcons.check, size: 18),
                label: Text(
                  isLoading ? 'Saving...' : 'Save Car',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    BuildContext context, {
    bool enabled = true,
    TextInputType inputType = TextInputType.text,
    String Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          // fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: validator,
      ),
    );
  }
}
