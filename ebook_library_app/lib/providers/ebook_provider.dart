import 'package:flutter/material.dart';
import '../models/ebook.dart';
import '../services/api_service.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:http/http.dart' as http;

class EbookProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Ebook> _ebooks = [];
  bool _isLoading = false;
  String _error = '';

  List<Ebook> get ebooks => _ebooks;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Search
  List<Ebook> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;
  
  List<Ebook> get searchResults => _searchResults;
  bool get isSearching => _isSearching;

  EbookProvider() {
    loadEbooks();
  }

  Future<void> loadEbooks() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _ebooks = await _apiService.fetchEbooks();
    } catch (e) {
      _error = 'Failed to load library: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadEbook(String title, String author, String filePath, {String? coverImagePath}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newEbook = await _apiService.uploadEbook(title, author, filePath, coverImagePath: coverImagePath);
      _ebooks.insert(0, newEbook); 
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<bool> deleteEbook(int id) async {
    try {
      final success = await _apiService.deleteEbook(id);
      if (success) {
        _ebooks.removeWhere((book) => book.id == id);
        _searchResults.removeWhere((book) => book.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void search(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _isSearching = true;
    notifyListeners();

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        if (query.trim().isEmpty) {
          _searchResults = [];
        } else {
          _searchResults = await _apiService.searchEbooks(query);
        }
      } catch (e) {
        _searchResults = [];
      } finally {
        _isSearching = false;
        notifyListeners();
      }
    });
  }
}
