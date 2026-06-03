import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarEvent {
  final String id;
  final String title;
  final DateTime date;
  final String type; 
  final String scope; 
  final String? courseCode;
  final String? ownerId;
  final String? facultyId; 
  CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    required this.scope,
    this.courseCode,
    this.ownerId,
    this.facultyId, 
  });

  factory CalendarEvent.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};

    final ts = data['date'];
    // ignore: unused_local_variable
    DateTime date = DateTime.now();
    if (ts is Timestamp) {
      date = ts.toDate();
    }

    return CalendarEvent(
      id: doc.id,
      title: (data['title'] ?? '').toString(),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: (data['type'] ?? 'Deadline').toString(),
      scope: (data['scope'] ?? 'global').toString(),
      courseCode: (data['courseCode'] ?? '').toString().isEmpty
          ? null
          : (data['courseCode']).toString(),
      ownerId: (data['ownerId'] ?? '').toString().isEmpty
          ? null
          : (data['ownerId']).toString(),
      facultyId: (data['facultyId'] ?? '').toString().isEmpty
          ? null
          : (data['facultyId']).toString(),
    );
  }
}
