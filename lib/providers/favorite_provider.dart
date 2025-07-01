import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/news_model.dart';

class FavoriteProvider with ChangeNotifier {
  List<News> _favorites = [];
  List<News> get favorites => _favorites;
  bool isFavorite(String newsId) {
    return _favorites.any((news) => news.id == newsId);
  }

  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList('favorites') ?? [];

      _favorites = favoritesJson.map((jsonString) {
        final Map<String, dynamic> json = jsonDecode(jsonString);
        return News.fromJson(json);
      }).toList();

      notifyListeners();
    } catch (e) {
      ('Error loading favorites: $e');
    }
  }

  Future<void> toggleFavorite(News news) async {
    try {
      final isCurrentlyFavorite = isFavorite(news.id ?? '');

      if (isCurrentlyFavorite) {
        _favorites.removeWhere((item) => item.id == news.id);
      } else {
        _favorites.add(news);
      }

      await _saveFavorites();
      notifyListeners();
    } catch (e) {
      ('Error toggling favorite: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = _favorites.map((news) {
        return jsonEncode(news.toJsonWithId());
      }).toList();

      await prefs.setStringList('favorites', favoritesJson);
    } catch (e) {
      ('Error saving favorites: $e');
    }
  }

  Future<void> clearFavorites() async {
    try {
      _favorites.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('favorites');
      notifyListeners();
    } catch (e) {
      ('Error clearing favorites: $e');
    }
  }
}