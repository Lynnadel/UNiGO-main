import 'package:cloud_firestore/cloud_firestore.dart';

class SuperAdminCourseOverrideService {
  SuperAdminCourseOverrideService._();

  static final SuperAdminCourseOverrideService instance =
      SuperAdminCourseOverrideService._();

  final _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _db.collection('users').doc(uid);
  }

  Future<void> addUpcomingCourse({
    required String studentUid,
    required String courseCode,
    required String sectionId,
  }) async {
    final docRef = _userDoc(studentUid);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      final data = snap.data() ?? <String, dynamic>{};

      final enrolled = List<String>.from(data['enrolledCourses'] ?? const []);
      if (enrolled.contains(courseCode)) {
        throw Exception(
          'Student is already enrolled in $courseCode this semester.',
        );
      }

      final upcoming = Set<String>.from(
        List<String>.from(data['upcomingCourses'] ?? const []),
      );

      upcoming.add(courseCode);

      final upcomingSections = Map<String, dynamic>.from(
        data['upcomingSections'] ?? <String, dynamic>{},
      );
      upcomingSections[courseCode] = sectionId;

      tx.update(docRef, {
        'upcomingCourses': upcoming.toList(),
        'upcomingSections': upcomingSections,
      });
    });
  }

  Future<void> removeUpcomingCourse({
    required String studentUid,
    required String courseCode,
  }) async {
    final docRef = _userDoc(studentUid);

    await docRef.update({
      'upcomingCourses': FieldValue.arrayRemove([courseCode]),
      'upcomingSections.$courseCode': FieldValue.delete(),
    });
  }

  Future<void> withdrawCurrentCourse({
    required String studentUid,
    required String courseCode,
  }) async {
    final docRef = _userDoc(studentUid);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      final data = snap.data() ?? <String, dynamic>{};

      final enrolled = List<String>.from(data['enrolledCourses'] ?? const []);
      if (!enrolled.contains(courseCode)) {
        throw Exception('Student is not currently enrolled in $courseCode.');
      }

      final withdrawn = Set<String>.from(
        List<String>.from(data['withdrawnCourses'] ?? const []),
      );

      enrolled.remove(courseCode);
      withdrawn.add(courseCode);

      tx.update(docRef, {
        'enrolledCourses': enrolled,
        'withdrawnCourses': withdrawn.toList(),
      });
    });
  }
}
