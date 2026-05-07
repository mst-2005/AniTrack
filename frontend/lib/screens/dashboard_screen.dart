import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../widgets/notification_tile.dart';
import '../services/api_service.dart';
import '../main.dart'; // Required to access themeNotifier

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getUserData() async {
    // Retrieves the name stored during login
    String? name = await _storage.read(key: 'userName') ?? "MAHITA"; 
    return {"name": name};
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilds the dashboard UI whenever themeNotifier changes
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        final isDark = currentMode == ThemeMode.dark;
        final textColor = isDark ? Colors.white : Colors.black87;
        final subTextColor = isDark ? Colors.white60 : Colors.black54;

        return FutureBuilder<Map<String, String>>(
          future: _getUserData(),
          builder: (context, snapshot) {
            final displayName = snapshot.data?['name'] ?? "MAHITA";

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "WELCOME BACK, ${displayName.toUpperCase()}!",
                    style: TextStyle(
                      color: textColor, // Prevents text invisibility in light mode
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "You have 3 shows in progress",
                    style: TextStyle(color: subTextColor),
                  ),
                  const SizedBox(height: 24),
                  // NotificationTile should use dynamic colors internally for best results
                  const NotificationTile(animeTitle: "One Piece", episodeNumber: 1120),
                  const SizedBox(height: 32),
                  const Text(
                    "CURRENTLY WATCHING",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCurrentlyWatchingCard(textColor, subTextColor, isDark),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCurrentlyWatchingCard(Color textColor, Color subTextColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              "https://cdn.myanimelist.net/images/anime/6/73245.jpg",
              width: 60,
              height: 80,
              fit: BoxFit.cover,
              // FIX: User-Agent header bypasses 403 Forbidden errors
              headers: const {'User-Agent': 'Mozilla/5.0'}, 
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.movie_filter, color: subTextColor.withValues(alpha: 0.2), size: 30),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "One Piece",
                  style: TextStyle(
                    color: textColor, 
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Episode 1119 / 1120",
                  style: TextStyle(color: subTextColor, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.play_circle_fill,
              color: Color(0xFFFF6600), // Crunchyroll Orange
              size: 32,
            ),
            onPressed: () {
              // Successfully calling the static method in ApiService
              ApiService.streamOnCrunchyroll("One Piece");
            },
          ),
          const SizedBox(width: 8),
          const Text(
            "WATCHING",
            style: TextStyle(
              color: Colors.greenAccent, 
              fontSize: 10, 
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
