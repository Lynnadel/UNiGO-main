import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/reservation_model.dart';
import '../services/registration_service.dart';

class ReserveTimeController extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  DateTime? selectedDate;
  String? selectedTime;

  List<String> timeSlots = [];

  List<Reservation> reserved = [];

  ReserveTimeController() {
    _generateTimeSlots();
    _loadExistingReservation();
  }

  void _generateTimeSlots() {
    final starts = RegistrationService.instance.generateFreeSlotStarts(
      startHour: 13,
      endHour: 18,
    );

    String two(int v) => v.toString().padLeft(2, '0');

    timeSlots = starts.map((start) {
      final startHour = start.hour;
      final startMin = start.minute;

      final startStr = '${two(startHour)}:${two(startMin)}';

      final endMinuteTotal = startMin + 15;
      final endHour = startHour + (endMinuteTotal ~/ 60);
      final endMin = endMinuteTotal % 60;
      final endStr = '${two(endHour)}:${two(endMin)}';

      return '$startStr - $endStr';
    }).toList();
  }

  Future<void> _loadExistingReservation() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snap = await _db
          .collection('registrationWindows')
          .doc(user.uid)
          .get();
      if (!snap.exists) {
        reserved = [];
        notifyListeners();
        return;
      }

      final data = snap.data() as Map<String, dynamic>;
      final startTs = data['startAt'];
      final endTs = data['endAt'];

      if (startTs is! Timestamp || endTs is! Timestamp) {
        reserved = [];
        notifyListeners();
        return;
      }

      final start = startTs.toDate();
      final end = endTs.toDate();

      String two(int v) => v.toString().padLeft(2, '0');

      final dateStr = '${start.year}/${two(start.month)}/${two(start.day)}';

      final timeStr =
          '${two(start.hour)}:${two(start.minute)} - '
          '${two(end.hour)}:${two(end.minute)}';

      reserved = [Reservation(registerDate: dateStr, registerTime: timeStr)];

      notifyListeners();
    } catch (_) {
      reserved = [];
      notifyListeners();
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final initial = selectedDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );

    if (picked != null) {
      selectedDate = picked;
      notifyListeners();
    }
  }

  void setTime(String? value) {
    selectedTime = value;
    notifyListeners();
  }
}
