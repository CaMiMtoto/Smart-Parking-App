import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../theme/app_colors.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({super.key});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  List<String> carPlates = ['RAB123A', 'RAE111B', 'RAF909C', 'RAC200D', 'RAD999Z'];
  String? selectedPlate;
  DateTime entryTime = DateTime.now().subtract(const Duration(hours: 2, minutes: 30));
  DateTime exitTime = DateTime.now();
  double amountPerHour = 1000;
  double totalAmount = 0;

  void _calculateAmount() {
    final duration = exitTime.difference(entryTime);
    final hours = (duration.inMinutes / 60).ceil();
    totalAmount = hours * amountPerHour;
  }

  @override
  Widget build(BuildContext context) {
    _calculateAmount();
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: Column(
        children: [
          // Top bar
          Container(
            padding: const EdgeInsets.only(top: 0, left: 16, right: 24, bottom: 30),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                const FaIcon(FontAwesomeIcons.carBurst, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  "Check Out Vehicle",
                  style:TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Form section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchablePlateDropdown(),
                  const SizedBox(height: 16),
                  if (selectedPlate != null) ...[
                    _buildInfoRow("Entry Time", entryTime.toString().substring(0, 16)),
                    _buildInfoRow("Exit Time", exitTime.toString().substring(0, 16)),
                    _buildInfoRow("Duration", "${exitTime.difference(entryTime).inMinutes} minutes"),
                    _buildInfoRow("Total Amount", "RWF ${totalAmount.toStringAsFixed(0)}"),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),

      // Pay button
      bottomNavigationBar: selectedPlate != null
          ? Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton.icon(
          onPressed: () {
            // Trigger MoMo payment
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const FaIcon(FontAwesomeIcons.mobileScreen),
          label: const Text("Pay with MoMo", style: TextStyle(fontSize: 16)),
        ),
      )
          : null,
    );
  }

  Widget _buildSearchablePlateDropdown() {
    return DropdownSearch<String>(
      items: carPlates,
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: "Search car plate...",
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Search Car Plate",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
      onChanged: (value) {
        setState(() {
          selectedPlate = value!;
          // Simulate loading entry time
          entryTime = DateTime.now().subtract(Duration(minutes: (45 + carPlates.indexOf(value) * 30)));
          exitTime = DateTime.now();
        });
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[700])),
          Text(value, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
