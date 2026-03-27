
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'ai_service.dart';

final aiServiceProvider = Provider<AIService>((ref) {
  final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  return AIService(apiKey);
});

final linkedInPostProvider = StateProvider<String?>((ref) => null);

final isLoadingProvider = StateProvider<bool>((ref) => false);
