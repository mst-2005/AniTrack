import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/anime.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5001/api/users';

  static Future<List<Anime>> fetchAllAnime() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/anime'));
      return response.statusCode == 200 
        ? (json.decode(response.body) as List).map((i) => Anime.fromJson(i)).toList() 
        : [];
    } catch (e) { return []; }
  }

  static Future<bool> addToWatchlist(String userId, String animeId) async {
    final response = await http.post(Uri.parse('$baseUrl/add-to-watchlist'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId, "animeId": animeId}));
    return response.statusCode == 200;
  }

  static Future<bool> removeFromWatchlist(String userId, String animeId) async {
    final response = await http.delete(Uri.parse('$baseUrl/remove-from-watchlist'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId, "animeId": animeId}));
    return response.statusCode == 200;
  }

  // FIX: Added changePassword
  static Future<bool> changePassword(String userId, String newPassword) async {
    final response = await http.put(Uri.parse('$baseUrl/change-password'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId, "newPassword": newPassword}));
    return response.statusCode == 200;
  }

  // NEW: Added account management
  static Future<bool> deleteAccount(String userId) async {
    final response = await http.delete(Uri.parse('$baseUrl/delete-account/$userId'));
    return response.statusCode == 200;
  }

 /// Opens Crunchyroll in the default browser for the given anime title
  static Future<void> streamOnCrunchyroll(String title) async {
    // Construct the search URL
    final String searchUrl = "https://www.crunchyroll.com/search?q=${Uri.encodeComponent(title)}";
    final Uri url = Uri.parse(searchUrl);

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        debugPrint("Could not launch $searchUrl");
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
    }
  }

}
