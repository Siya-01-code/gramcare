import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'pages.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(
    GramCareApp(themeController: ThemeController(preferences: preferences)),
  );
}

class GramCareApp extends StatelessWidget {
  GramCareApp({super.key, DemoStore? store, ThemeController? themeController})
    : store = store ?? DemoStore(),
      themeController = themeController ?? ThemeController();
  final DemoStore store;
  final ThemeController themeController;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: themeController,
    builder: (context, _) => MaterialApp(
      title: 'GramCare',
      debugShowCheckedModeBanner: false,
      theme: gramCareTheme(Brightness.light),
      darkTheme: gramCareTheme(Brightness.dark),
      themeMode: themeController.isDark ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) =>
          ThemeScope(controller: themeController, child: child!),
      home: AnimatedBuilder(
        animation: store,
        builder: (context, _) => store.role == null
            ? LoginPage(store: store)
            : Dashboard(store: store),
      ),
    ),
  );
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key, required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(actions: const [ThemeToggle()]),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            padding: const EdgeInsets.all(24),
            shrinkWrap: true,
            children: [
              Icon(
                Icons.health_and_safety,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'GramCare',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Care closer to your village.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              const DemoNotice(),
              const SizedBox(height: 24),
              Text(
                'Choose a demo account',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Text(
                'No password needed. All people and organisations are fictional.',
              ),
              const SizedBox(height: 12),
              for (final role in Role.values)
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Icon(
                        role.icon,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(
                      role.label,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(role.person),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () => store.switchRole(role),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class DemoNotice extends StatelessWidget {
  const DemoNotice({super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF49371D)
          : const Color(0xFFFFF0DA),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      'Hackathon demo — no real medical or emergency service.',
      style: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFFFFDDA6)
            : const Color(0xFF79511C),
        fontSize: 13,
      ),
    ),
  );
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key, required this.store});
  final DemoStore store;
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int tab = 0;
  Role? previousRole;
  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    if (previousRole != s.role) {
      tab = 0;
      previousRole = s.role;
    }
    final patient = s.role == Role.patient;
    final labels = patient
        ? ['Home', 'Care', 'Blood', 'Wellness', 'Profile']
        : ['Dashboard', 'Directory', 'Wellness', 'Profile'];
    final icons = patient
        ? [
            Icons.home_outlined,
            Icons.favorite_outline,
            Icons.bloodtype_outlined,
            Icons.self_improvement,
            Icons.person_outline,
          ]
        : [
            Icons.dashboard_outlined,
            Icons.local_hospital_outlined,
            Icons.self_improvement,
            Icons.person_outline,
          ];
    final Widget page;
    if (patient) {
      page = switch (tab) {
        0 => PatientHome(
          store: s,
          navigate: (index) => setState(() => tab = index),
        ),
        1 => CarePage(store: s),
        2 => BloodPage(store: s),
        3 => WellnessPage(store: s),
        _ => ProfilePage(store: s),
      };
    } else {
      page = switch (tab) {
        0 => switch (s.role!) {
          Role.volunteer => VolunteerPage(store: s),
          Role.doctor => DoctorPage(store: s),
          Role.hospital => HospitalPage(store: s),
          Role.contributor => WellnessPage(store: s),
          _ => const SizedBox(),
        },
        1 => DirectoryPage(store: s),
        2 => WellnessPage(store: s),
        _ => ProfilePage(store: s),
      };
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GramCare',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          const ThemeToggle(),
          PopupMenuButton<Role>(
            tooltip: 'Switch role',
            icon: const Icon(Icons.switch_account_outlined),
            onSelected: s.switchRole,
            itemBuilder: (_) => [
              for (final r in Role.values)
                PopupMenuItem(value: r, child: Text(r.label)),
            ],
          ),
          IconButton(
            tooltip: 'Reset demo',
            icon: const Icon(Icons.restart_alt),
            onPressed: () async {
              final reset = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Reset demo?'),
                  content: const Text(
                    'Clear all bookings, requests, points and health entries, then return to account selection.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
              if (reset == true) {
                s.reset();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: [
                      Icon(
                        s.role!.icon,
                        color: Theme.of(context).colorScheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${s.role!.label} • ${s.accountName}',
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: DemoNotice(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: page,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (value) => setState(() => tab = value),
        destinations: [
          for (int i = 0; i < labels.length; i++)
            NavigationDestination(icon: Icon(icons[i]), label: labels[i]),
        ],
      ),
    );
  }
}
