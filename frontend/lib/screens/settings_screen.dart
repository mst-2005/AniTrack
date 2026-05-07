import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/anime.dart';

class ApiService {
  // Use 127.0.0.1:5001 to match your Node.js server
  static const String baseUrl = 'http://127.0.0.1:5001/api/users';

  static Future<List<Anime>> fetchAllAnime() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/anime'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Anime.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("API Error: $e");
      return [];
    }
  }

  static Future<bool> addToWatchlist(String userId, String animeId) async {
    final url = Uri.parse('$baseUrl/add-to-watchlist');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId, "animeId": animeId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> removeFromWatchlist(String userId, String animeId) async {
    final url = Uri.parse('$baseUrl/remove-from-watchlist');
    try {
      final response = await http.delete(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId, "animeId": animeId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // FIX: Added changePassword
  static Future<bool> changePassword(String userId, String newPassword) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/change-password'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId, "newPassword": newPassword}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // NEW: Added deleteAccount
  static Future<bool> deleteAccount(String userId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/delete-account/$userId'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // NEW: Added Feedback method
  static Future<bool> sendFeedback(String userId, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/feedback'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId, "message": message}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static void streamOnCrunchyroll(String title) {
    print("Streaming $title on Crunchyroll...");
  }
}
