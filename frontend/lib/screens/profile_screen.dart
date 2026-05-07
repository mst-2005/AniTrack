import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../main.dart'; // Access themeNotifier

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _fetchUserData() async {
    return {
      "name": await _storage.read(key: 'userName') ?? "Mahita",
      "email": await _storage.read(key: 'userEmail') ?? "demo@anitrack.com"
    };
  }

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder is the key to making the toggle work in real-time
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        final isDark = currentMode == ThemeMode.dark;
        final textColor = isDark ? Colors.white : Colors.black87;
        final subTextColor = isDark ? Colors.white54 : Colors.black54;
        final scaffoldBg = isDark ? const Color(0xFF020814) : Colors.white;

        return FutureBuilder<Map<String, String>>(
          future: _fetchUserData(),
          builder: (context, snapshot) {
            final name = snapshot.data?['name'] ?? "Mahita";
            final email = snapshot.data?['email'] ?? "demo@anitrack.com";

            return Scaffold(
              backgroundColor: scaffoldBg, // Dynamic background
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text("Profile & Settings", style: TextStyle(color: textColor)),
                centerTitle: true,
                iconTheme: IconThemeData(color: textColor),
              ),
              body: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        name[0].toUpperCase(),
                        style: const TextStyle(fontSize: 40, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor, // Dynamic text
                      ),
                    ),
                    Text(email, style: TextStyle(color: subTextColor)),
                    const SizedBox(height: 40),

                    // THEME TOGGLE
                    ListTile(
                      leading: Icon(
                        isDark ? Icons.dark_mode : Icons.light_mode,
                        color: isDark ? Colors.cyanAccent : Colors.orangeAccent,
                      ),
                      title: Text("Dark Mode", style: TextStyle(color: textColor)),
                      trailing: Switch(
                        value: isDark,
                        onChanged: (val) {
                          // Updates global state and triggers the builder to rebuild
                          themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                        },
                      ),
                    ),

                    // SHARE WATCHLIST
                    ListTile(
                      leading: Icon(Icons.share, color: isDark ? Colors.cyanAccent : Colors.blueAccent),
                      title: Text("Share Watchlist", style: TextStyle(color: textColor)),
                      trailing: TextButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: "http://localhost:5001/share/${name.toLowerCase()}"));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Link copied!")),
                          );
                        },
                        child: const Text("COPY LINK"),
                      ),
                    ),

                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          await _storage.deleteAll();
                          if (context.mounted) Navigator.pushReplacementNamed(context, '/');
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                        ),
                        child: const Text("Logout", style: TextStyle(color: Colors.redAccent)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
