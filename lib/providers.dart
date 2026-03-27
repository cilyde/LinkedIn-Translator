
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'ai_service.dart';

// Add your Gemini API key here
const String _apiKey = 'AIzaSyCrGWNglnUjFx8_TnWC-1alPn_tuDbEGms';

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService(_apiKey);
});

final linkedInPostProvider = StateProvider<String?>((ref) => null);

final isLoadingProvider = StateProvider<bool>((ref) => false);
