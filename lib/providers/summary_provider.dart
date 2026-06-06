import "package:flutter/material.dart";

import "../models/summary_model.dart";
import "../services/ai_service.dart";

enum SummaryLength { short, medium, detailed }
enum SummaryStyle { professional, student, business, technical }

class SummaryProvider extends ChangeNotifier {
  String _inputText = "";
  SummaryLength _length = SummaryLength.medium;
  SummaryStyle _style = SummaryStyle.professional;
  SummaryModel? _currentSummary;
  bool _isLoading = false;

  String get inputText => _inputText;
  SummaryLength get length => _length;
  SummaryStyle get style => _style;
  SummaryModel? get currentSummary => _currentSummary;
  bool get isLoading => _isLoading;

  int get wordCount =>
      _inputText.trim().isEmpty ? 0 : _inputText.trim().split(RegExp(r"\s+")).length;
  int get charCount => _inputText.length;

  void updateInput(String value) {
    _inputText = value;
    notifyListeners();
  }

  void setLength(SummaryLength length) {
    _length = length;
    notifyListeners();
  }

  void setStyle(SummaryStyle style) {
    _style = style;
    notifyListeners();
  }

  void clearInput() {
    _inputText = "";
    notifyListeners();
  }

  Future<SummaryModel> generateSummary() async {
    _isLoading = true;
    notifyListeners();
    final summary = await AiService.generateSummary(
      input: _inputText,
      length: _length,
      style: _style,
    );
    _currentSummary = summary;
    _isLoading = false;
    notifyListeners();
    return summary;
  }
}
