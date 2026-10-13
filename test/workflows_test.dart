import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gramcare/main.dart';
import 'package:gramcare/models.dart';

void main() {
  test('matching, reward deduplication, booking collisions and reset', () {
    final s = DemoStore();
    final request = BloodRequest(s.nextId, 0, 'O+', 1, 1);
    expect(request.matches(0), false);
    expect(request.matches(3), true);
    expect(request.matches(1), false);
    expect(s.acceptDonation(request, 0), false);
    expect(s.confirmDonation(request, 3), false);
    expect(s.acceptDonation(request, 3), true);
    expect(s.confirmDonation(request, 3), true);
    expect(s.confirmDonation(request, 3), false);
    s.donorAccount = 3;
    expect(s.points, 100);
    expect(s.redeem(), true);
    expect(s.redeem(), false);
    expect(s.book(0, 'Tomorrow • 09:00', 'Sample visit'), true);
    expect(s.book(0, 'Tomorrow • 09:00', 'Sample visit'), false);
    s.switchRole(Role.doctor);
    expect(s.appointments.length, 1);
    s.reset();
    expect(s.role, null);
    expect(s.appointments, isEmpty);
    expect(s.points, 0);
  });

  Future<void> tap(WidgetTester tester, String text) async {
    final target = find.text(text);
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Future<DemoStore> launch(WidgetTester tester, Role role) async {
    tester.view.physicalSize = const Size(1000, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final s = DemoStore()..switchRole(role);
    await tester.pumpWidget(GramCareApp(store: s));
    return s;
  }

  testWidgets('patient → volunteer → hospital → volunteer assistance', (
    tester,
  ) async {
    final s = await launch(tester, Role.patient);
    await tap(tester, 'Request demo help');
    await tap(tester, 'Submit demo request');
    expect(s.assistance.single.stage, 0);
    s.switchRole(Role.volunteer);
    await tester.pumpAndSettle();
    await tap(tester, 'Accept assistance');
    await tap(tester, 'Assign hospital');
    await tap(tester, hospitals.first.name);
    expect(s.assistance.single.stage, 2);
    s.switchRole(Role.hospital);
    await tester.pumpAndSettle();
    await tap(tester, 'Acknowledge request');
    s.switchRole(Role.volunteer);
    await tester.pumpAndSettle();
    await tap(tester, 'Mark assistance completed');
    expect(s.assistance.single.stage, 4);
    expect(tester.takeException(), null);
  });

  testWidgets('hospital → donor → confirmed donation and points', (
    tester,
  ) async {
    final s = await launch(tester, Role.hospital);
    await tap(tester, 'Create blood request');
    await tap(tester, 'Create request');
    expect(s.blood.single.radius, 10);
    s.switchRole(Role.patient);
    await tester.pumpAndSettle();
    await tap(tester, 'Blood');
    await tap(tester, 'Accept demo blood request');
    s.switchRole(Role.hospital);
    await tester.pumpAndSettle();
    await tap(tester, 'Confirm donation • Meera Patil');
    expect(s.blood.single.fulfilled, true);
    expect(s.points, 100);
    expect(tester.takeException(), null);
  });

  testWidgets('consultation booking through patient summary', (tester) async {
    final s = await launch(tester, Role.patient);
    await tap(tester, 'Care');
    await tap(tester, 'Book consultation');
    await tester.enterText(
      find.byType(TextFormField),
      'Fictional routine check-in',
    );
    await tap(tester, 'Book');
    s.switchRole(Role.doctor);
    await tester.pumpAndSettle();
    for (final action in [
      'Accept consultation',
      'Simulate consultation',
      'Add sample summary',
    ]) {
      await tap(tester, action);
    }
    s.switchRole(Role.patient);
    await tester.pumpAndSettle();
    await tap(tester, 'Care');
    expect(find.text('Summary ready'), findsOneWidget);
    expect(find.textContaining('No diagnosis or prescription'), findsOneWidget);
    expect(tester.takeException(), null);
  });

  testWidgets('all dashboards and tabs fit a phone screen', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final s = DemoStore();
    await tester.pumpWidget(GramCareApp(store: s));
    for (final role in Role.values) {
      s.switchRole(role);
      await tester.pumpAndSettle();
      expect(tester.takeException(), null);
      final tabs = role == Role.patient
          ? ['Home', 'Care', 'Blood', 'Wellness', 'Profile']
          : ['Dashboard', 'Directory', 'Wellness', 'Profile'];
      for (final tab in tabs) {
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text(tab),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), null);
      }
    }
  });
}
