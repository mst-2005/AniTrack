import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/anime.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../main.dart'; // Access themeNotifier

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  late Future<List<Anime>> _animeFuture;
  String _selectedCategory = "All";

  final List<String> _categories = [
    "All", "Action", "Adventure", "Sci-Fi", "Fantasy",
  ];

  @override
  void initState() {
    super.initState();
    _animeFuture = ApiService.fetchAllAnime();
  }

  @override
  Widget build(BuildContext context) {
    // This builder makes the screen reactive to the Dark/Light toggle
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        final isDark = currentMode == ThemeMode.dark;
        final scaffoldBg = isDark ? const Color(0xFF020814) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black87;

        return Scaffold(
          backgroundColor: scaffoldBg,
          body: Column(
            children: [
              _buildCategoryFilter(isDark, textColor),
              Expanded(
                child: FutureBuilder<List<Anime>>(
                  future: _animeFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.cyanAccent),
                      );
                    }

                    final allAnime = snapshot.data ?? [];
                    // Local filtering based on UI selection
                    final filteredList = _selectedCategory == "All"
                        ? allAnime
                        : allAnime.where((a) => a.category == _selectedCategory).toList();

                    if (filteredList.isEmpty) {
                      return Center(
                        child: Text(
                          "No anime found in this category",
                          style: TextStyle(color: textColor.withValues(alpha: 0.5)),
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) =>
                          _buildAnimeCard(filteredList[index], textColor, isDark),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryFilter(bool isDark, Color textColor) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (selected) => setState(() => _selectedCategory = cat),
              selectedColor: Colors.cyanAccent,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.5),
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : textColor, // Fixed visibility
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              side: BorderSide.none,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimeCard(Anime anime, Color textColor, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    anime.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    // FIX: Headers resolve the missing picture issue
                    headers: const {
                      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
                    }, 
                    errorBuilder: (context, e, s) => Container(
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.1),
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.white24, size: 30),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () async {
                      const storage = FlutterSecureStorage();
                      String? userId = await storage.read(key: 'userId');
                      if (userId != null) {
                        bool success = await ApiService.addToWatchlist(userId, anime.id);
                        _showSnackBar(
                          success ? "Added to Watchlist!" : "Already in list",
                          success ? Colors.greenAccent : Colors.orangeAccent,
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.cyanAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add, color: Colors.black, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              anime.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold), // Responsive color
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }
}
