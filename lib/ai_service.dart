
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  final GenerativeModel _primaryModel;
  final GenerativeModel _fallbackModel;
  final String _apiKey;

  AIService(String apiKey)
      : _apiKey = apiKey,
        _primaryModel = GenerativeModel(model: 'gemini-3.1-flash-lite-preview', apiKey: apiKey),
        _fallbackModel = GenerativeModel(model: 'gemini-3-flash-preview', apiKey: apiKey);

  Future<String> generatePost({
    required String inputText,
    required String tone,
    required String length,
    required String complexity,
    required bool includeHashtags,
  }) async {
    final prompt = _buildPrompt(
      inputText: inputText,
      tone: tone,
      length: length,
      complexity: complexity,
      includeHashtags: includeHashtags,
    );

    try {
      print('Attempting with primary model (gemini-3.1-flash-lite-preview)...');
      final response = await _primaryModel.generateContent([Content.text(prompt)]);
      return response.text ?? '';
    } catch (e) {
      print('Primary model failed: $e');
      print('Falling back to gemini-3-flash-preview...');
      try {
        final fallbackResponse = await _fallbackModel.generateContent([Content.text(prompt)]);
        return fallbackResponse.text ?? '';
      } catch (fallbackError) {
        print('Fallback model also failed: $fallbackError');
        return 'Error: Could not generate post. Both models are currently unavailable. Please try again later.';
      }
    }
  }

  String _buildPrompt({
    required String inputText,
    required String tone,
    required String length,
    required String complexity,
    required bool includeHashtags,
  }) {
    final complexityInstruction = complexity.toLowerCase() == 'high'
        ? "Use extremely sophisticated, academic, and complex vocabulary. Aim for a 'super-complex' word factor. Use words like 'multidisciplinary', 'orchestrating', 'paradigm', 'synergistic', 'unprecedented'."
        : "Use standard professional vocabulary. Professional and classy, but accessible and not overly verbose.";

    final lengthInstruction = length.toLowerCase() == 'long'
        ? "Use the 'LinkedIn format': Short, punchy sentences. Lots of white space. Start with a hook. End with a question or a 'call to action'."
        : "Produce exactly ONE extremely punchy, high-impact, and sophisticated sentence. Maximum 15 words. No fluff, just the core professional insight.";

    final hashtagInstruction = includeHashtags
        ? "Include 3-5 relevant, high-performing hashtags at the end."
        : "Do not include hashtags.";

    return '''
const systemInstruction = `
  You are a world-class LinkedIn Influencer and Executive Communications Coach.
  Your task is to transform simple, everyday sentences into "LinkedIn-ified" masterpieces.

  Rules:
  1. Exaggerate the impact. A "fixed bug" becomes "engineered a critical solution that optimized system-wide efficiency and safeguarded user trust."
  2. Vocabulary Complexity: $complexityInstruction
  3. Format: $lengthInstruction
  4. Tone: $tone.
  5. $hashtagInstruction
  6. Make it sound sophisticated, advanced, and classy.
`;

Simple sentence: "$inputText"
LinkedIn Post:
''';
  }
}
