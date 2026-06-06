import "dart:convert";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uuid/uuid.dart";

import "../models/summary_model.dart";

class HistoryProvider extends ChangeNotifier {
  static const _storageKey = "summary_history";
  final List<SummaryModel> _history = [];
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<SummaryModel> get history => List.unmodifiable(_history);

  String? get _userId => _auth.currentUser?.uid;

  Future<void> loadHistory() async {
    // 1. Load from SharedPreferences first for immediate UI
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _history
        ..clear()
        ..addAll(decoded.map((item) => SummaryModel.fromJson(item as Map<String, dynamic>)));
      notifyListeners();
    }

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
    _history.insert(0, summary);
    await _persistLocal();
    
    if (_userId != null) {
      await _db
          .collection('users')
          .doc(_userId)
          .collection('summaries')
          .doc(summary.id)
          .set(summary.toJson());
    }
    
    notifyListeners();
  }

  Future<void> deleteSummary(String id) async {
    _history.removeWhere((item) => item.id == id);
    await _persistLocal();

    if (_userId != null) {
      await _db
          .collection('users')
          .doc(_userId)
          .collection('summaries')
          .doc(id)
          .delete();
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
      await _db
          .collection('users')
          .doc(_userId)
          .collection('summaries')
          .doc(id)
          .update({'isFavorite': _history[index].isFavorite});
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
