// lib/models/ai_chat_response.dart
// Model for AI chat API responses

class AIChatResponse {
  final String answer;
  final List<String> sources;

  AIChatResponse({
    required this.answer,
    required this.sources,
  });

  factory AIChatResponse.fromJson(Map<String, dynamic> json) {
    return AIChatResponse(
      answer: json['answer'] as String? ?? '',
      sources: (json['sources'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'answer': answer,
      'sources': sources,
    };
  }
}
