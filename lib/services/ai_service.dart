import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';
import '../models/summary_model.dart';
import '../providers/summary_provider.dart';

class AiService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static Future<SummaryModel> generateSummary({
    required String input,
    required SummaryLength length,
    required SummaryStyle style,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('Gemini API Key not found. Please check your .env file.');
    }

    final prompt = _buildPrompt(input, length, style);

    // Simplest possible initialization for maximum compatibility
    final modelsToTry = [
      'gemini-2.5-flash',
      'gemini-2.5-flash-light',
      'gemini-pro',
    ];

    List<String> errors = [];

    for (var modelName in modelsToTry) {
      try {
        print('Attempting summarization with: $modelName');
        final model = GenerativeModel(model: modelName, apiKey: _apiKey);
        final content = [Content.text(prompt)];
        final response = await model.generateContent(content);
        
        final responseText = response.text;
        if (responseText != null && responseText.isNotEmpty) {
          return _parseAiResponse(responseText);
        }
      } catch (e) {
        print('Error with $modelName: $e');
        errors.add('$modelName: $e');
      }
    }

    throw Exception('Failed to connect to Gemini AI. This usually means the API Key is not yet fully active or the model name has changed.\n\nError details:\n${errors.first}');
  }

  static String _buildPrompt(String input, SummaryLength length, SummaryStyle style) {
    final lengthText = switch (length) {
      SummaryLength.short => 'Concise (max 150 words)',
      SummaryLength.medium => 'Moderate (approx 300 words)',
      SummaryLength.detailed => 'Detailed (comprehensive)',
    };

    final styleText = switch (style) {
      SummaryStyle.professional => 'Professional, formal, and structured',
      SummaryStyle.student => 'Educational, simple language, and easy to grasp',
      SummaryStyle.business => 'Strategic, bulleted, and result-oriented',
      SummaryStyle.technical => 'Deep dive, technical accuracy, and jargon-aware',
    };

    return '''
    Analyze and summarize the following text.
    Length: $lengthText
    Tone: $styleText

    Output Format (JSON):
    {
      "title": "A title",
      "summary": "The summary",
      "category": "One word",
      "keywords": ["key1", "key2"],
      "keyPoints": ["point1", "point2", "point3", "point4", "point5"]
    }

    Text: $input
    ''';
  }

  static SummaryModel _parseAiResponse(String text) {
    try {
      String cleaned = text.trim();
      if (cleaned.contains('```')) {
        cleaned = cleaned.split('```').firstWhere((s) => s.contains('{'), orElse: () => cleaned);
        if (cleaned.startsWith('json')) {
          cleaned = cleaned.substring(4).trim();
        }
      }
      
      final start = cleaned.indexOf('{');
      final end = cleaned.lastIndexOf('}');
      if (start != -1 && end != -1) {
        cleaned = cleaned.substring(start, end + 1);
      }

      final Map<String, dynamic> data = jsonDecode(cleaned);

      return SummaryModel(
        id: const Uuid().v4(),
        title: data['title'] ?? 'Generated Summary',
        summary: data['summary'] ?? '',
        date: DateTime.now(),
        category: data['category'] ?? 'General',
        keywords: List<String>.from(data['keywords'] ?? []),
        keyPoints: List<String>.from(data['keyPoints'] ?? []),
      );
    } catch (e) {
      throw Exception('Failed to parse AI response.');
    }
  }
}
