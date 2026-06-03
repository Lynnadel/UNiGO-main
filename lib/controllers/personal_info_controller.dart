import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/personal_info_model.dart';

class PersonalInfoController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<PersonalInfo?> loadInfo() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    final data = doc.data() ?? <String, dynamic>{};

    return PersonalInfo(
      address: (data['houseaddress'] ?? '').toString(),
      email: (data['personalEmail'] ?? '').toString(),
      phone: (data['phone'] ?? '').toString(),
      altPhone: (data['altPhone'] ?? '').toString(),
    );
  }

  Future<void> updateInfo(PersonalInfo info) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('No logged-in user.');
    }

    await _db.collection('users').doc(uid).set({
      'houseaddress': info.address.trim(),
      'location': info.address.trim(),
      'personalEmail': info.email.trim(),
      'phone': info.phone.trim(),
      'altPhone': info.altPhone.trim(),
    }, SetOptions(merge: true));
  }
}
