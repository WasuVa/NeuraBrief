import "dart:convert";

import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uuid/uuid.dart";

import "../models/summary_model.dart";

class HistoryProvider extends ChangeNotifier {
  static const _storageKey = "summary_history";
  final List<SummaryModel> _history = [];

  List<SummaryModel> get history => List.unmodifiable(_history);

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) {
      return;
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    _history
      ..clear()
      ..addAll(decoded.map((item) => SummaryModel.fromJson(item as Map<String, dynamic>)));
    notifyListeners();
  }

  Future<void> addSummary(SummaryModel summary) async {
    _history.insert(0, summary);
    await _persist();
    notifyListeners();
  }

  Future<void> deleteSummary(String id) async {
    _history.removeWhere((item) => item.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final index = _history.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }
    _history[index].isFavorite = !_history[index].isFavorite;
    await _persist();
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

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_history.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
