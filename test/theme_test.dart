import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gramcare/main.dart';
import 'package:gramcare/models.dart';
import 'package:gramcare/theme.dart';

void main() {
  testWidgets('theme saves, survives role/reset/restart and returns to light', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = DemoStore();
    final controller = ThemeController(preferences: preferences);
    await tester.pumpWidget(
      GramCareApp(store: store, themeController: controller),
    );
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.light,
    );

    await tester.tap(find.byTooltip('Switch to dark mode'));
    await tester.pumpAndSettle();
    expect(preferences.getBool(ThemeController.preferenceKey), true);
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.dark,
    );

    store.switchRole(Role.patient);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Care'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Switch to light mode'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );
    expect(preferences.getBool(ThemeController.preferenceKey), false);
    await tester.tap(find.byTooltip('Switch to dark mode'));
    await tester.pumpAndSettle();
    store.reset();
    await tester.pumpAndSettle();
    expect(find.byTooltip('Switch to light mode'), findsOneWidget);

    // Recreate the app and controller using the stored preference, as on launch.
    await tester.pumpWidget(const SizedBox());
    await preferences.reload();
    await tester.pumpWidget(
      GramCareApp(themeController: ThemeController(preferences: preferences)),
    );
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.dark,
    );
    await tester.tap(find.byTooltip('Switch to light mode'));
    await tester.pumpAndSettle();
    await preferences.reload();
    expect(ThemeController(preferences: preferences).isDark, false);
    expect(tester.takeException(), null);
  });
}
