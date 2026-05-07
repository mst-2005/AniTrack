import 'package:flutter/material.dart';

class NotificationTile extends StatelessWidget {
  final String animeTitle;
  final int episodeNumber;

  const NotificationTile({
    super.key,
    required this.animeTitle,
    required this.episodeNumber,
  });

  @override
  Widget build(BuildContext context) {
    // Detect theme brightness for text color
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Subtle background that works in both modes
        color: Colors.blueAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active, color: Colors.cyanAccent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "NEW EPISODE!",
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  "$animeTitle Episode $episodeNumber is available!",
                  style: TextStyle(
                    // FONT COLOR FIX: Black in Light Mode, White in Dark
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
