import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/browse_screen.dart';
import 'screens/mylist_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/responsive_layout.dart';

// Global notifier to handle theme changes across all screens
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() {
  runApp(const AniTrackApp());
}

class AniTrackApp extends StatelessWidget {
  const AniTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'AniTrack',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          
          // BRIGHTER LIGHT THEME
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.blue,
            // A cleaner, high-visibility white
            scaffoldBackgroundColor: const Color(0xFFF8F9FA), 
            cardColor: Colors.white,
            
            // Ensures AppBars are bright and visible
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 1,
              iconTheme: IconThemeData(color: Colors.black87),
            ),
            
            // Standardizes text for maximum readability
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.black87),
              bodyMedium: TextStyle(color: Colors.black54),
              titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
            
            // Brightens up input fields like the Search bar
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.black.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF020814),
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
              secondary: Colors.cyanAccent,
            ),
          ),

          initialRoute: '/',
          routes: {
            '/': (context) => const LoginScreen(),
            '/main': (context) => const ResponsiveLayout(),
            '/dashboard': (context) => const DashboardScreen(),
            '/browse': (context) => const BrowseScreen(),
            '/mylist': (context) => const MyListScreen(),
            '/profile': (context) => const ProfileScreen(),
          },
        );
      },
    );
  }
}
