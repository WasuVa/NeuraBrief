import "dart:async";

import "package:uuid/uuid.dart";

import "../models/summary_model.dart";
import "../providers/summary_provider.dart";

class AiService {
  static Future<SummaryModel> generateSummary({
    required String input,
    required SummaryLength length,
    required SummaryStyle style,
  }) async {
    // Mock AI response with a simulated network delay.
    await Future.delayed(const Duration(seconds: 2));
    const sampleSummary =
        "Flutter empowers developers to build beautiful, high-performance apps from a single "
        "codebase. By combining Dart's expressive syntax with a reactive UI framework, teams can "
        "deliver consistent experiences across iOS, Android, and the web. Provider simplifies state "
        "management by exposing data models throughout the widget tree, while async services handle "
        "networking, caching, and AI workflows. In practice, a clean architecture separates UI, "
        "business logic, and data access to keep features scalable. Developers can optimize user "
        "flows using animations, shimmer loaders, and glassmorphism for modern aesthetics. When "
        "integrating AI summarization, latency can be masked with engaging loading states, and "
        "insights can be surfaced via keyword chips, action items, and history views. With strong "
        "tooling, reusable widgets, and clear design systems, Flutter enables rapid iteration and "
        "polished production delivery.";

    return SummaryModel(
      id: const Uuid().v4(),
      title: "Programming Notes",
      summary: sampleSummary,
      date: DateTime.now(),
      category: "Programming",
      keywords: const ["Flutter", "Provider", "Dart", "API", "State", "UI"],
      keyPoints: const [
        "Single codebase accelerates delivery.",
        "Provider keeps state predictable.",
        "Animations improve perceived performance.",
        "AI summaries should feel instant.",
        "Reusable widgets keep UI consistent.",
      ],
    );
  }
}
