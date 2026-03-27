# 🛠️ Implementation Guide - LinkedIn Translator UI Overhaul

## Quick Start

### Using Components

#### Import Components
```dart
import 'package:linkedin_translator/components/index.dart';
import 'package:linkedin_translator/theme/index.dart';
```

#### Use in Your Widgets
```dart
// Segmented Control
AnimatedCupertinoSegmentedControl<String>(
  groupValue: _selectedValue,
  onValueChanged: (value) => setState(() => _selectedValue = value),
  children: {
    'Option1': const Text('Option 1'),
    'Option2': const Text('Option 2'),
  },
)

// Card
CupertinoCard(
  backgroundColor: AppColors.secondaryBackground(context),
  child: Text('Content'),
)

// Button
AnimatedCupertinoButton(
  text: 'Action',
  onPressed: () => handleAction(),
)

// Chip
CupertinoChip(
  label: 'Tag',
  selected: isSelected,
  onSelected: () => toggleSelection(),
)

// Text Field
AnimatedCupertinoTextField(
  controller: _controller,
  placeholder: 'Enter text...',
  label: 'Label',
)
```

---

## Color System Usage

### Getting Theme-Aware Colors

```dart
// In any widget that has BuildContext
final primaryText = AppColors.textPrimary(context);
final secondaryBg = AppColors.secondaryBackground(context);
final borderColor = AppColors.border(context);

// Or use static constants
final brandBlue = AppColors.primaryBlue;
final errorColor = AppColors.error;
```

### Creating Adaptive Widgets

```dart
class MyAdaptiveWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    
    return Container(
      color: AppColors.background(context),
      child: Text(
        'Hello',
        style: AppTypography.body.copyWith(
          color: AppColors.textPrimary(context),
        ),
      ),
    );
  }
}
```

---

## Typography Usage

### Predefined Styles

```dart
// Large Title
Text('Screen Title', style: AppTypography.largeTitle)

// Heading
Text('Section Header', style: AppTypography.headline)

// Body Text
Text('Main content goes here', style: AppTypography.body)

// Caption
Text('Metadata', style: AppTypography.caption2)
```

### Extending Styles

```dart
// Change color
AppTypography.body.copyWith(
  color: AppColors.textSecondary(context),
)

// Change weight
AppTypography.headline.copyWith(
  fontWeight: FontWeight.w700,
)

// Chain multiple changes
AppTypography.body.copyWith(
  color: AppColors.textSecondary(context),
  fontSize: 14,
  letterSpacing: 0.5,
)
```

---

## Animation Recipes

### Fade Transition

```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  child: isLoading
      ? const LoadingWidget()
      : const ContentWidget(),
)
```

### Scale Feedback

```dart
GestureDetector(
  onTap: () => _controller.forward().then((_) {
    _controller.reverse();
    handleTap();
  }),
  child: ScaleTransition(
    scale: _animation,
    child: MyButton(),
  ),
)
```

### Implicit Animation

```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 200),
  decoration: BoxDecoration(
    color: isSelected ? Colors.blue : Colors.grey,
    borderRadius: BorderRadius.circular(8),
  ),
  child: const Padding(padding: EdgeInsets.all(16)),
)
```

---

## Creating Custom Cupertino Widgets

### Template

```dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/index.dart';

class MyCupertinoWidget extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  const MyCupertinoWidget({
    super.key,
    required this.label,
    this.onTap,
    this.enabled = true,
  });

  @override
  State<MyCupertinoWidget> createState() => _MyCupertinoWidgetState();
}

class _MyCupertinoWidgetState extends State<MyCupertinoWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!widget.enabled) return;
    _controller.forward().then((_) {
      _controller.reverse();
      widget.onTap?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return ScaleTransition(
      scale: _animation,
      child: GestureDetector(
        onTap: _onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkTertiaryBackground
                : AppColors.lightBackground,
            border: Border.all(
              color: AppColors.border(context),
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Text(
            widget.label,
            style: AppTypography.headline.copyWith(
              color: AppColors.textPrimary(context),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## Screen Structure

### Recommended Layout

```dart
class MyScreen extends ConsumerStatefulWidget {
  const MyScreen({super.key});

  @override
  ConsumerState<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends ConsumerState<MyScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background(context),
      child: CustomScrollView(
        slivers: [
          // Navigation Bar
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Screen Title'),
            backgroundColor: AppColors.background(context),
            border: Border(
              bottom: BorderSide(
                color: AppColors.border(context),
                width: 0.5,
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Your content here
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Best Practices

### ✅ Do

- ✅ Always pass `BuildContext` to color helper methods
- ✅ Use `AppTypography` constants for text styling
- ✅ Wrap animations with proper `TickerProvider`
- ✅ Use `CupertinoPageScaffold` instead of `Scaffold`
- ✅ Test both light and dark mode versions
- ✅ Include haptic feedback for interactions
- ✅ Set proper `duration` and `curve` for animations

### ❌ Don't

- ❌ Hardcode colors - use the color system
- ❌ Use `Scaffold` instead of `CupertinoPageScaffold`
- ❌ Create animations without `vsync` from `TickerProvider`
- ❌ Forget to dispose animation controllers
- ❌ Use `print()` in production code
- ❌ Ignore dark mode support
- ❌ Use overly complex animation curves

---

## Testing Dark Mode

### Run in Dark Mode

```bash
# Command line (iOS)
flutter run -d ios

# Then toggle in Simulator:
# CMD + SHIFT + A (appearance)
```

### Test Colors Programmatically

```dart
// In widget tests
testWidgets('Dark mode colors', (WidgetTester tester) async {
  MediaQuery.of(context).platformBrightness == Brightness.dark;
  
  final darkBgColor = AppColors.background(context);
  expect(darkBgColor, AppColors.darkBackground);
});
```

---

## Common Tasks

### Add a New Segmented Control

```dart
AnimatedCupertinoSegmentedControl<String>(
  groupValue: _selectedValue,
  onValueChanged: (value) {
    setState(() => _selectedValue = value);
    HapticFeedback.selectionClick();
  },
  children: {
    'Option1': const Text('Option 1'),
    'Option2': const Text('Option 2'),
    'Option3': const Text('Option 3'),
  },
)
```

### Add a Loading State

```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  child: isLoading
      ? const SizedBox(
          key: ValueKey('loading'),
          height: 100,
          child: Center(child: CupertinoActivityIndicator()),
        )
      : MyContent(key: const ValueKey('content')),
)
```

### Create a Settings Toggle

```dart
CupertinoCard(
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text('Enable Notifications',
        style: AppTypography.body.copyWith(
          color: AppColors.textPrimary(context),
        ),
      ),
      CupertinoSwitch(
        value: _notificationsEnabled,
        onChanged: (value) =>
          setState(() => _notificationsEnabled = value),
        activeColor: AppColors.primaryBlue,
      ),
    ],
  ),
)
```

### Display an Alert

```dart
showCupertinoDialog(
  context: context,
  builder: (context) => CupertinoAlertDialog(
    title: const Text('Confirm Action'),
    content: const Text('Are you sure?'),
    actions: [
      CupertinoDialogAction(
        child: const Text('Cancel'),
        onPressed: () => Navigator.pop(context),
      ),
      CupertinoDialogAction(
        isDestructiveAction: true,
        child: const Text('Delete'),
        onPressed: () {
          Navigator.pop(context);
          handleDelete();
        },
      ),
    ],
  ),
);
```

---

## Troubleshooting

### Issue: Animations Not Running

**Solution**: Ensure your widget has a `TickerProvider`

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget>
    with SingleTickerProviderStateMixin { // Add this
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this, // Must pass 'this'
    );
  }
}
```

### Issue: Colors Not Adapting to Dark Mode

**Solution**: Always use helper methods instead of static colors

```dart
// ❌ Wrong
Text('Hello', style: TextStyle(color: Colors.black))

// ✅ Correct
Text('Hello', style: TextStyle(
  color: AppColors.textPrimary(context),
))
```

### Issue: Segmented Control Not Responding

**Solution**: Ensure state is being updated properly

```dart
AnimatedCupertinoSegmentedControl<String>(
  groupValue: _selectedValue, // Must match selected value
  onValueChanged: (value) {
    setState(() => _selectedValue = value); // Update state
  },
  children: {...},
)
```

---

## Performance Tips

1. **Use const widgets** where possible
2. **Lazy load lists** with `.separated()` or `.builder()`
3. **Dispose animations** properly
4. **Avoid rebuilding** entire trees
5. **Use `RepaintBoundary`** for expensive widgets
6. **Profile with DevTools** before optimizing

---

## Resources

- [Cupertino Design Guide](https://developer.apple.com/design/human-interface-guidelines/ios/)
- [Flutter Cupertino Widgets](https://api.flutter.dev/flutter/cupertino/cupertino-library.html)
- [Animation Guidelines](https://material.io/design/motion/)

---

**Last Updated**: March 2026  
**Branch**: `ui-overhaul-cupertino`
