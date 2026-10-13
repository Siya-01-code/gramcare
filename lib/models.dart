import 'package:flutter/material.dart';

enum Role { patient, volunteer, doctor, hospital, contributor }

extension RoleInfo on Role {
  String get label => const [
    'Patient / Donor',
    'Village Volunteer',
    'Doctor',
    'Hospital Staff',
    'Wellness Contributor',
  ][index];
  String get person => const [
    'Meera Patil',
    'Arjun Deshmukh',
    'Dr. Kavya Rao',
    'Nisha Kulkarni',
    'Rohan Joshi',
  ][index];
  IconData get icon => const [
    Icons.person_outline,
    Icons.volunteer_activism,
    Icons.medical_services_outlined,
    Icons.local_hospital_outlined,
    Icons.self_improvement,
  ][index];
}

const villages = ['Sonwadi', 'Devgaon', 'Kusumpur'];
const bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

class Hospital {
  final String name, city, verification;
  final List<String> specialties;
  const Hospital(this.name, this.city, this.verification, this.specialties);
}

const hospitals = [
  Hospital('Sahyadri Community Hospital', 'Sonwadi', 'DEMO-H001', [
    'General medicine',
    'Women’s health',
  ]),
  Hospital('Jeevan Rural Health Centre', 'Devgaon', 'DEMO-H002', [
    'General medicine',
    'Physiotherapy',
  ]),
  Hospital('Aarogya District Hospital', 'Kusumpur', 'DEMO-H003', [
    'Paediatrics',
    'Women’s health',
  ]),
];

class Doctor {
  final String name, specialty, verification;
  final int hospital;
  const Doctor(this.name, this.specialty, this.verification, this.hospital);
}

const doctors = [
  Doctor('Dr. Kavya Rao', 'General medicine', 'DEMO-D001', 0),
  Doctor('Dr. Neha More', 'Women’s health', 'DEMO-D002', 0),
  Doctor('Dr. Sameer Kale', 'General medicine', 'DEMO-D003', 1),
  Doctor('Dr. Isha Shah', 'Physiotherapy', 'DEMO-D004', 1),
  Doctor('Dr. Anaya Desai', 'Paediatrics', 'DEMO-D005', 2),
  Doctor('Dr. Nitin Pawar', 'Women’s health', 'DEMO-D006', 2),
];

class Appointment {
  final int id, doctor;
  final String slot, concern;
  int stage = 0;
  String summary = '';
  Appointment(this.id, this.doctor, this.slot, this.concern);
  String get status => const [
    'Awaiting doctor',
    'Accepted',
    'Consultation simulated',
    'Summary ready',
  ][stage];
}

class Assistance {
  final int id;
  final String issue, village;
  int stage = 0;
  int? hospital;
  Assistance(this.id, this.issue, this.village);
  String get status => const [
    'Submitted',
    'Volunteer accepted',
    'Hospital assigned',
    'Hospital acknowledged',
    'Assistance completed',
  ][stage];
}

class Donor {
  final String name, group, village;
  final List<int> distances;
  const Donor(this.name, this.group, this.village, this.distances);
}

const donors = [
  Donor('Meera Patil', 'O+', 'Sonwadi', [2, 5, 9]),
  Donor('Vikram Jadhav', 'A+', 'Devgaon', [6, 1, 8]),
  Donor('Sana Sheikh', 'B+', 'Kusumpur', [9, 7, 1]),
  Donor('Asha Shinde', 'O+', 'Sonwadi', [1, 6, 10]),
  Donor('Dev Bhosale', 'AB-', 'Devgaon', [7, 2, 6]),
];

class BloodRequest {
  final int id, hospital, units, radius;
  final String group;
  final Set<int> accepted = {}, confirmed = {};
  BloodRequest(this.id, this.hospital, this.group, this.units, this.radius);
  bool matches(int donor) =>
      donors[donor].group == group &&
      donors[donor].distances[hospital] <= radius;
  bool get fulfilled => confirmed.length >= units;
}

class WellnessContent {
  final String title, category, description;
  final bool reviewed;
  const WellnessContent(
    this.title,
    this.category,
    this.description, {
    this.reviewed = false,
  });
}

class Medicine {
  final String name;
  final TimeOfDay time;
  bool taken = false;
  Medicine(this.name, this.time);
}

class Vacancy {
  final String title, shift;
  final int hospital;
  bool applied = false;
  Vacancy(this.title, this.shift, this.hospital);
}

class RewardEntry {
  final String reason;
  final int points;
  const RewardEntry(this.reason, this.points);
}

class DemoStore extends ChangeNotifier {
  Role? role;
  int doctorAccount = 0, hospitalAccount = 0, donorAccount = 0;
  int _nextId = 1;
  final List<Appointment> appointments = [];
  final List<Assistance> assistance = [];
  final List<BloodRequest> blood = [];
  final List<Medicine> medicines = [];
  final List<WellnessContent> content = [];
  final List<Vacancy> vacancies = [];
  final Map<int, List<RewardEntry>> rewards = {};
  final Set<int> completedSessions = {};
  DateTime? lastPeriod;
  int cycleLength = 28;
  bool organInterest = false;
  String village = villages.first;

  DemoStore() {
    reset();
  }
  int get nextId => _nextId++;
  int get points =>
      (rewards[donorAccount] ?? []).fold(0, (sum, item) => sum + item.points);
  String get accountName => switch (role) {
    Role.patient => donors[donorAccount].name,
    Role.doctor => doctors[doctorAccount].name,
    Role.hospital => hospitals[hospitalAccount].name,
    _ => role?.person ?? 'Guest',
  };
  void changed() => notifyListeners();
  void switchRole(Role value) {
    role = value;
    changed();
  }

  bool book(int doctor, String slot, String concern) {
    if (appointments.any((a) => a.doctor == doctor && a.slot == slot)) {
      return false;
    }
    appointments.add(Appointment(nextId, doctor, slot, concern));
    changed();
    return true;
  }

  bool acceptDonation(BloodRequest request, int donor) {
    if (!request.matches(donor) ||
        request.fulfilled ||
        request.accepted.contains(donor)) {
      return false;
    }
    request.accepted.add(donor);
    changed();
    return true;
  }

  bool confirmDonation(BloodRequest request, int donor) {
    if (!request.accepted.contains(donor) ||
        request.confirmed.contains(donor) ||
        request.fulfilled) {
      return false;
    }
    request.confirmed.add(donor);
    rewards
        .putIfAbsent(donor, () => [])
        .add(RewardEntry('Demo donation • request #${request.id}', 100));
    changed();
    return true;
  }

  bool redeem() {
    if (points < 100) {
      return false;
    }
    rewards
        .putIfAbsent(donorAccount, () => [])
        .add(const RewardEntry('Mock wellness coupon • GRAM100', -100));
    changed();
    return true;
  }

  void reset() {
    role = null;
    doctorAccount = hospitalAccount = donorAccount = 0;
    _nextId = 1;
    appointments.clear();
    assistance.clear();
    blood.clear();
    medicines.clear();
    rewards.clear();
    completedSessions.clear();
    lastPeriod = null;
    cycleLength = 28;
    organInterest = false;
    village = villages.first;
    content
      ..clear()
      ..addAll(const [
        WellnessContent(
          'A gentle start',
          'Yoga',
          '8-minute seated mobility and relaxed breathing. Simulated video; move only within your comfort.',
        ),
        WellnessContent(
          'Your daily movement plan',
          'Workout',
          '10 minutes of comfortable walking, followed by gentle shoulder movements. Pause if you feel unwell.',
        ),
        WellnessContent(
          'Everyday hydration',
          'Home care',
          'Drink water regularly and keep drinking water clean. Follow any fluid limits advised by your clinician.',
          reviewed: true,
        ),
        WellnessContent(
          'A restful routine',
          'Home care',
          'Aim for a consistent sleep schedule and a calm, comfortable sleeping space.',
          reviewed: true,
        ),
      ]);
    vacancies
      ..clear()
      ..add(Vacancy('Staff nurse', 'Day shift • mock opening', 0));
    changed();
  }
}
