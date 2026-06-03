import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/civil_person.dart';
import 'civil_registry_service.dart';
import 'admin_auth_helper.dart';

class ManagedUserSummary {
  final String uid;
  final String name;
  final String email;
  final String id;
  final String role;

  ManagedUserSummary({
    required this.uid,
    required this.name,
    required this.email,
    required this.id,
    required this.role,
  });
}

class CreatedUserFromCivilResult {
  final String uid;
  final String universityId;
  final String email;
  final String password;

  CreatedUserFromCivilResult({
    required this.uid,
    required this.universityId,
    required this.email,
    required this.password,
  });
}

class SuperAdminUserManagementService {
  SuperAdminUserManagementService._();

  static final SuperAdminUserManagementService instance =
      SuperAdminUserManagementService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<ManagedUserSummary>> loadUsersWithRoles({
    String? facultyId,
  }) async {
    Query<Map<String, dynamic>> usersQuery = _db.collection('users');

    if (facultyId != null && facultyId.trim().isNotEmpty) {
      usersQuery = usersQuery.where('facultyId', isEqualTo: facultyId.trim());
    }

    final usersSnap = await usersQuery.get();
    final rolesSnap = await _db.collection('roles').get();

    final roleMap = <String, String>{};
    for (final doc in rolesSnap.docs) {
      final data = doc.data();
      final r = (data['role'] ?? 'student').toString();
      roleMap[doc.id] = r;
    }

    final result = <ManagedUserSummary>[];

    for (final doc in usersSnap.docs) {
      final data = doc.data();
      final uid = doc.id;
      final name = (data['name'] ?? data['fullName'] ?? '').toString().trim();
      final email = (data['email'] ?? '').toString().trim();
      final id = (data['id'] ?? '').toString().trim();
      final role = roleMap[uid] ?? 'student';

      result.add(
        ManagedUserSummary(
          uid: uid,
          name: name,
          email: email,
          id: id,
          role: role,
        ),
      );
    }

    result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return result;
  }

  Future<void> setUserRole({required String uid, required String role}) async {
    await _db.collection('roles').doc(uid).set({
      'role': role,
    }, SetOptions(merge: true));
  }

  //OLD
  Future<String> createUserFirestoreOnly({
    required String fullName,
    required String email,
    required String universityId,
    required String major,
    required String department,
    required String role,
  }) async {
    final password = _generatePassword(fullName);

    final docRef = _db.collection('users').doc();
    final uid = docRef.id;

    await docRef.set({
      'name': fullName,
      'email': email,
      'id': universityId,
      'major': major,
      'faculty': department,
      'gpa': 0.0,
      'location': '',
      'houseaddress': '',
      'identifiers': {},
      'paynum': '',
      'university': '',
      'advisor': '',
      'dob': null,
      'enrolledCourses': [],
      'upcomingCourses': [],
      'previousCourses': {},
      'withdrawnCourses': [],
      'upcomingSections': {},
      'courseGrades': {},
      'year': '',
      'createdAt': FieldValue.serverTimestamp(),
      'markForAuthCreation': true,
      'initialPassword': password,
    });

    await _db.collection('roles').doc(uid).set({'role': role});

    return password;
  }

  //NEW
  Future<CreatedUserFromCivilResult> createUserFromCivilRegistry({
    required String nationalId,
    required String role,
    required String createdByUid,
    required String facultyId,
    required String facultyName,
    required String majorId,
    required String majorName,
    required String advisorId,
    required String advisorName,
  }) async {
    final CivilPerson? person = await CivilRegistryService.getByNationalId(
      nationalId,
    );

    if (person == null) {
      throw Exception('Civil registry record not found for this national ID.');
    }

    if (person.linkedUid != null && person.linkedUid!.isNotEmpty) {
      throw Exception(
        'This civil record is already linked to a UniGO account.',
      );
    }

    final String universityId = await _generateUniversityId();
    final String password = _generatePassword(person.fullName);
    final String email = _generateUniversityEmail(
      person.fullName,
      universityId,
    );

    final String uid = await AdminAuthHelper.createUser(
      email: email,
      password: password,
    );

    final usersRef = _db.collection('users').doc(uid);
    final rolesRef = _db.collection('roles').doc(uid);

    final civilSnap = await _db
        .collection('civilRegistry')
        .where('nationalId', isEqualTo: nationalId)
        .limit(1)
        .get();

    if (civilSnap.docs.isEmpty) {
      throw Exception(
        'Civil registry document not found for this national ID.',
      );
    }

    final civilRef = civilSnap.docs.first.reference;

    final advisorRef = _db
        .collection('faculties')
        .doc(facultyId)
        .collection('professors')
        .doc(advisorId);

    final batch = _db.batch();

    batch.set(usersRef, {
      'name': person.fullName,
      'email': email,
      'id': universityId,
      'nationalId': person.nationalId,
      'dob': person.dob,
      'location': person.location ?? person.placeOfBirth ?? '',
      'houseaddress': person.houseAddress ?? '',
      'paynum': person.paynum ?? '',
      'identifiers': person.identifiers,
      'phone': person.primaryPhone ?? '',
      'university': 'JU',
      'facultyId': facultyId,
      'faculty': facultyName,
      'majorId': majorId,
      'major': majorName,
      'advisorId': advisorId,
      'advisor': advisorName,
      'gpa': 0.0,
      'year': '',
      'enrolledCourses': [],
      'upcomingCourses': [],
      'previousCourses': {},
      'withdrawnCourses': [],
      'upcomingSections': {},
      'courseGrades': {},
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': createdByUid,
      'initialPassword': password,
    });

    batch.set(rolesRef, {'role': role}, SetOptions(merge: true));

    batch.update(civilRef, {
      'linkedUid': uid,
      'linkedAt': FieldValue.serverTimestamp(),
      'linkedBy': createdByUid,
    });

    batch.set(advisorRef, {
      'adviseesCount': FieldValue.increment(1),
    }, SetOptions(merge: true));

    await batch.commit();

    return CreatedUserFromCivilResult(
      uid: uid,
      universityId: universityId,
      email: email,
      password: password,
    );
  }

  Future<CreatedUserFromCivilResult> createAdminFromCivilRegistry({
    required String nationalId,
    required String createdByUid,
    required String facultyId,
    required String facultyName,
    required List<String> majorIds,
    required List<String> majorNames,
    bool isSuperAdmin = false,
  }) async {
    final CivilPerson? person = await CivilRegistryService.getByNationalId(
      nationalId,
    );

    if (person == null) {
      throw Exception('Civil registry record not found for this national ID.');
    }

    if (person.linkedUid != null && person.linkedUid!.isNotEmpty) {
      throw Exception(
        'This civil record is already linked to a UniGO account.',
      );
    }

    final String universityId = await _generateUniversityId();
    final String password = _generatePassword(person.fullName);
    final String email = _generateUniversityEmail(
      person.fullName,
      universityId,
    );

    final String uid = await AdminAuthHelper.createUser(
      email: email,
      password: password,
    );

    final usersRef = _db.collection('users').doc(uid);
    final rolesRef = _db.collection('roles').doc(uid);

    final civilSnap = await _db
        .collection('civilRegistry')
        .where('nationalId', isEqualTo: nationalId)
        .limit(1)
        .get();

    if (civilSnap.docs.isEmpty) {
      throw Exception(
        'Civil registry document not found for this national ID.',
      );
    }
    final civilRef = civilSnap.docs.first.reference;

    final profRef = _db
        .collection('faculties')
        .doc(facultyId)
        .collection('professors')
        .doc(uid);

    final batch = _db.batch();

    final String roleValue = isSuperAdmin ? 'superAdmin' : 'admin';

    batch.set(usersRef, {
      'name': person.fullName,
      'email': email,
      'id': universityId,
      'nationalId': person.nationalId,
      'dob': person.dob,
      'location': person.location ?? person.placeOfBirth ?? '',
      'houseaddress': person.houseAddress ?? '',
      'paynum': person.paynum,
      'identifiers': person.identifiers,
      'phone': person.primaryPhone ?? '',
      'university': 'JU',
      'facultyId': facultyId,
      'faculty': facultyName,
      'majorIds': majorIds,
      'majorNames': majorNames,
      'role': roleValue,
      'isProfessor': true,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': createdByUid,
      'initialPassword': password,
    });

    batch.set(rolesRef, {
      'role': roleValue,
      'facultyId': facultyId,
      'faculty': facultyName,
      'majorIds': majorIds,
    }, SetOptions(merge: true));

    batch.update(civilRef, {
      'linkedUid': uid,
      'linkedAt': FieldValue.serverTimestamp(),
      'linkedBy': createdByUid,
    });

    batch.set(profRef, {
      'fullName': person.fullName,
      'email': email,
      'facultyId': facultyId,
      'majorIds': majorIds,
      'canAdvise': false,
      'maxAdvisees': 0,
      'adviseesCount': 0,
      'assignedCourseCodes': <String>[],
      'linkedUid': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': createdByUid,
    }, SetOptions(merge: true));

    await batch.commit();

    return CreatedUserFromCivilResult(
      uid: uid,
      universityId: universityId,
      email: email,
      password: password,
    );
  }

  Future<void> deleteUserDataFirestore(String uid) async {
    await _db.collection('roles').doc(uid).delete();

    final eventsSnap = await _db
        .collection('calendarEvents')
        .where('ownerId', isEqualTo: uid)
        .get();
    for (final doc in eventsSnap.docs) {
      await doc.reference.delete();
    }

    await _db.collection('users').doc(uid).delete();

    await _db.collection('deletedUsers').doc(uid).set({
      'uid': uid,
      'requestedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> hardDeleteUser({required String uid}) async {
    final batch = _db.batch();

    final userRef = _db.collection('users').doc(uid);
    final roleRef = _db.collection('roles').doc(uid);
    final regWindowRef = _db.collection('registrationWindows').doc(uid);

    batch.delete(userRef);
    batch.delete(roleRef);
    batch.delete(regWindowRef);

    await batch.commit();
  }

  String _generatePassword(String fullName) {
    final trimmed = fullName.trim();
    final firstLetter = trimmed.isEmpty ? 'u' : trimmed[0].toLowerCase();
    const symbol = '@';
    final random = Random.secure();
    final number = random.nextInt(10000); // 0..9999
    final digits = number.toString().padLeft(4, '0');
    return '$firstLetter$symbol$digits';
  }

  Future<String> _generateUniversityId() async {
    final now = DateTime.now();
    final yy = (now.year % 100).toString().padLeft(2, '0');

    final counterRef = _db.collection('counters').doc('universityId_$yy');

    final int seq = await _db.runTransaction<int>((tx) async {
      final snap = await tx.get(counterRef);
      final data = snap.data();

      final current = (data?['next'] ?? 1) as int;

      tx.set(counterRef, {'next': current + 1}, SetOptions(merge: true));

      return current;
    });

    if (seq > 9999) {
      throw Exception('University ID sequence exceeded 9999 for year $yy.');
    }

    final digits = seq.toString().padLeft(4, '0');
    return '0$yy$digits';
  }

  String _generateUniversityEmail(String fullName, String universityId) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    final firstName = parts.isEmpty ? 'std' : parts.first;
    String prefix;
    if (firstName.length >= 3) {
      prefix = firstName.substring(0, 3).toLowerCase();
    } else {
      prefix = firstName.toLowerCase().padRight(3, 'x');
    }
    return '$prefix$universityId@ju.edu.jo';
  }
}
