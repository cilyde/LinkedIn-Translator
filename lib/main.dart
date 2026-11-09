import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linkedin_translator/providers.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/index.dart';
import 'components/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // If .env is missing in some environments, continue with defaults
    debugPrint('Warning: .env file not found or failed to load: $e');
  }

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
    extends ConsumerState<LinkedInTranslatorScreen>
    with TickerProviderStateMixin {
  final _textController = TextEditingController();
  late FocusNode _textFocusNode;
  bool _textFieldFocused = false;
  String _selectedTone = 'Visionary';
  String _selectedLength = 'Short';
  String _selectedComplexity = 'Low';
  bool _includeHashtags = false;
  bool _toneChanged = false;
  bool _showAdvancedTooltip = false;

  final List<String> _tones = [
    'Visionary',
    'Professional',
    'Humblebrag',
    'Thought Leader',
  ];
  double _scrollOffset = 0.0;
  late ScrollController _scrollController;

  late AnimationController _ambientController;
  late AnimationController _miniLoaderController;

  @override
  void initState() {
    super.initState();
    _textFocusNode = FocusNode()
      ..addListener(() {
        if (mounted) {
          setState(() {
            _textFieldFocused = _textFocusNode.hasFocus;
          });
        }
      });

    _scrollController = ScrollController()
      ..addListener(() {
        if (!mounted) return;
        final offset = _scrollController.offset;
        if (_scrollOffset != offset) {
          setState(() {
            _scrollOffset = offset;
          });
        }
      });

    _textController.addListener(() {
      if (mounted) setState(() {});
    });

    _ambientController = AnimationController(
      duration: const Duration(seconds: 16),
      vsync: this,
    )..repeat();

    _miniLoaderController = AnimationController(
      duration: const Duration(milliseconds: 560),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _miniLoaderController.dispose();
    _scrollController.dispose();
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  Future<bool> _checkAndUpdateRequestCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month}-${today.day}';
    final savedDate = prefs.getString('request_date');
    final requestCount = prefs.getInt('request_count') ?? 0;

    // If it's a new day, reset the counter
    if (savedDate != dateKey) {
      await prefs.setString('request_date', dateKey);
      await prefs.setInt('request_count', 1);
      return true;
    }

    // Check if under limit for today
    if (requestCount < 20) {
      await prefs.setInt('request_count', requestCount + 1);
      return true;
    }

    return false;
  }

  Future<void> _generatePost() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      _showCupertinoAlert(
        'Missing Input',
        'Please enter a sentence before generating a post.',
      );
      return;
    }

    // Check rate limit
    final canProceed = await _checkAndUpdateRequestCount();
    if (!canProceed) {
      _showCupertinoAlert(
        'Daily Limit Reached',
        'Using it too much, dont you think?. Try again tomorrow!',
      );
      return;
    }

    // Close keyboard
    FocusScope.of(context).unfocus();

    ref.read(isLoadingProvider.notifier).state = true;
    _miniLoaderController
      ..reset()
      ..repeat();
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

      // Scroll to bottom to show output
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        );
      }
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
      _miniLoaderController.stop();
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
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: Transform.translate(
              offset: Offset(0, _scrollOffset * 0.06),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [Color(0xFF101220), Color(0xFF141836)]
                        : [Color(0xFFEFF4FA), Color(0xFFCFDFF2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ExcludeSemantics(
              child: AnimatedBuilder(
                animation: _ambientController,
                builder: (context, child) {
                  final progress = _ambientController.value;
                  final circle1Offset = Offset(
                    (sin(progress * 2 * pi) * 140),
                    (cos(progress * 2 * pi) * 140),
                  );
                  final circle2Offset = Offset(
                    (sin((progress + 0.47) * 2 * pi) * 220),
                    (cos((progress + 0.47) * 2 * pi) * 100),
                  );

                  return Stack(
                    children: [
                      Transform.translate(
                        offset: circle1Offset,
                        child: Center(
                          child: Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  (isDark
                                          ? Color(0xFF4974F5)
                                          : Color(0xFF4FA6FF))
                                      .withOpacity(0.28),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.78],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (isDark
                                              ? Color(0xFFCDF0FF)
                                              : Color(0xFFC7E6FF))
                                          .withOpacity(0.16),
                                  blurRadius: 58,
                                  spreadRadius: 32,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(
                          circle2Offset.dx * 0.6,
                          circle2Offset.dy * 0.6,
                        ),
                        child: Center(
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  (isDark
                                          ? Color(0xFF78D7E6)
                                          : Color(0xFF9BD9FF))
                                      .withOpacity(0.24),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.72],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (isDark
                                              ? Color(0xFFB4E8FC)
                                              : Color(0xFFB0DBFF))
                                          .withOpacity(0.16),
                                  blurRadius: 46,
                                  spreadRadius: 26,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(
                          -circle2Offset.dy * 0.5,
                          circle1Offset.dx * 0.3,
                        ),
                        child: Center(
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  (isDark
                                          ? Color(0xFF84CBFF)
                                          : Color(0xFFC0E6FF))
                                      .withOpacity(0.2),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.65],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (isDark
                                              ? Color(0xFFB8E5F8)
                                              : Color(0xFFD1ECFF))
                                          .withOpacity(0.14),
                                  blurRadius: 40,
                                  spreadRadius: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: circle2Offset,
                        child: Center(
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  (isDark
                                          ? Color(0xFF78D7E6)
                                          : Color(0xFF9BD9FF))
                                      .withOpacity(0.12),
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (isDark
                                              ? Color(0xFFB4E8FC)
                                              : Color(0xFFB0DBFF))
                                          .withOpacity(0.10),
                                  blurRadius: 38,
                                  spreadRadius: 22,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.transparent),
            ),
          ),
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              CupertinoSliverNavigationBar(
                largeTitle: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'LinkedIn',
                        style: GoogleFonts.outfit(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black,
                          letterSpacing: 0.25,
                        ),
                      ),
                      TextSpan(
                        text: ' Translator',
                        style: AppTypography.headline.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          color: isDark ? Colors.white : Colors.black,
                          letterSpacing: 0.25,
                        ),
                      ),
                    ],
                  ),
                ),
                backgroundColor: Colors.transparent,
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
                      _buildEditorView(isDark, generatedPost, isLoading),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: _textController.text.isNotEmpty ? 100 : 0,
                ),
              ),
            ],
          ),
          // Floating Translate Button
          Positioned(
            bottom: 32,
            right: 24,
            child: AnimatedOpacity(
              opacity: _textController.text.isNotEmpty && !isLoading
                  ? 1.0
                  : 0.0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: _textController.text.isEmpty || isLoading,
                child: AnimatedScale(
                  scale: _toneChanged ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.elasticOut,
                  child: AnimatedCupertinoButton(
                    text: 'Translate',
                    isLoading: isLoading,
                    onPressed: isLoading ? null : _generatePost,
                    icon: const Icon(
                      LucideIcons.sparkles,
                      color: Colors.white,
                      size: 18,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 28,
                    ),
                    backgroundColor: AppColors.primaryBlue,
                    borderRadius: 14,
                  ),
                ),
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
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: isLoading
                    ? _buildMiniGeneratingIndicator(isDark)
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                transform: Matrix4.identity()
                  ..scale(_textFieldFocused ? 1.02 : 1.0),
                transformAlignment: Alignment.topCenter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: CupertinoTextField(
                    focusNode: _textFocusNode,
                    controller: _textController,
                    placeholder: 'I fixed a bug today...',
                    placeholderStyle: AppTypography.body.copyWith(
                      color: AppColors.textTertiary(context),
                    ),
                    style: AppTypography.body.copyWith(
                      color: AppColors.textPrimary(context),
                    ),
                    minLines: _textController.text.isEmpty ? 2 : 4,
                    maxLines: 6,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkTertiaryBackground
                          : AppColors.lightBackground,
                      border: Border.all(
                        color: _textFieldFocused
                            ? AppColors.primaryBlue
                            : AppColors.border(context),
                        width: _textFieldFocused ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(_textFieldFocused ? 14 : 12),
                    suffix: _textController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _textController.clear();
                              setState(() {});
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Icon(
                                LucideIcons.x,
                                color: AppColors.textSecondary(context),
                                size: 18,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Tone Selection
        _buildSectionHeader('Tone', LucideIcons.briefcase),
        AnimatedContainer(
          height: _topToneHeight,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tones
              .map(
                (tone) => CupertinoChip(
                  label: tone,
                  selected: _selectedTone == tone,
                  onSelected: () {
                    setState(() {
                      _selectedTone = tone;
                      _toneChanged = true;
                    });
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted) {
                        setState(() => _toneChanged = false);
                      }
                    });
                  },
                ),
              )
              .toList(),
        ),
        AnimatedContainer(
          height: _bottomToneHeight,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        ),
        AnimatedContainer(
          height: _pushPullAboveLength,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        ),

        // Length Segmented Control
        _buildSectionHeader('Post Length', LucideIcons.trendingUp),
        const SizedBox(height: 10),
        AnimatedCupertinoSegmentedControl<String>(
          groupValue: _selectedLength,
          onValueChanged: (value) => setState(() => _selectedLength = value),
          children: {'Short': const Text('Short'), 'Long': const Text('Long')},
        ),
        const SizedBox(height: 20),

        // Complexity Segmented Control
        _buildSectionHeader('Complexity', LucideIcons.award),
        const SizedBox(height: 10),
        Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedCupertinoSegmentedControl<String>(
              groupValue: _selectedComplexity,
              onValueChanged: (value) {
                setState(() {
                  _selectedComplexity = value;
                  _showAdvancedTooltip = value == 'High';
                });

                if (value == 'High') {
                  Future.delayed(const Duration(milliseconds: 1500), () {
                    if (mounted && _selectedComplexity == 'High') {
                      setState(() => _showAdvancedTooltip = false);
                    }
                  });
                }
              },
              children: {
                'Low': const Text('Accessible'),
                'High': const Text('Advanced'),
              },
            ),
            Positioned(
              right: 34,
              top: -48,
              child: AnimatedOpacity(
                opacity: _showAdvancedTooltip ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: Visibility(
                  visible: _showAdvancedTooltip,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkTertiaryBackground
                          : AppColors.lightBackground,
                      border: Border.all(
                        color: AppColors.primaryBlueDark,
                        width: 1.2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'too much bro',
                      style: AppTypography.footnote.copyWith(
                        color: AppColors.primaryBlueLight,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
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
                  height: 240,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildClassyLoadingIndicator(isDark),
                        const SizedBox(height: 18),
                        Text(
                          'Polishing your LinkedIn story…',
                          style: AppTypography.body.copyWith(
                            color: AppColors.textSecondary(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'A stellar post is being etched with character.',
                          style: AppTypography.footnote.copyWith(
                            color: AppColors.textTertiary(context),
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

  Widget _buildClassyLoadingIndicator(bool isDark) {
    return AnimatedBuilder(
      animation: _ambientController,
      builder: (context, child) {
        final spin = _ambientController.value * 2 * pi;

        return SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _buildSpinnerRing(
                110,
                3.0,
                AppColors.primaryBlue.withOpacity(0.45),
                spin,
              ),
              _buildSpinnerRing(
                86,
                3.6,
                AppColors.accentOrange.withOpacity(0.55),
                -spin * 1.18,
              ),
              _buildSpinnerRing(
                62,
                2.2,
                AppColors.primaryBlue.withOpacity(0.9),
                spin * 1.68,
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? AppColors.darkBackground
                      : AppColors.lightBackground,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    LucideIcons.sparkles,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpinnerRing(
    double size,
    double thickness,
    Color color,
    double rotation,
  ) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: thickness),
        ),
      ),
    );
  }

  Widget _buildMiniGeneratingIndicator(bool isDark) {
    return AnimatedBuilder(
      animation: _miniLoaderController,
      builder: (context, child) {
        return SizedBox(
          key: const ValueKey('mini-loading'),
          height: 32,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: List.generate(3, (index) {
              final progress =
                  (_miniLoaderController.value + index * 0.14) % 1.0;
              final sinVal = sin(progress * 2 * pi);
              final yOffset = sinVal * 10;
              final scale = 0.85 + (sinVal.abs() * 0.3);
              final dotColor = index == 1
                  ? AppColors.accentOrange.withOpacity(
                      0.85 + 0.12 * sinVal.abs(),
                    )
                  : AppColors.primaryBlue.withOpacity(
                      0.65 + 0.25 * sinVal.abs(),
                    );

              return Transform.translate(
                offset: Offset(0, yOffset),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dotColor,
                      boxShadow: [
                        BoxShadow(
                          color: dotColor.withOpacity(0.45),
                          blurRadius: 7,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  double get _topToneHeight {
    switch (_selectedTone) {
      case 'Visionary':
        return 8;
      case 'Professional':
        return 12;
      case 'Humblebrag':
        return 16;
      case 'Thought Leader':
        return 14;
      default:
        return 10;
    }
  }

  double get _bottomToneHeight {
    switch (_selectedTone) {
      case 'Visionary':
        return 16;
      case 'Professional':
        return 12;
      case 'Humblebrag':
        return 8;
      case 'Thought Leader':
        return 10;
      default:
        return 12;
    }
  }

  double get _pushPullAboveLength {
    // Inverse of bottom tone height for push/pull effect
    switch (_selectedTone) {
      case 'Visionary':
        return 8;
      case 'Professional':
        return 12;
      case 'Humblebrag':
        return 16;
      case 'Thought Leader':
        return 14;
      default:
        return 12;
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryBlue),
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
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
          parent: AlwaysStoppedAnimation(1.0),
          curve: Curves.elasticOut,
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: AlwaysStoppedAnimation(1.0),
                curve: Curves.easeOutCubic,
              ),
            ),
        child: CupertinoCard(
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
                'Generated by LinkedIn Translator',
                style: AppTypography.caption2.copyWith(
                  color: AppColors.textTertiary(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.9, end: 1.0).animate(
        CurvedAnimation(
          parent: AlwaysStoppedAnimation(1.0),
          curve: Curves.easeOutCubic,
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: AlwaysStoppedAnimation(1.0),
                curve: Curves.easeOutCubic,
              ),
            ),
        child: CupertinoCard(
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
        ),
      ),
    );
  }
}
