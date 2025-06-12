import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:parking_system/screens/active_parking_list.dart';
import 'package:parking_system/screens/settings.dart';
import 'package:parking_system/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'dashboard_screen.dart';
import 'checkin_screen.dart';
import 'report_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  _HomeShellState createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;
  var appBarTitle = 'Dashboard';

  final List<Widget> _screens = [
    DashboardScreen(),
    ActiveParkingList(),
    CheckInScreen(),
    ReportScreen(),
    Settings(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          appBarTitle = 'Dashboard';
          break;
        case 1:
          appBarTitle = 'Active Cars';
          break;
        case 2:
          appBarTitle = 'Check In';
          break;
        case 3:
          appBarTitle = 'Reports';
          break;
        case 4:
          appBarTitle = 'Settings';
          break;
      }
    });
  }

  getInitials(String name) {
    return name.split(' ').map((n) => n[0]).take(2).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isLargeScreen = constraints.maxWidth >= 600;

        return Scaffold(
          // backgroundColor: Colors.white,
          appBar: AppBar(
            centerTitle: false,
            // backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              appBarTitle,
              style: TextStyle(
                // color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              PopupMenuButton(
                child: CircleAvatar(
                  foregroundColor: AppColors.primary,
                  child: Text(getInitials(user!['name'])),
                ),
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'logout',
                        child: Text('Logout'),
                      ),
                    ],
                onSelected: (value) {
                  if (value == 'logout') {
                    Provider.of<AuthProvider>(context, listen: false).logout();
                  }
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Row(
            children: [
              if (isLargeScreen)
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onItemTapped,
                  labelType: NavigationRailLabelType.selected,
                  destinations: [
                    NavigationRailDestination(
                      icon: Tooltip(
                        message: 'Dashboard',
                        child: const Icon(FontAwesomeIcons.house),
                      ),
                      label: const Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Tooltip(
                        message: 'Active Cars',
                        child: const Icon(FontAwesomeIcons.squareParking),
                      ),
                      label: const Text('Active'),
                    ),
                    NavigationRailDestination(
                      icon: Tooltip(
                        message: 'Check In New Car',
                        child: const Icon(FontAwesomeIcons.plus),
                      ),
                      label: const Text('Check In'),
                    ),
                    NavigationRailDestination(
                      icon: Tooltip(
                        message: 'Reports & Analytics',
                        child: const Icon(FontAwesomeIcons.chartSimple),
                      ),
                      label: const Text('Reports'),
                    ),
                    NavigationRailDestination(
                      icon: Tooltip(
                        message: 'Settings',
                        child: const Icon(FontAwesomeIcons.gear),
                      ),
                      label: const Text('Settings'),
                    ),
                  ],
                ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isLargeScreen ? 800 : double.infinity,
                    ),
                    child: _screens[_selectedIndex],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar:
              isLargeScreen
                  ? null
                  : BottomNavigationBar(
                    selectedItemColor: AppColors.primary,
                    unselectedItemColor:
                        themeProvider.themeMode.name != 'light'
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                    currentIndex: _selectedIndex,
                    onTap: _onItemTapped,
                    type: BottomNavigationBarType.shifting,
                    showUnselectedLabels: false,
                    showSelectedLabels: false,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(FontAwesomeIcons.house),
                        label: 'Home',
                        tooltip: "Home",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(FontAwesomeIcons.squareParking),
                        label: 'Active Cars',
                        tooltip: "Active Cars",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(FontAwesomeIcons.plus),
                        label: 'New',
                        tooltip: "Check In",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(FontAwesomeIcons.chartSimple),
                        label: 'Reports',
                        tooltip: "Reports",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(FontAwesomeIcons.gear),
                        label: 'Settings',
                        tooltip: "Settings",
                      ),
                    ],
                  ),
        );
      },
    );
  }
}
