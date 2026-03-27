import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linkedin_translator/providers.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'theme/index.dart';
import 'components/index.dart';

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
      theme: AppTheme.lightTheme(),
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
  String _selectedViewMode = 'Editor'; // 'Editor' or 'Recent'
  String _selectedTone = 'Visionary';
  String _selectedLength = 'Short';
  String _selectedComplexity = 'Low';
  bool _includeHashtags = false;

  final List<String> _tones = ['Visionary', 'Professional', 'Humblebrag', 'Thought Leader'];
  final List<String> _recentPosts = [];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _generatePost() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      _showCupertinoAlert('Missing Input', 'Please enter a sentence before generating a post.');
      return;
    }

    ref.read(isLoadingProvider.notifier).state = true;
    try {
      final aiService = ref.read(aiServiceProvider);
      final post = await aiService.generatePost(
        inputText: text,
        tone: _selectedTone,
        length: _selectedLength,
        complexity: _selectedComplexity,
        includeHashtags: _includeHashtags,
      );
      ref.read(linkedInPostProvider.notifier).state = post;

      // Add to recent posts
      setState(() {
        _recentPosts.insert(0, post);
        if (_recentPosts.length > 10) {
          _recentPosts.removeLast();
        }
      });
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  void _showCupertinoAlert(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.mediumImpact();
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        content: const Text('Copied to clipboard!'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Done'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final generatedPost = ref.watch(linkedInPostProvider);
    final isLoading = ref.watch(isLoadingProvider);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background(context),
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('LinkedIn Post Crafter'),
            backgroundColor: AppColors.background(context),
            border: Border(
              bottom: BorderSide(
                color: AppColors.border(context),
                width: 0.5,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // View Mode Segmented Control
                  AnimatedCupertinoSegmentedControl<String>(
                    groupValue: _selectedViewMode,
                    onValueChanged: (value) {
                      setState(() => _selectedViewMode = value);
                      HapticFeedback.selectionClick();
                    },
                    children: {
                      'Editor': const Text('Editor'),
                      'Recent': const Text('Recent'),
                    },
                  ),
                  const SizedBox(height: 20),

                  // Conditional UI based on view mode
                  if (_selectedViewMode == 'Editor') ...[
                    _buildEditorView(isDark, generatedPost, isLoading),
                  ] else ...[
                    _buildRecentView(isDark),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorView(bool isDark, String? generatedPost, bool isLoading) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text Input Card
        CupertinoCard(
          backgroundColor: AppColors.secondaryBackground(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Achievement',
                style: AppTypography.headline.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: _textController,
                placeholder: 'Tell us your accomplishment...',
                placeholderStyle: AppTypography.body.copyWith(
                  color: AppColors.textTertiary(context),
                ),
                style: AppTypography.body.copyWith(
                  color: AppColors.textPrimary(context),
                ),
                minLines: 4,
                maxLines: 6,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkTertiaryBackground : AppColors.lightBackground,
                  border: Border.all(
                    color: AppColors.border(context),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Tone Selection
        _buildSectionHeader('Tone', LucideIcons.briefcase),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tones
              .map(
                (tone) => CupertinoChip(
                  label: tone,
                  selected: _selectedTone == tone,
                  onSelected: () => setState(() => _selectedTone = tone),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 20),

        // Length Segmented Control
        _buildSectionHeader('Post Length', LucideIcons.trendingUp),
        const SizedBox(height: 10),
        AnimatedCupertinoSegmentedControl<String>(
          groupValue: _selectedLength,
          onValueChanged: (value) => setState(() => _selectedLength = value),
          children: {
            'Short': const Text('Short'),
            'Long': const Text('Long'),
          },
        ),
        const SizedBox(height: 20),

        // Complexity Segmented Control
        _buildSectionHeader('Complexity', LucideIcons.award),
        const SizedBox(height: 10),
        AnimatedCupertinoSegmentedControl<String>(
          groupValue: _selectedComplexity,
          onValueChanged: (value) => setState(() => _selectedComplexity = value),
          children: {
            'Low': const Text('Accessible'),
            'High': const Text('Advanced'),
          },
        ),
        const SizedBox(height: 20),

        // Hashtags Toggle
        CupertinoCard(
          backgroundColor: AppColors.secondaryBackground(context),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.hash,
                    size: 20,
                    color: AppColors.textSecondary(context),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Include Hashtags',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ],
              ),
              CupertinoSwitch(
                value: _includeHashtags,
                onChanged: (value) => setState(() => _includeHashtags = value),
                activeColor: AppColors.primaryBlue,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Generate Button
        AnimatedCupertinoButton(
          text: 'Generate Post',
          isLoading: isLoading,
          onPressed: _generatePost,
          icon: const Icon(LucideIcons.sparkles, color: Colors.white),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
        const SizedBox(height: 20),

        // Output Section
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: isLoading
              ? SizedBox(
                  key: const ValueKey('loading'),
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CupertinoActivityIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Crafting your post...',
                          style: AppTypography.body.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : (generatedPost != null
                  ? _buildOutputCard(generatedPost)
                  : _buildEmptyState()),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildRecentView(bool isDark) {
    if (_recentPosts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(
                LucideIcons.history,
                size: 48,
                color: AppColors.textTertiary(context),
              ),
              const SizedBox(height: 16),
              Text(
                'No Recent Posts',
                style: AppTypography.headline.copyWith(
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Generate some posts to see them here',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentPosts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final post = _recentPosts[index];
        return CupertinoCard(
          backgroundColor: AppColors.secondaryBackground(context),
          onTap: () => _copyToClipboard(post),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarkdownBody(
                data: post.length > 200 ? '${post.substring(0, 200)}...' : post,
                styleSheet: MarkdownStyleSheet(
                  p: AppTypography.body.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                  em: AppTypography.body.copyWith(
                    color: AppColors.textSecondary(context),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tap to copy',
                style: AppTypography.caption2.copyWith(
                  color: AppColors.textTertiary(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primaryBlue,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.headline.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildOutputCard(String post) {
    return CupertinoCard(
      backgroundColor: AppColors.secondaryBackground(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Post',
                style: AppTypography.headline.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _copyToClipboard(post),
                child: Row(
                  children: [
                    const Icon(LucideIcons.copy, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Copy',
                      style: AppTypography.subheadline.copyWith(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MarkdownBody(
            data: post,
            styleSheet: MarkdownStyleSheet(
              p: AppTypography.body.copyWith(
                color: AppColors.textPrimary(context),
                height: 1.5,
              ),
              em: AppTypography.body.copyWith(
                color: AppColors.textSecondary(context),
                fontStyle: FontStyle.italic,
              ),
              strong: AppTypography.body.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Generated by LinkedIn Post Crafter',
            style: AppTypography.caption2.copyWith(
              color: AppColors.textTertiary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return CupertinoCard(
      backgroundColor: AppColors.secondaryBackground(context),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.sparkles,
            size: 48,
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Ready to craft your post?',
            style: AppTypography.headline.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your achievement and click Generate to create a professional LinkedIn post.',
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary(context),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
