import "dart:convert";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uuid/uuid.dart";

import "../models/summary_model.dart";

class HistoryProvider extends ChangeNotifier {
  final List<SummaryModel> _history = [];
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _userId;

  List<SummaryModel> get history => List.unmodifiable(_history);

  int get totalSummaries => _history.length;
  int get totalSaved => _history.where((s) => s.isFavorite).toList().length;

  int get totalWordsProcessed {
    int count = 0;
    for (var s in _history) {
      count += s.summary.trim().isEmpty ? 0 : s.summary.trim().split(RegExp(r"\s+")).length;
    }
    return count;
  }

  String get favoriteCategory {
    if (_history.isEmpty) return "None";
    final counts = <String, int>{};
    for (var s in _history) {
      counts[s.category] = (counts[s.category] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  double get timeSavedHours => (totalSummaries * 5) / 60; // Estimate 5 mins saved per summary

  List<double> get weeklyUsage {
    final now = DateTime.now();
    final counts = List.generate(7, (index) => 0.0);
    for (var s in _history) {
      final difference = now.difference(s.date).inDays;
      if (difference >= 0 && difference < 7) {
        counts[6 - difference]++;
      }
    }
    return counts;
  }

  List<Map<String, dynamic>> get monthlyTrend {
    // Return last 7 active entries for the line chart trend
    final trend = _history.reversed.take(7).toList();
    return trend.map((s) => {
      'date': s.date,
      'value': s.summary.length.toDouble() / 100, // Normalized value for chart
    }).toList();
  }

  String get _storageKey => _userId != null ? "summary_history_$_userId" : "summary_history_guest";

  void updateUserId(String? uid) {
    if (_userId != uid) {
      _userId = uid;
      _history.clear(); // Clear old user's data from memory
      loadHistory();
    }
  }

  Future<void> loadHistory() async {
    // 1. Load from User-Specific SharedPreferences first
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    
    _history.clear();
    if (raw != null) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _history.addAll(
        decoded.map((item) => SummaryModel.fromJson(item as Map<String, dynamic>)),
      );
    }
    notifyListeners();

    // 2. If logged in, load from Firestore and sync
    if (_userId != null) {
      try {
        final snapshot = await _db
            .collection('users')
            .doc(_userId)
            .collection('summaries')
            .orderBy('date', descending: true)
            .get();
        
        if (snapshot.docs.isNotEmpty) {
          _history.clear();
          for (var doc in snapshot.docs) {
            _history.add(SummaryModel.fromJson(doc.data()));
          }
          await _persistLocal();
          notifyListeners();
        }
      } catch (e) {
        print("Error loading from Firestore: $e");
      }
    }
  }

  Future<void> addSummary(SummaryModel summary) async {
    // Prevent duplicate entries with the same ID
    final exists = _history.any((item) => item.id == summary.id);
    if (exists) return;

    _history.insert(0, summary);
    await _persistLocal();
    
    if (_userId != null) {
      try {
        await _db
            .collection('users')
            .doc(_userId)
            .collection('summaries')
            .doc(summary.id)
            .set(summary.toJson());
      } catch (e) {
        print("Error saving to Firestore: $e");
      }
    }
    
    notifyListeners();
  }

  Future<void> deleteSummary(String id) async {
    _history.removeWhere((item) => item.id == id);
    await _persistLocal();

    if (_userId != null) {
      try {
        await _db
            .collection('users')
            .doc(_userId)
            .collection('summaries')
            .doc(id)
            .delete();
      } catch (e) {
        print("Error deleting from Firestore: $e");
      }
    }

    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final index = _history.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }
    _history[index].isFavorite = !_history[index].isFavorite;
    await _persistLocal();

    if (_userId != null) {
      try {
        await _db
            .collection('users')
            .doc(_userId)
            .collection('summaries')
            .doc(id)
            .update({'isFavorite': _history[index].isFavorite});
      } catch (e) {
        print("Error updating favorite in Firestore: $e");
      }
    }

    notifyListeners();
  }

  SummaryModel createSummary({
    required String title,
    required String summary,
    required String category,
    required List<String> keywords,
    required List<String> keyPoints,
  }) {
    return SummaryModel(
      id: const Uuid().v4(),
      title: title,
      summary: summary,
      date: DateTime.now(),
      category: category,
      keywords: keywords,
      keyPoints: keyPoints,
    );
  }

  Future<void> _persistLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_history.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
