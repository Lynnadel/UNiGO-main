import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/student_model.dart';

class ProfileController {
  Future<Student?> getStudent() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    final pay = _readAny(data, ['paynum', 'payNum', 'pay_num']);

    String dobString = '';
    final dobValue = data['dob'];
    if (dobValue != null) {
      if (dobValue is Timestamp) {
        final dt = dobValue.toDate();
        const monthNames = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        dobString = '${dt.day} ${monthNames[dt.month - 1]} ${dt.year}';
      } else {
        dobString = dobValue.toString();
      }
    }

    return Student(
      name: data['name'] ?? '',
      advisor: data['advisor'] ?? '',
      dob: dobString,
      email: data['email'] ?? '',
      gpa: (data['gpa'] is num) ? (data['gpa'] as num).toDouble() : 0.0,
      houseaddress: data['houseaddress'] ?? '',
      id: data['id']?.toString() ?? '',
      identifiers: (data['identifiers'] is Map<String, dynamic>)
          ? (data['identifiers'] as Map<String, dynamic>).map(
              (k, v) => MapEntry(k, v.toString()),
            )
          : {},
      location: data['location'] ?? '',
      major: data['major'] ?? '',
      paynum: pay,
      profileImage: (data['profileImage'] ?? '').toString(),
      university: data['university'] ?? '',
      department: data['department'] ?? '',
    );
  }

  String _contentTypeFromExt(String ext) {
    final e = ext.toLowerCase();
    if (e == 'jpg' || e == 'jpeg') return 'image/jpeg';
    if (e == 'png') return 'image/png';
    return 'application/octet-stream';
  }

  Future<String> uploadProfilePhoto({
    required Uint8List bytes,
    required String extension,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('No logged-in user.');

    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final oldSnap = await userRef.get();
    final oldPath = (oldSnap.data()?['profileImagePath'] ?? '').toString();

    final ts = DateTime.now().millisecondsSinceEpoch;
    final safeExt = extension.toLowerCase();
    final newPath = 'profile_photos/$uid/$ts.$safeExt';

    final ref = FirebaseStorage.instance.ref(newPath);

    await ref.putData(
      bytes,
      SettableMetadata(contentType: _contentTypeFromExt(safeExt)),
    );

    final url = await ref.getDownloadURL();

    await userRef.set({
      'profileImage': url,
      'profileImagePath': newPath,
      'profileImageUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (oldPath.isNotEmpty && oldPath != newPath) {
      try {
        await FirebaseStorage.instance.ref(oldPath).delete();
      } catch (_) {}
    }

    return url;
  }

  Future<void> removeProfilePhoto() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('No logged-in user.');

    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final snap = await userRef.get();

    final oldPath = (snap.data()?['profileImagePath'] ?? '').toString();

    if (oldPath.isNotEmpty) {
      try {
        await FirebaseStorage.instance.ref(oldPath).delete();
      } catch (_) {}
    }

    await userRef.set({
      'profileImage': '',
      'profileImagePath': '',
      'profileImageUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  String _readAny(Map<String, dynamic> data, List<String> keys) {
    for (final k in keys) {
      final v = data[k];
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
    return '';
  }
}
