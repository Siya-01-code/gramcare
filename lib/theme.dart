import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const teal = Color(0xFF087F78);

class ThemeController extends ChangeNotifier {
  ThemeController({SharedPreferences? preferences})
    : _preferences = preferences,
      _dark = preferences?.getBool(preferenceKey) ?? false;

  static const preferenceKey = 'gramcare.darkMode';
  SharedPreferences? _preferences;
  bool _dark;
  bool _saving = false;
  bool get isDark => _dark;
  bool get saving => _saving;

  Future<bool> toggle() async {
    if (_saving) return true;
    _dark = !_dark;
    _saving = true;
    notifyListeners();
    try {
      final preferences = _preferences ??=
          await SharedPreferences.getInstance();
      return await preferences.setBool(preferenceKey, _dark);
    } catch (_) {
      return false;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}

class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeScope>()!.notifier!;
}

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ThemeScope.of(context);
    return IconButton(
      tooltip: controller.isDark
          ? 'Switch to light mode'
          : 'Switch to dark mode',
      icon: Icon(
        controller.isDark
            ? Icons.light_mode_outlined
            : Icons.dark_mode_outlined,
      ),
      onPressed: controller.saving
          ? null
          : () async {
              final saved = await controller.toggle();
              if (!saved && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Theme changed, but could not be saved. Try switching again.',
                    ),
                  ),
                );
              }
            },
    );
  }
}

ThemeData gramCareTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(seedColor: teal, brightness: brightness);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: dark ? scheme.surface : const Color(0xFFF3F8F7),
    appBarTheme: AppBarTheme(
      backgroundColor: dark ? scheme.surface : const Color(0xFFF3F8F7),
      foregroundColor: scheme.onSurface,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: const OutlineInputBorder(),
      filled: true,
      fillColor: dark ? scheme.surfaceContainerHighest : Colors.white,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: dark ? scheme.surfaceContainer : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
  );
}
