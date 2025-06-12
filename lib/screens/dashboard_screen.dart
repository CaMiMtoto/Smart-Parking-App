import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:parking_system/services/dashboard_service.dart';
import 'package:parking_system/theme/app_colors.dart';
import 'package:parking_system/utils/constants.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_data.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/earnings_bar_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<DashboardData> dashboardFuture;
  var dashboardService = DashboardService();

  @override
  void initState() {
    super.initState();
    var token = Provider.of<AuthProvider>(context, listen: false).token;
    dashboardFuture = dashboardService.fetchDashboardData(token!);
  }

  String selectedFilter = 'Weekly';
  DateTimeRange? selectedDateRange;

  // Example hardcoded data
  List<double> earningsData = [2500, 3200, 2800, 4000, 3700, 4500, 3000];

  final List<String> filters = ['Weekly', 'Monthly', 'Custom'];

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
        // TODO: Replace this with logic to fetch API based on selectedDateRange
        earningsData = List.generate(7, (index) => (index + 1) * 1000); // mock
      });
    }
  }

  Widget _buildFilterBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Filter Dropdown
        DropdownButton<String>(
          value: selectedFilter,
          items:
              filters.map((String filter) {
                return DropdownMenuItem<String>(
                  value: filter,
                  child: Text(filter),
                );
              }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedFilter = value;
                // Update chart data based on selection
                if (value == 'Weekly') {
                  earningsData = [2500, 3200, 2800, 4000, 3700, 4500, 3000];
                  selectedDateRange = null;
                } else if (value == 'Monthly') {
                  earningsData = List.generate(12, (i) => (i + 1) * 1500);
                  selectedDateRange = null;
                } else if (value == 'Custom') {
                  _pickDateRange();
                }
              });
            }
          },
        ),

        // Show selected range if custom
        if (selectedFilter == 'Custom' && selectedDateRange != null)
          Text(
            "${DateFormat('dd MMM').format(selectedDateRange!.start)} - ${DateFormat('dd MMM').format(selectedDateRange!.end)}",
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
      ],
    );
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    print( themeProvider.themeMode.name);
    return Scaffold(
      body: FutureBuilder<DashboardData>(
        future: dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          final weeklyAmounts = data.earnings.map((e) => e.amount).toList();
          final activeCars = data.activeCars;
          final todayRevenue = data.todayRevenue;
          final totalRevenue = data.totalRevenue;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello ${Provider.of<AuthProvider>(context).user?['name']}',
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  "Active Parked Cars",
                  Globals.numberFormat(activeCars),
                  FontAwesomeIcons.car,
                  AppColors.primary,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  "Today's Revenue",
                  "RWF ${Globals.numberFormat(todayRevenue)}",
                  FontAwesomeIcons.wallet,
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  "Total Revenue",
                  "RWF ${Globals.numberFormat(totalRevenue)}",
                  FontAwesomeIcons.coins,
                  AppColors.success,
                ),
                const SizedBox(height: 24),
                _buildFilterBar(),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        themeProvider.themeMode.name == 'light'
                            ? Colors.white
                            : null,
                    borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade300
                  )
                  /*  boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 1),
                    ],*/
                  ),
                  height: 260,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Earnings",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Expanded(
                        child: EarningsBarChart(weeklyEarnings: weeklyAmounts),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color bgColor,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0.1,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: bgColor.withOpacity(0.2),
              child: Icon(icon, color: bgColor),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: bgColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
