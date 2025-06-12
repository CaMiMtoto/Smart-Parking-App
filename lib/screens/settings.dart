import 'package:flutter/material.dart';
import 'package:parking_system/theme/app_colors.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Add a duration
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      // backgroundColor: const Color(0xFFF6F8FB),
      body: ListView(
        children: [
          Container(
            // color: AppColors.primary,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      user!['name'],
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: AppColors.primary),
                      onPressed: null,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SectionTitle(title: "Profile information"),
          const SectionTitle(title: "Security & Access"),
          const SectionTitle(title: "Help & Support"),
          const Divider(height: 32),
          const SettingItem(title: "Language", value: "English"),
          const SettingItem(
            title: "Display Mode",
            value: "System settings mode",
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return ListTile(
                title: const Text(
                  "Display Mode",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  themeProvider.themeMode.name[0].toUpperCase() +
                      themeProvider.themeMode.name.substring(1),
                ),
                trailing: DropdownButtonHideUnderline(
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            themeProvider.themeMode.name != 'light'
                                ? Colors.grey.shade900
                                : Colors.white,
                        width: 1.0,
                      ),
                    ),
                    child: DropdownButton<ThemeMode>(
                      value: themeProvider.themeMode,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      borderRadius: BorderRadius.circular(12),
                      dropdownColor: Theme.of(context).cardColor,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w600,
                      ),
                      onChanged: (ThemeMode? newMode) {
                        if (newMode != null) {
                          themeProvider.setTheme(newMode);
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text("System Default"),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text("Light"),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text("Dark"),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const SectionTitle(title: "Switch profiles"),
          const SectionTitle(title: "Logout"),
          const SectionTitle(title: "Rate us on the Play Store"),
          const SectionTitle(title: "Invite a friend"),
          const SectionTitle(title: "Data Collection Customer Policy"),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'App Version\nv. 1.43.8 (420)',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}

class SettingItem extends StatelessWidget {
  final String title;
  final String value;

  const SettingItem({required this.title, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(value),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
