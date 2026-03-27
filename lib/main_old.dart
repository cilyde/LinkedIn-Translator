
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linkedin_translator/providers.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'LinkedIn Translator',
      theme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xFF0A66C2),
        scaffoldBackgroundColor: Color(0xFFF9FAFB),
      ),
      home: const LinkedInTranslatorScreen(),
    );
  }
}

class LinkedInTranslatorScreen extends ConsumerStatefulWidget {
  const LinkedInTranslatorScreen({super.key});

  @override
  ConsumerState<LinkedInTranslatorScreen> createState() =>
      _LinkedInTranslatorScreenState();
}

class _LinkedInTranslatorScreenState
    extends ConsumerState<LinkedInTranslatorScreen> {
  final _textController = TextEditingController();
  String _selectedTone = 'Visionary';
  String _selectedLength = 'Short';
  String _selectedComplexity = 'Low';
  bool _includeHashtags = false;

  void _generatePost() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a sentence before generating a post.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ref.read(isLoadingProvider.notifier).state = true;
    final aiService = ref.read(aiServiceProvider);
    final post = await aiService.generatePost(
      inputText: text,
      tone: _selectedTone,
      length: _selectedLength,
      complexity: _selectedComplexity,
      includeHashtags: _includeHashtags,
    );
    ref.read(linkedInPostProvider.notifier).state = post;
    ref.read(isLoadingProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    final generatedPost = ref.watch(linkedInPostProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LinkedIn Translator'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF0A66C2),
      ),
      backgroundColor: const Color(0xFFF3F6F9),
      bottomSheet: isKeyboardOpen
          ? Container(
              color: Colors.white,
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => FocusScope.of(context).unfocus(),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF0A66C2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Close Keyboard'),
                  ),
                ],
              ),
            )
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFeef4fd), Color(0xFFffffff)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _textController,
                            decoration: InputDecoration(
                              labelText: 'Your achievement',
                              hintText: 'I fixed a bug...',
                              labelStyle: const TextStyle(color: Color(0xFF667085)),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            minLines: 4,
                            maxLines: 6,
                          ),
                          const SizedBox(height: 16),
                          _buildSectionTitle('Tone', LucideIcons.briefcase),
                          const SizedBox(height: 8),
                          _buildToneSelection(),
                          const SizedBox(height: 16),
                          _buildSectionTitle('Length', LucideIcons.trendingUp),
                          const SizedBox(height: 8),
                          _buildLengthToggle(),
                          const SizedBox(height: 16),
                          _buildSectionTitle('Complexity', LucideIcons.award),
                          const SizedBox(height: 8),
                          _buildComplexityToggle(),
                          const SizedBox(height: 16),
                          _buildHashtagToggle(),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _generatePost,
                            icon: const Icon(LucideIcons.sparkles),
                            label: const Text('Generate Post'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0A66C2),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: isLoading
                          ? const SizedBox(
                              height: 140,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : (generatedPost != null
                              ? _buildOutputCard(generatedPost)
                              : _buildEmptyPlaceholder()),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Text(
                        "Remember: It's not about what you did. It's about how you synergize it.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildToneSelection() {
    final tones = ['Visionary', 'Professional', 'Humblebrag', 'Thought Leader'];
    return Wrap(
      spacing: 8.0,
      children: tones.map((tone) {
        return ChoiceChip(
          label: Text(tone),
          selected: _selectedTone == tone,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedTone = tone;
              });
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildLengthToggle() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'Short', label: Text('Short')),
        ButtonSegment(value: 'Long', label: Text('Long')),
      ],
      selected: {_selectedLength},
      onSelectionChanged: (newSelection) {
        setState(() {
          _selectedLength = newSelection.first;
        });
      },
    );
  }

  Widget _buildComplexityToggle() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'Low', label: Text('Low')),
        ButtonSegment(value: 'High', label: Text('High')),
      ],
      selected: {_selectedComplexity},
      onSelectionChanged: (newSelection) {
        setState(() {
          _selectedComplexity = newSelection.first;
        });
      },
    );
  }

  Widget _buildHashtagToggle() {
    return SwitchListTile(
      title: const Text('Include Hashtags'),
      value: _includeHashtags,
      onChanged: (value) {
        setState(() {
          _includeHashtags = value;
        });
      },
      secondary: const Icon(LucideIcons.hash),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Text(
          'Start with a line and let me craft a powerful LinkedIn post.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ),
    );
  }

  Widget _buildOutputCard(String post) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MarkdownBody(data: post),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'LinkedIn Translator AI',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: post));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                  icon: const Icon(LucideIcons.copy, size: 16),
                  label: const Text('Copy'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
