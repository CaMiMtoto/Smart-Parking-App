import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parking_system/providers/auth_provider.dart';
import 'package:parking_system/providers/theme_provider.dart';
import 'package:parking_system/screens/home_shell.dart';
import 'package:parking_system/screens/login_screen.dart';
import 'package:parking_system/theme/app_colors.dart';
import 'package:parking_system/utils/constants.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // other providers...
      ],
      child: const ParkingApp(),
    ),
  );
  // ChangeNotifierProvider(create: (_) => , child: ParkingApp()),
}

class ParkingApp extends StatelessWidget {
  const ParkingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context);
    return FutureBuilder(
      future: auth.tryAutoLogin(),
      builder: (BuildContext ctx, AsyncSnapshot<void> snapshot) {
        return MaterialApp(
          // debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            primaryColor: AppColors.primary,
            useMaterial3: true,
            scaffoldBackgroundColor: AppColors.background,
            // textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
            fontFamily: GoogleFonts.inter().fontFamily,

            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 2,
            ),
            textTheme: TextTheme(
              bodyMedium: TextStyle(color: AppColors.textPrimary),
            ),
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
              secondary: AppColors.secondary,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(defaultButtonBorderRadius),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                // padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 16),
                elevation: 0,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    defaultButtonBorderRadius,
                  ),
                ),
              ),
            ),
            buttonTheme: ButtonThemeData(
              buttonColor: AppColors.primary,
              textTheme: ButtonTextTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
          ),
          title: 'Parking App',
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: const Color(0xFF121212),
            // ... dark theme
          ),
          home:
              snapshot.connectionState == ConnectionState.waiting
                  ? const CircularProgressIndicator()
                  : Consumer<AuthProvider>(
                    builder:
                        (ctx, auth, _) =>
                            auth.isAuthenticated ? HomeShell() : LoginScreen(),
                  ),
        );
      },
    );
  }
}
