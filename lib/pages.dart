import 'package:flutter/material.dart';
import 'models.dart';
import 'theme.dart' show teal;

void feedback(BuildContext context, String message) => ScaffoldMessenger.of(
  context,
).showSnackBar(SnackBar(content: Text(message)));

class Section extends StatelessWidget {
  const Section(this.title, {super.key, this.subtitle, required this.children});
  final String title;
  final String? subtitle;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
      if (subtitle != null)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            subtitle!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      const SizedBox(height: 16),
      ...children,
    ],
  );
}

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.favorite_outline,
    this.children = const [],
  });
  final String title;
  final String? subtitle;
  final IconData icon;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(subtitle!),
            ),
          if (children.isNotEmpty) const SizedBox(height: 16),
          ...children,
        ],
      ),
    ),
  );
}

Widget empty(String text) => Panel(
  title: 'Nothing here yet',
  subtitle: text,
  icon: Icons.inbox_outlined,
);
Widget gap() => const SizedBox(height: 12);
Widget badge(String text) => Padding(
  padding: const EdgeInsets.only(top: 8),
  child: Builder(
    builder: (context) => Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
);

Widget choice<T>(
  String label,
  T value,
  List<T> items,
  String Function(T) name,
  ValueChanged<T> onChanged,
) => Padding(
  padding: const EdgeInsets.only(bottom: 12),
  child: DropdownButtonFormField<T>(
    initialValue: value,
    isExpanded: true,
    decoration: InputDecoration(labelText: label),
    items: [
      for (final item in items)
        DropdownMenuItem(
          value: item,
          child: Text(name(item), overflow: TextOverflow.ellipsis),
        ),
    ],
    onChanged: (v) {
      if (v != null) {
        onChanged(v);
      }
    },
  ),
);

Future<void> showInfo(BuildContext context, String title, String text) =>
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(text)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );

Future<void> assistanceForm(BuildContext context, DemoStore s) async {
  var issue = 'Travel assistance for a hospital visit';
  var village = s.village;
  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, update) => AlertDialog(
        title: const Text('Request demo assistance'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This does not contact emergency services or dispatch help. For a real emergency, contact local emergency services directly.',
              ),
              gap(),
              choice(
                'Issue',
                issue,
                [
                  'Travel assistance for a hospital visit',
                  'Urgent care coordination',
                  'Support for an older adult',
                ],
                (v) => v,
                (v) => update(() => issue = v),
              ),
              choice(
                'Village',
                village,
                villages,
                (v) => v,
                (v) => update(() => village = v),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              s.assistance.add(Assistance(s.nextId, issue, village));
              s.changed();
              Navigator.pop(ctx);
              feedback(
                context,
                'Demo request submitted. Switch to Village Volunteer to continue.',
              );
            },
            child: const Text('Submit demo request'),
          ),
        ],
      ),
    ),
  );
}

class PatientHome extends StatelessWidget {
  const PatientHome({super.key, required this.store, required this.navigate});
  final DemoStore store;
  final ValueChanged<int> navigate;
  @override
  Widget build(BuildContext context) => Section(
    'Hello, ${store.accountName.split(' ').first}',
    subtitle: 'A little support. A healthier community.',
    children: [
      Container(
        padding: const EdgeInsets.all(22),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: teal,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your village.\nYour care circle.',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            gap(),
            const Text(
              'Connect with a doctor or ask your village team for support.',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            gap(),
            FilledButton.tonalIcon(
              onPressed: () => navigate(1),
              icon: const Icon(Icons.calendar_month),
              label: const Text('Book a consultation'),
            ),
          ],
        ),
      ),
      Panel(
        title: 'Emergency assistance',
        subtitle: 'Coordinate a fictional request with your village team.',
        icon: Icons.emergency_outlined,
        children: [
          FilledButton.icon(
            onPressed: () => assistanceForm(context, store),
            icon: const Icon(Icons.volunteer_activism),
            label: const Text('Request demo help'),
          ),
        ],
      ),
      Panel(
        title: 'Your care at a glance',
        children: [
          Text(
            '${store.appointments.length} consultations  •  ${store.assistance.where((a) => a.stage < 4).length} open help requests',
          ),
          gap(),
          OutlinedButton(
            onPressed: () => navigate(2),
            child: Text(
              '${store.blood.where((r) => r.matches(store.donorAccount) && !r.fulfilled && !r.accepted.contains(store.donorAccount)).length} matching blood alerts',
            ),
          ),
        ],
      ),
      Panel(
        title: 'Demo weather • 31°C',
        subtitle: 'Sonwadi • warm and sunny • fixed sample',
        icon: Icons.wb_sunny_outlined,
        children: [
          const Text(
            'Keep drinking water nearby, take breaks in the shade, and plan outdoor activity for cooler hours.',
          ),
        ],
      ),
      for (final m in store.medicines.where((m) => !m.taken))
        Panel(
          title: m.name,
          subtitle: 'In-app reminder • ${m.time.format(context)}',
          icon: Icons.medication_outlined,
          children: [
            OutlinedButton(
              onPressed: () {
                m.taken = true;
                store.changed();
                feedback(context, 'Marked taken in this demo.');
              },
              child: const Text('Mark taken'),
            ),
          ],
        ),
      const Text(
        'Session-only data: restarting the app clears changes. Switch roles using the account icon above.',
      ),
    ],
  );
}

class CarePage extends StatelessWidget {
  const CarePage({super.key, required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) => Section(
    'Your care',
    subtitle: 'Book locally, then switch to the doctor account to continue.',
    children: [
      FilledButton.icon(
        onPressed: () => bookingForm(context, store),
        icon: const Icon(Icons.add),
        label: const Text('Book consultation'),
      ),
      gap(),
      if (store.appointments.isEmpty)
        empty('Book a consultation to see its progress and summary here.'),
      for (final a in store.appointments.reversed)
        appointmentCard(context, a, store, false),
      Text(
        'Assistance timeline',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      gap(),
      OutlinedButton.icon(
        onPressed: () => assistanceForm(context, store),
        icon: const Icon(Icons.emergency_outlined),
        label: const Text('Request demo help'),
      ),
      gap(),
      if (store.assistance.isEmpty)
        empty('Your village assistance requests will appear here.'),
      for (final a in store.assistance.reversed) assistanceCard(a),
      DirectoryPage(store: store),
    ],
  );
}

Future<void> bookingForm(BuildContext context, DemoStore s) async {
  var hospital = 0, doctor = 0;
  var slot = 'Tomorrow • 09:00';
  var concern = '';
  final form = GlobalKey<FormState>();
  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, update) => AlertDialog(
        title: const Text('Book a consultation'),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Form(
              key: form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  choice(
                    'Demo-verified hospital',
                    hospital,
                    [0, 1, 2],
                    (v) => hospitals[v].name,
                    (v) => update(() {
                      hospital = v;
                      doctor = doctors.indexWhere((d) => d.hospital == v);
                    }),
                  ),
                  KeyedSubtree(
                    key: ValueKey(hospital),
                    child: choice(
                      'Doctor',
                      doctor,
                      [
                        for (var i = 0; i < doctors.length; i++)
                          if (doctors[i].hospital == hospital) i,
                      ],
                      (v) => doctors[v].name,
                      (v) => update(() => doctor = v),
                    ),
                  ),
                  choice(
                    'Demo slot',
                    slot,
                    [
                      'Tomorrow • 09:00',
                      'Tomorrow • 11:00',
                      'Tomorrow • 15:30',
                    ],
                    (v) => v,
                    (v) => slot = v,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Reason for visit (fictional)',
                    ),
                    maxLength: 160,
                    onChanged: (v) => concern = v.trim(),
                    validator: (v) => (v ?? '').trim().isEmpty
                        ? 'Enter a fictional reason for the visit.'
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!form.currentState!.validate()) {
                return;
              }
              if (!s.book(doctor, slot, concern)) {
                showInfo(
                  ctx,
                  'Slot already booked',
                  'Choose another slot or doctor.',
                );
                return;
              }
              Navigator.pop(ctx);
              feedback(
                context,
                'Booked. Switch to Doctor and choose ${doctors[doctor].name}.',
              );
            },
            child: const Text('Book'),
          ),
        ],
      ),
    ),
  );
}

Widget appointmentCard(
  BuildContext context,
  Appointment a,
  DemoStore s,
  bool doctorView,
) => Panel(
  title: doctors[a.doctor].name,
  subtitle:
      '${hospitals[doctors[a.doctor].hospital].name}\n${a.slot}\nFictional patient: Meera Patil • ${a.concern}',
  icon: Icons.calendar_month,
  children: [
    badge(a.status),
    if (a.summary.isNotEmpty)
      Padding(padding: const EdgeInsets.only(top: 12), child: Text(a.summary)),
    if (doctorView && a.stage < 3)
      Padding(
        padding: const EdgeInsets.only(top: 12),
        child: FilledButton(
          onPressed: () {
            a.stage++;
            if (a.stage == 3) {
              a.summary =
                  'Sample consultation summary\nFictional concern reviewed in a simulated session. No diagnosis or prescription was generated. Arrange a real clinical assessment for personal medical advice.\nFollow-up: sample check-in after 7 days.';
            }
            s.changed();
            feedback(context, a.status);
          },
          child: Text(
            [
              'Accept consultation',
              'Simulate consultation',
              'Add sample summary',
            ][a.stage],
          ),
        ),
      ),
  ],
);

Widget assistanceCard(Assistance a, {List<Widget> actions = const []}) => Panel(
  title: 'Help request #${a.id}',
  subtitle: '${a.issue}\n${a.village} • fictional patient Meera Patil',
  icon: Icons.volunteer_activism,
  children: [
    if (a.hospital != null) Text('Assigned: ${hospitals[a.hospital!].name}'),
    gap(),
    for (var i = 0; i < 5; i++)
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Icon(
              i <= a.stage ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 20,
              color: i <= a.stage ? const Color(0xFF4DB6AC) : Colors.grey,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                [
                  'Submitted',
                  'Volunteer accepted',
                  'Hospital assigned',
                  'Hospital acknowledged',
                  'Assistance completed',
                ][i],
                style: TextStyle(
                  fontWeight: i == a.stage
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    ...actions,
  ],
);

class VolunteerPage extends StatelessWidget {
  const VolunteerPage({super.key, required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) => Section(
    'Village support team',
    subtitle: 'Coordinate the next step for your community.',
    children: [
      const Panel(
        title: 'Sonwadi circle • 5 volunteers',
        icon: Icons.groups_outlined,
        subtitle:
            'Arjun Deshmukh • coordinator\nPooja Kale • visit support\nImran Shaikh • transport coordination\nSavita More • family liaison\nDeepak Jadhav • hospital liaison',
      ),
      if (store.assistance.isEmpty)
        empty('Switch to Patient / Donor and submit a demo help request.'),
      for (final a in store.assistance.reversed)
        assistanceCard(
          a,
          actions: [
            if (a.stage == 0)
              FilledButton(
                onPressed: () {
                  a.stage = 1;
                  store.changed();
                  feedback(context, 'Accepted by Arjun Deshmukh.');
                },
                child: const Text('Accept assistance'),
              ),
            if (a.stage == 1)
              FilledButton(
                onPressed: () async {
                  final selected = await showDialog<int>(
                    context: context,
                    builder: (ctx) => SimpleDialog(
                      title: const Text('Assign a hospital'),
                      children: [
                        for (int i = 0; i < hospitals.length; i++)
                          SimpleDialogOption(
                            onPressed: () => Navigator.pop(ctx, i),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(hospitals[i].name),
                            ),
                          ),
                      ],
                    ),
                  );
                  if (selected != null) {
                    a.hospital = selected;
                    a.stage = 2;
                    store.changed();
                  }
                },
                child: const Text('Assign hospital'),
              ),
            if (a.stage == 2)
              const Text(
                'Waiting for Hospital Staff to acknowledge this request.',
              ),
            if (a.stage == 3)
              FilledButton(
                onPressed: () {
                  a.stage = 4;
                  store.changed();
                  feedback(context, 'Demo assistance completed.');
                },
                child: const Text('Mark assistance completed'),
              ),
          ],
        ),
    ],
  );
}

class DoctorPage extends StatelessWidget {
  const DoctorPage({super.key, required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) => Section(
    'Consultation desk',
    subtitle: 'Fictional records • simulated consultations only',
    children: [
      choice(
        'Doctor account',
        store.doctorAccount,
        List.generate(doctors.length, (i) => i),
        (v) => doctors[v].name,
        (v) {
          store.doctorAccount = v;
          store.changed();
        },
      ),
      if (!store.appointments.any((a) => a.doctor == store.doctorAccount))
        empty(
          'No bookings for this doctor. Book from the Patient Care tab or select another doctor.',
        ),
      for (final a in store.appointments.where(
        (a) => a.doctor == store.doctorAccount,
      ))
        appointmentCard(context, a, store, true),
    ],
  );
}

class DirectoryPage extends StatelessWidget {
  const DirectoryPage({super.key, required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) => Section(
    'Care directory',
    subtitle:
        'Fictional hospitals and clinicians. Verification badges are demo labels.',
    children: [
      for (var i = 0; i < hospitals.length; i++)
        Panel(
          title: hospitals[i].name,
          subtitle:
              '${hospitals[i].city}\n${hospitals[i].specialties.join(' • ')}',
          icon: Icons.local_hospital_outlined,
          children: [
            badge('Demo verified • ${hospitals[i].verification}'),
            gap(),
            for (final d in doctors.where((d) => d.hospital == i))
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '${d.name} — ${d.specialty}\nDemo verified • ${d.verification}\nSample availability: tomorrow, 09:00 / 11:00 / 15:30',
                ),
              ),
          ],
        ),
    ],
  );
}

class HospitalPage extends StatelessWidget {
  const HospitalPage({super.key, required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) => Section(
    'Hospital coordination',
    subtitle: 'Manage local requests and community support.',
    children: [
      choice(
        'Hospital account',
        store.hospitalAccount,
        [0, 1, 2],
        (v) => hospitals[v].name,
        (v) {
          store.hospitalAccount = v;
          store.changed();
        },
      ),
      Text(
        'Assistance requests',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      gap(),
      if (!store.assistance.any((a) => a.hospital == store.hospitalAccount))
        empty('A volunteer must assign a request to this hospital first.'),
      for (final a in store.assistance.where(
        (a) => a.hospital == store.hospitalAccount,
      ))
        assistanceCard(
          a,
          actions: [
            if (a.stage == 2)
              FilledButton(
                onPressed: () {
                  a.stage = 3;
                  store.changed();
                  feedback(
                    context,
                    'Acknowledged. Volunteer can now complete assistance.',
                  );
                },
                child: const Text('Acknowledge request'),
              ),
          ],
        ),
      BloodPage(store: store),
      gap(),
      StaffingPage(store: store),
    ],
  );
}

Future<void> bloodForm(BuildContext context, DemoStore s) async {
  var group = 'O+', radius = 10, units = 1;
  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, update) => AlertDialog(
        title: const Text('Create blood request'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(hospitals[s.hospitalAccount].name),
              gap(),
              choice(
                'Blood group',
                group,
                bloodGroups,
                (v) => v,
                (v) => update(() => group = v),
              ),
              choice(
                'Units',
                units,
                [1, 2, 3, 4, 5],
                (v) => '$v',
                (v) => update(() => units = v),
              ),
              choice(
                'Radius',
                radius,
                [1, 5, 10],
                (v) => '$v km',
                (v) => update(() => radius = v),
              ),
              const Text(
                'Distances are predefined. Matching is illustrative; clinical eligibility and compatibility require professional screening.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              s.blood.add(
                BloodRequest(s.nextId, s.hospitalAccount, group, units, radius),
              );
              s.changed();
              Navigator.pop(ctx);
              feedback(
                context,
                'Created. Matching sample donors now have an in-app alert.',
              );
            },
            child: const Text('Create request'),
          ),
        ],
      ),
    ),
  );
}

class BloodPage extends StatelessWidget {
  const BloodPage({super.key, required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) {
    final staff = store.role == Role.hospital;
    final requests = store.blood
        .where(
          (r) => staff
              ? r.hospital == store.hospitalAccount
              : r.matches(store.donorAccount),
        )
        .toList();
    return Section(
      staff ? 'Blood requests' : 'Give a little. Help a life.',
      subtitle:
          'Illustrative matching only. Clinical eligibility and compatibility require professional screening.',
      children: [
        if (staff)
          FilledButton.icon(
            onPressed: () => bloodForm(context, store),
            icon: const Icon(Icons.add),
            label: const Text('Create blood request'),
          )
        else ...[
          choice(
            'Sample donor account',
            store.donorAccount,
            List.generate(donors.length, (i) => i),
            (v) => '${donors[v].name} • ${donors[v].group}',
            (v) {
              store.donorAccount = v;
              store.changed();
            },
          ),
          Panel(
            title:
                '${donors[store.donorAccount].group} • ${donors[store.donorAccount].village}',
            subtitle:
                'Simulated distances to hospitals: ${donors[store.donorAccount].distances.join(' / ')} km (directory order). No device location used.',
            icon: Icons.location_on_outlined,
          ),
        ],
        gap(),
        if (requests.isEmpty)
          empty(
            staff
                ? 'Create a request to alert matching mock donors.'
                : 'No matching alerts. Try a hospital O+ request within 10 km for Meera Patil.',
          ),
        for (final r in requests.reversed)
          Panel(
            title:
                '${r.group} blood • ${r.units} ${r.units == 1 ? 'unit' : 'units'}',
            subtitle:
                '${hospitals[r.hospital].name}\nRequest #${r.id} • ${r.radius} km sample radius',
            icon: Icons.bloodtype,
            children: [
              badge(
                r.fulfilled
                    ? 'Fulfilled • donation confirmed'
                    : '${r.confirmed.length}/${r.units} units confirmed',
              ),
              if (staff) ...[
                Text(
                  '${donors.where((d) => r.matches(donors.indexOf(d))).length} matching sample donors • ${r.accepted.length} accepted',
                ),
                gap(),
                if (r.accepted.isEmpty)
                  const Text(
                    'Waiting for a matching donor to accept in their Blood tab.',
                  ),
                for (final donor in r.accepted)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: r.confirmed.contains(donor)
                        ? Text(
                            '${donors[donor].name} • confirmed • +100 demo points',
                          )
                        : OutlinedButton(
                            onPressed: r.fulfilled
                                ? null
                                : () {
                                    store.confirmDonation(r, donor);
                                    feedback(
                                      context,
                                      'Demo donation confirmed. 100 points awarded to ${donors[donor].name}.',
                                    );
                                  },
                            child: Text(
                              'Confirm donation • ${donors[donor].name}',
                            ),
                          ),
                  ),
              ] else ...[
                Text(
                  '${donors[store.donorAccount].distances[r.hospital]} km predefined distance',
                ),
                gap(),
                if (r.confirmed.contains(store.donorAccount))
                  const Text(
                    'Thank you! 100 demo points were added to your profile.',
                  )
                else if (r.accepted.contains(store.donorAccount))
                  Text(
                    r.fulfilled
                        ? 'Request fulfilled by another donor. No further action needed.'
                        : 'Accepted. Waiting for hospital confirmation.',
                  )
                else if (!r.fulfilled)
                  FilledButton(
                    onPressed: () {
                      store.acceptDonation(r, store.donorAccount);
                      feedback(
                        context,
                        'Accepted. Switch to Hospital Staff to confirm the demo donation.',
                      );
                    },
                    child: const Text('Accept demo blood request'),
                  ),
              ],
            ],
          ),
      ],
    );
  }
}

class WellnessPage extends StatelessWidget {
  const WellnessPage({super.key, required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) => Section(
    'Small steps, better days',
    subtitle: 'General wellbeing content. Adapt activity to your comfort.',
    children: [
      Panel(
        title: 'Your session progress',
        subtitle:
            '${store.completedSessions.length} sessions completed in this demo',
        icon: Icons.insights,
      ),
      if (store.role == Role.contributor) ...[
        FilledButton.icon(
          onPressed: () => contentForm(context, store),
          icon: const Icon(Icons.add),
          label: const Text('Add wellness content'),
        ),
        gap(),
      ],
      for (var i = 0; i < store.content.length; i++)
        Panel(
          title: store.content[i].title,
          subtitle: store.content[i].description,
          icon: store.content[i].category == 'Home care'
              ? Icons.spa_outlined
              : Icons.self_improvement,
          children: [
            badge(
              '${store.content[i].category}${store.content[i].reviewed
                  ? ' • Demo reviewed sample'
                  : store.content[i].category == 'Home care'
                  ? ' • Pending review — contributor draft'
                  : ''}',
            ),
            if (store.content[i].category == 'Yoga') ...[
              gap(),
              OutlinedButton.icon(
                onPressed: () => showInfo(
                  context,
                  'Simulated playback',
                  '▶ ${store.content[i].title}\n\nThis is a mock video player. No video or audio is streamed. Preview a comfortable seated position and gentle movements.\n\nClose this preview, then mark your demo session complete.',
                ),
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Play demo video'),
              ),
            ],
            if (store.content[i].category != 'Home care') ...[
              gap(),
              FilledButton.tonal(
                onPressed: store.completedSessions.contains(i)
                    ? null
                    : () {
                        store.completedSessions.add(i);
                        store.changed();
                        feedback(
                          context,
                          'Session completed. Progress updated.',
                        );
                      },
                child: Text(
                  store.completedSessions.contains(i)
                      ? 'Session completed'
                      : 'Mark session complete',
                ),
              ),
            ],
          ],
        ),
    ],
  );
}

Future<void> contentForm(BuildContext context, DemoStore s) async {
  var title = '', description = '', category = 'Yoga';
  final form = GlobalKey<FormState>();
  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, update) => AlertDialog(
        title: const Text('Add mock content'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Form(
              key: form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  choice(
                    'Category',
                    category,
                    ['Yoga', 'Workout', 'Home care'],
                    (v) => v,
                    (v) => update(() => category = v),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Title'),
                    maxLength: 60,
                    onChanged: (v) => title = v.trim(),
                    validator: requiredText,
                  ),
                  gap(),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'General wellbeing guidance',
                    ),
                    maxLength: 300,
                    minLines: 2,
                    maxLines: 4,
                    onChanged: (v) => description = v.trim(),
                    validator: requiredText,
                  ),
                  const Text(
                    'Use general wellbeing guidance without cure claims or emergency-treatment advice. New home-care entries are drafts pending review.',
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!form.currentState!.validate()) {
                return;
              }
              s.content.add(WellnessContent(title, category, description));
              s.changed();
              Navigator.pop(ctx);
              feedback(context, 'Mock content added.');
            },
            child: const Text('Add content'),
          ),
        ],
      ),
    ),
  );
}

String? requiredText(String? v) =>
    (v ?? '').trim().isEmpty ? 'Please enter a value.' : null;

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) => Section(
    'Your community profile',
    subtitle: 'Health tools use fictional, session-only records.',
    children: [
      Panel(
        title: store.accountName,
        subtitle:
            '${store.role!.label}\nCare tools below use the shared fictional patient Meera Patil.',
        icon: Icons.person_outline,
        children: [
          choice('Sample village', store.village, villages, (v) => v, (v) {
            store.village = v;
            store.changed();
          }),
        ],
      ),
      if (store.role == Role.patient)
        Panel(
          title: '${store.points} demo points',
          subtitle:
              'Reward account: ${donors[store.donorAccount].name}. No real money or government endorsement.',
          icon: Icons.stars_outlined,
          children: [
            FilledButton.tonal(
              onPressed: store.points >= 100
                  ? () {
                      if (store.redeem()) {
                        showInfo(
                          context,
                          'Mock coupon redeemed',
                          'GRAM100\n\nThis demo wellness coupon has no monetary value and cannot be used with a real business.',
                        );
                      }
                    }
                  : null,
              child: const Text('Redeem mock coupon • 100 points'),
            ),
            gap(),
            if ((store.rewards[store.donorAccount] ?? []).isEmpty)
              const Text(
                'Complete a hospital-confirmed demo donation to earn 100 points.',
              ),
            for (final r in (store.rewards[store.donorAccount] ?? []).reversed)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${r.points > 0 ? '+' : ''}${r.points} • ${r.reason}',
                ),
              ),
          ],
        ),
      Panel(
        title: 'Menstrual tracker',
        icon: Icons.calendar_today_outlined,
        subtitle: store.lastPeriod == null
            ? 'Add a sample last-period date to estimate the next one.'
            : 'Last period: ${dateLabel(store.lastPeriod!)}\nCycle: ${store.cycleLength} days\nEstimated next period: ${dateLabel(store.lastPeriod!.add(Duration(days: store.cycleLength)))}',
        children: [
          const Text(
            'An estimate only; cycles vary. Not for diagnosis or contraception.',
          ),
          gap(),
          OutlinedButton(
            onPressed: () => cycleForm(context, store),
            child: const Text('Update cycle'),
          ),
        ],
      ),
      Panel(
        title: 'Medicine reminders',
        icon: Icons.medication_outlined,
        subtitle:
            'In-app only. No background alarms or notifications. Use medicines only as directed by your clinician.',
        children: [
          OutlinedButton.icon(
            onPressed: () => medicineForm(context, store),
            icon: const Icon(Icons.add),
            label: const Text('Add reminder'),
          ),
          for (final m in store.medicines)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(m.name),
              subtitle: Text(
                '${m.time.format(context)} • ${m.taken ? 'Taken' : 'Pending'}',
              ),
              value: m.taken,
              onChanged: (v) {
                m.taken = v ?? false;
                store.changed();
              },
            ),
          if (store.medicines.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'No reminders yet. Add a fictional medicine and time.',
              ),
            ),
        ],
      ),
      Panel(
        title: 'Organ donation awareness',
        icon: Icons.favorite_border,
        subtitle:
            'Organ donation can help people with organ failure. Discuss your wishes with your family and seek information from an authorised transplant centre. Eligibility and consent require professional assessment.',
        children: [
          const Text('This mock interest form is not official registration.'),
          gap(),
          OutlinedButton(
            onPressed: () => organForm(context, store),
            child: Text(
              store.organInterest
                  ? 'View mock interest'
                  : 'Record mock interest',
            ),
          ),
        ],
      ),
      StaffingPage(store: store),
    ],
  );
}

String dateLabel(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

Future<void> cycleForm(BuildContext context, DemoStore s) async {
  var date = s.lastPeriod;
  var length = s.cycleLength;
  final form = GlobalKey<FormState>();
  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, update) => AlertDialog(
        title: const Text('Sample cycle details'),
        content: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  final now = DateTime.now();
                  final selected = await showDatePicker(
                    context: ctx,
                    initialDate: date ?? now,
                    firstDate: DateTime(now.year - 2),
                    lastDate: now,
                  );
                  if (selected != null) {
                    update(() => date = selected);
                  }
                },
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  date == null ? 'Choose last-period date' : dateLabel(date!),
                ),
              ),
              gap(),
              TextFormField(
                initialValue: '$length',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cycle length in days',
                ),
                onChanged: (v) => length = int.tryParse(v) ?? 0,
                validator: (v) {
                  final n = int.tryParse(v ?? '') ?? 0;
                  return n < 21 || n > 45
                      ? 'Use 21–45 days for this demo.'
                      : null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!form.currentState!.validate()) {
                return;
              }
              if (date == null) {
                showInfo(
                  ctx,
                  'Choose a date',
                  'Select the last-period date first.',
                );
                return;
              }
              s.lastPeriod = date;
              s.cycleLength = length;
              s.changed();
              Navigator.pop(ctx);
              feedback(context, 'Cycle estimate updated.');
            },
            child: const Text('Save estimate'),
          ),
        ],
      ),
    ),
  );
}

Future<void> medicineForm(BuildContext context, DemoStore s) async {
  var name = '';
  var time = const TimeOfDay(hour: 9, minute: 0);
  final form = GlobalKey<FormState>();
  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, update) => AlertDialog(
        title: const Text('Add in-app reminder'),
        content: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Fictional medicine name',
                ),
                maxLength: 60,
                validator: requiredText,
                onChanged: (v) => name = v.trim(),
              ),
              gap(),
              OutlinedButton(
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: ctx,
                    initialTime: time,
                  );
                  if (picked != null) {
                    update(() => time = picked);
                  }
                },
                child: Text('Time: ${time.format(ctx)}'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!form.currentState!.validate()) {
                return;
              }
              s.medicines.add(Medicine(name, time));
              s.changed();
              Navigator.pop(ctx);
              feedback(context, 'In-app reminder added.');
            },
            child: const Text('Add reminder'),
          ),
        ],
      ),
    ),
  );
}

Future<void> organForm(BuildContext context, DemoStore s) async {
  if (s.organInterest) {
    await showInfo(
      context,
      'Mock interest recorded',
      'Meera Patil • interested in learning more.\nThis is not official registration. No information was sent anywhere.',
    );
    return;
  }
  var consent = false;
  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, update) => AlertDialog(
        title: const Text('Mock interest form'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Fictional person: Meera Patil\nRecord interest in learning more about organ donation.',
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: consent,
              onChanged: (v) => update(() => consent = v ?? false),
              title: const Text(
                'I understand this is not official registration.',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: consent
                ? () {
                    s.organInterest = true;
                    s.changed();
                    Navigator.pop(ctx);
                    feedback(context, 'Mock interest saved locally.');
                  }
                : null,
            child: const Text('Save mock interest'),
          ),
        ],
      ),
    ),
  );
}

class StaffingPage extends StatelessWidget {
  const StaffingPage({super.key, required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) => Section(
    'Community opportunities',
    subtitle: 'Fictional vacancies and mock applications.',
    children: [
      if (store.role == Role.hospital) ...[
        OutlinedButton.icon(
          onPressed: () => vacancyForm(context, store),
          icon: const Icon(Icons.add),
          label: const Text('Post vacancy'),
        ),
        gap(),
      ],
      for (final v in store.vacancies)
        Panel(
          title: v.title,
          subtitle: '${hospitals[v.hospital].name}\n${v.shift}',
          icon: Icons.work_outline,
          children: [
            if (store.role == Role.hospital)
              Text(
                v.applied
                    ? '1 mock application • Meera Patil'
                    : 'No mock applications yet.',
              )
            else
              FilledButton.tonal(
                onPressed: v.applied
                    ? null
                    : () async {
                        final apply = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Submit mock application?'),
                            content: Text(
                              'Apply as fictional candidate Meera Patil for ${v.title}. Nothing is sent to a real hospital.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Submit'),
                              ),
                            ],
                          ),
                        );
                        if (apply == true) {
                          v.applied = true;
                          store.changed();
                          if (context.mounted) {
                            feedback(context, 'Mock application submitted.');
                          }
                        }
                      },
                child: Text(
                  v.applied
                      ? 'Mock application submitted'
                      : 'Apply with sample profile',
                ),
              ),
          ],
        ),
    ],
  );
}

Future<void> vacancyForm(BuildContext context, DemoStore s) async {
  var title = '', shift = '';
  final form = GlobalKey<FormState>();
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Post a mock vacancy'),
      content: Form(
        key: form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Role title'),
              maxLength: 60,
              validator: requiredText,
              onChanged: (v) => title = v.trim(),
            ),
            gap(),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Shift / details'),
              maxLength: 120,
              validator: requiredText,
              onChanged: (v) => shift = v.trim(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!form.currentState!.validate()) {
              return;
            }
            s.vacancies.add(Vacancy(title, shift, s.hospitalAccount));
            s.changed();
            Navigator.pop(ctx);
            feedback(context, 'Mock vacancy posted.');
          },
          child: const Text('Post vacancy'),
        ),
      ],
    ),
  );
}
