import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../services/api_service.dart';

class NewsProvider with ChangeNotifier {
  List<News> _publicNews = [];
  List<News> _authorNews = [];
  bool _isLoading = false;
  String? _error;

  List<News> get publicNews => _publicNews;
  List<News> get authorNews => _authorNews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> fetchPublicNews() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _publicNews = await ApiService.getPublicNews();
    } catch (e) {
      _error = 'Gagal mengambil berita: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAuthorNews() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _authorNews = await ApiService.getAuthorNews();
    } catch (e) {
      _error = 'Gagal mengambil berita penulis: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createNews(News news) async {
    _error = null;
    try {
      final createdNews = await ApiService.createNews(news);
      _authorNews.insert(0, createdNews);

      if (createdNews.isPublished) {
        _publicNews.insert(0, createdNews);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal membuat berita: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateNews(String id, News news) async {
    _error = null;

    try {
      final updatedNews = await ApiService.updateNews(id, news);
      final authorIndex = _authorNews.indexWhere((n) => n.id == id);
      if (authorIndex != -1) {
        _authorNews[authorIndex] = updatedNews;
      }

      final publicIndex = _publicNews.indexWhere((n) => n.id == id);
      if (publicIndex != -1) {
        if (updatedNews.isPublished) {
          _publicNews[publicIndex] = updatedNews;
        } else {
          _publicNews.removeAt(publicIndex);
        }
      } else if (updatedNews.isPublished) {
        _publicNews.insert(0, updatedNews);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal mengupdate berita: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteNews(String id) async {
    _error = null;
    try {
      bool success = await ApiService.deleteNews(id);

      if (success) {
        _authorNews.removeWhere((n) => n.id == id);
        _publicNews.removeWhere((n) => n.id == id);
        notifyListeners();
        return true;
      } else {
        _error = 'Gagal menghapus berita';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Gagal menghapus berita: $e';
      notifyListeners();
      return false;
    }
  }
}