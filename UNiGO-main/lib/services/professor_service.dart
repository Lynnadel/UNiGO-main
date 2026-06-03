import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/professor.dart';

class ProfessorService {
  static final _db = FirebaseFirestore.instance;

  static Future<List<Professor>> getAdvisors({
    required String facultyId,
    String? majorId,
  }) async {
    Query<Map<String, dynamic>> q = _db
        .collection('faculties')
        .doc(facultyId)
        .collection('professors')
        .where('canAdvise', isEqualTo: true);

    if (majorId != null && majorId.isNotEmpty) {
      q = q.where('majorIds', arrayContains: majorId);
    }

    final snap = await q.get();
    return snap.docs.map(Professor.fromDoc).toList();
  }
}
