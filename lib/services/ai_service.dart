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
      throw Exception('Gemini API Key not found in environment variables');
    }

    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);

    final lengthPrompt = switch (length) {
      SummaryLength.short => 'Concise (1-2 paragraphs)',
      SummaryLength.medium => 'Moderate (3-4 paragraphs)',
      SummaryLength.detailed => 'Detailed (comprehensive)',
    };

    final stylePrompt = switch (style) {
      SummaryStyle.professional => 'Professional and formal',
      SummaryStyle.student => 'Educational and easy to understand',
      SummaryStyle.business => 'Corporate and objective',
      SummaryStyle.technical => 'Detailed and technical',
    };

    final prompt = '''
    Summarize the following text. 
    Target Length: $lengthPrompt
    Tone/Style: $stylePrompt

    Provide the response in the following JSON format:
    {
      "title": "A short descriptive title for the note",
      "summary": "The main summary text",
      "category": "One word category (e.g., Tech, Health, Business)",
      "keywords": ["keyword1", "keyword2", "keyword3"],
      "keyPoints": ["point1", "point2", "point3", "point4", "point5"]
    }

    Text to summarize:
    $input
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      final responseText = response.text;
      if (responseText == null) {
        throw Exception('AI returned empty response');
      }

      // Clean the response if it contains markdown code blocks
      final cleanedResponse = responseText.replaceAll('```json', '').replaceAll('```', '').trim();
      final Map<String, dynamic> data = jsonDecode(cleanedResponse);

      return SummaryModel(
        id: const Uuid().v4(),
        title: data['title'] ?? 'Untitled Summary',
        summary: data['summary'] ?? '',
        date: DateTime.now(),
        category: data['category'] ?? 'General',
        keywords: List<String>.from(data['keywords'] ?? []),
        keyPoints: List<String>.from(data['keyPoints'] ?? []),
      );
    } catch (e) {
      print('Gemini AI Error: $e');
      rethrow;
    }
  }
}
