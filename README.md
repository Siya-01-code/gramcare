# GramCare

A Flutter Material 3 hackathon prototype with five role dashboards, fictional Indian sample records, and shared in-memory demo state. No backend, authentication, GPS, or APIs. The `shared_preferences` package stores the light/dark theme setting locally.

## Run

Requires Flutter 3.35.5 or newer with Dart 3.9.2 or newer.

```powershell
cd H:\RND\2026\gramcare-flutter
flutter pub get
flutter run -d chrome
```

For Android, start an emulator or connect a phone with USB debugging enabled:

```powershell
flutter devices
flutter run -d <android-device-id>
```

For Windows desktop: `flutter run -d windows`. Enable Windows Developer Mode if Flutter reports that plugin builds require symlink support. Restart the app fully after adding the SharedPreferences plugin; hot reload alone cannot register a new native plugin.

Use the sun/moon button at the top right of the login screen or any dashboard to switch between light and dark mode. Light is the default. The saved choice is restored on startup and retained when switching roles or resetting demo records. On web, preferences are saved per browser origin (use a fixed port, such as `flutter run -d chrome --web-port 8080`, to keep the same preference between development runs).

## Test and build

Validation on this machine: `flutter analyze --no-pub` passed with no issues; all six tests passed using `flutter test --no-pub --concurrency=1`, including theme persistence. The initial prototype's web build succeeded; rebuild it to include the theme changes. The APK build could not complete because Windows exhausted available memory/page-file capacity (Java error 1455), and the native build/Gradle processes crashed. Gradle is capped at a 2 GB heap and two workers in this project. Close memory-heavy applications or increase available virtual memory before retrying the APK command below. No APK is included.

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

APK output: `build\app\outputs\flutter-apk\app-debug.apk`.
If the Android build reports unaccepted SDK licenses, review and accept them with `flutter doctor --android-licenses`, then repeat the build.
For an optimised demo APK: `flutter build apk --release`. The generated Android configuration uses the debug signing key; configure your own release signing before distribution.

## Two-minute judge demo

Use the account-switch icon at the top right. Switching roles preserves all data; the reset icon clears the demo.

1. **0:00–0:20 — Patient / Donor:** tap **Request demo help**, leave Sonwadi selected, and submit.
2. **0:20–0:40 — Village Volunteer:** **Accept assistance**, then **Assign hospital → Sahyadri Community Hospital**.
3. **0:40–0:55 — Hospital Staff:** **Acknowledge request**. Switch back to Volunteer and **Mark assistance completed**. The Patient Care tab shows the complete timeline.
4. **0:55–1:15 — Hospital Staff:** **Create blood request**, keep **O+ / 1 unit / 10 km**, and create.
5. **1:15–1:35 — Patient / Donor:** open **Blood**, keep **Meera Patil**, and **Accept demo blood request**.
6. **1:35–2:00 — Hospital Staff:** **Confirm donation • Meera Patil**. Switch to Patient **Profile** to see 100 demo points and redeem a mock coupon.

### Consultation demo

Patient **Care → Book consultation**: choose hospital, doctor and slot; enter a fictional reason. Switch to **Doctor**, select the booked doctor, then **Accept consultation → Simulate consultation → Add sample summary**. Patient **Care** displays the summary. Duplicate doctor/slot bookings are prevented.

### Other features

- Care directory: specialties, sample availability and clearly labelled demo verification IDs.
- Wellness: simulated yoga playback, workout completion, progress, and sample home-care guidance. Contributor can add local mock content.
- Profile: period estimate, medicine reminders, mock organ-donation interest, vacancies and mock applications.
- Hospital: post vacancies and view sample applications.
- Home: fixed demo weather and general wellbeing tips.
- Blood: 1/5/10 km radii using predefined distances to each hospital. Sample donors can be switched on the Blood tab; rewards are tracked per donor.

## Demo boundaries

**Hackathon demo — no real medical or emergency service.** No help is dispatched, no calls are made, and no external messages are sent. Blood matching uses identical sample groups and is illustrative; clinical eligibility and compatibility require professional screening. Coupons have no monetary value or government endorsement. Organ interest is not official registration. Verification and content-review badges are simulated, not real credentials.

Health tools, consultations, assistance, and job applications share one fictional patient record, Meera Patil. Donor identities and rewards can be switched separately. Reminders are in-app only; no background alarms. Video playback is a labelled simulation. Period dates are estimates, not diagnosis or contraception.

Demo records disappear on reset or app restart. Only the theme preference persists. No personal information should be entered.

## Source map

- `lib/main.dart`: theme, login, navigation and role switching.
- `lib/models.dart`: sample records and session state.
- `lib/theme.dart`: light/dark palettes, toggle and SharedPreferences persistence.
- `lib/pages.dart`: role dashboards, forms and workflows.
- `test/workflows_test.dart`: end-to-end widget flows, radius/reward checks, booking conflicts, reset and phone layouts.
- `test/theme_test.dart`: saved light/dark preference, app recreation, navigation and demo reset.
