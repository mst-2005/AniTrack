import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';
import '../models/anime.dart';
import '../main.dart'; // To access themeNotifier

class MyListScreen extends StatefulWidget {
  const MyListScreen({super.key});

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> {
  final _storage = const FlutterSecureStorage();
  late Future<List<Anime>> _watchlistFuture;
  String _activeTab = "All";

  @override
  void initState() {
    super.initState();
    // Initialize the data fetch
    _watchlistFuture = ApiService.fetchAllAnime();
  }

  // Helper to trigger a UI refresh after changes
  void _refreshData() {
    setState(() {
      _watchlistFuture = ApiService.fetchAllAnime();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        final isDark = currentMode == ThemeMode.dark;
        final textColor = isDark ? Colors.white : Colors.black87;
        final subTextColor = isDark ? Colors.white60 : Colors.black54;
        final scaffoldBg = isDark ? const Color(0xFF020814) : const Color(0xFFF8F9FA);

        return Scaffold(
          backgroundColor: scaffoldBg,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              "My Watchlist",
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              _buildSearchBar(isDark, textColor, subTextColor),
              _buildCategoryTabs(subTextColor),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<Anime>>(
                  future: _watchlistFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text("Error loading list", style: TextStyle(color: Colors.red)));
                    }

                    final allAnime = snapshot.data ?? [];
                    
                    // FILTER LOGIC: Matches the active tab to the anime status
                    final filteredList = _activeTab == "All"
                        ? allAnime
                        : allAnime.where((anime) => anime.status == _activeTab).toList();

                    if (filteredList.isEmpty) {
                      return Center(
                        child: Text("No shows in '$_activeTab'", style: TextStyle(color: subTextColor)),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) => _buildWatchlistItem(
                        filteredList[index],
                        textColor,
                        subTextColor,
                        isDark,
                      ),
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

  Widget _buildSearchBar(bool isDark, Color textColor, Color subTextColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: "Search your list...",
          hintStyle: TextStyle(color: subTextColor),
          prefixIcon: Icon(Icons.search, color: subTextColor),
          fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(Color subTextColor) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: ["All", "Watching", "Completed", "On Hold", "Dropped"]
            .map((tab) => GestureDetector(
                  onTap: () => setState(() => _activeTab = tab),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Text(
                      tab,
                      style: TextStyle(
                        color: _activeTab == tab ? Colors.cyanAccent : subTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildWatchlistItem(Anime anime, Color textColor, Color subTextColor, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              anime.imageUrl,
              width: 50, height: 70, fit: BoxFit.cover,
              headers: const {'User-Agent': 'Mozilla/5.0'},
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(anime.title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 0.7, // You can make this dynamic if your model has 'progress'
                  backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                  minHeight: 4,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _confirmDelete(anime),
          ),
        ],
      ),
    );
  }

  // DELETE LOGIC: Shows a dialog before calling the backend
  void _confirmDelete(Anime anime) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Anime"),
        content: Text("Are you sure you want to remove ${anime.title} from your list?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final userId = await _storage.read(key: 'userId');
              
              final response = await http.delete(
                Uri.parse('http://127.0.0.1:5001/api/users/remove-from-watchlist'),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({"userId": userId, "animeId": anime.id}),
              );

              if (response.statusCode == 200) {
                _refreshData(); // Triggers re-fetch and UI update
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${anime.title} removed")),
                  );
                }
              }
            },
            child: const Text("Remove", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
