import 'package:cloud_firestore/cloud_firestore.dart';

class CivilPerson {
  final String id;

  final String fullName;
  final String nationalId;

  final String? dob;
  final String? placeOfBirth;
  final String? location;
  final String? houseAddress;
  final String? paynum;
  final String? email;

  final List<String> identifiers;
  final String? primaryPhone;
  final String? motherName;
  final String? fatherName;

  final String? linkedUid;

  CivilPerson(
    this.email, {
    required this.id,
    required this.fullName,
    required this.nationalId,
    this.dob,
    this.placeOfBirth,
    this.location,
    this.houseAddress,
    this.paynum,
    this.identifiers = const [],
    this.primaryPhone,
    this.motherName,
    this.fatherName,
    this.linkedUid,
  });

  factory CivilPerson.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    final fullName = (data['fullName'] ?? data['full name'] ?? '')
        .toString()
        .trim();

    final nationalId = (data['nationalId'] ?? data['doc ID'] ?? doc.id)
        .toString();

    final dob = data['dob']?.toString();

    final placeOfBirth = data['placeOfBirth']?.toString();
    final location = data['location']?.toString();

    final houseAddress = (data['houseadress'] ?? data['houseaddress'])
        ?.toString();

    // ignore: unused_element
    String? readAny(Map<String, dynamic> data, List<String> keys) {
      for (final k in keys) {
        final v = data[k];
        if (v == null) continue;
        final s = v.toString().trim();
        if (s.isNotEmpty) return s;
      }
      return null;
    }

    final paynum = (data['paynum'] ?? data['payNum'] ?? data['pay_num'])
        ?.toString();

    final emailRaw = (data['email'] ?? '').toString().trim();
    final String? email = emailRaw.isEmpty ? null : emailRaw;

    final rawIdentifiers = data['identifiers'];
    List<String> identifiers = [];
    if (rawIdentifiers is List) {
      identifiers = rawIdentifiers.map((e) => e.toString()).toList();
    } else if (rawIdentifiers is Map) {
      identifiers = rawIdentifiers.values.map((e) => e.toString()).toList();
    }

    String? primaryPhone;
    if (identifiers.isNotEmpty) {
      primaryPhone = identifiers.first;
    } else if (data['phone'] != null) {
      primaryPhone = data['phone'].toString();
      identifiers = [primaryPhone];
    }

    return CivilPerson(
      email,
      id: doc.id,
      fullName: fullName,
      nationalId: nationalId,
      dob: dob,
      placeOfBirth: placeOfBirth,
      location: location,
      houseAddress: houseAddress,
      paynum: paynum,
      identifiers: identifiers,
      primaryPhone: primaryPhone,
      motherName: data['motherName']?.toString(),
      fatherName: data['fatherName']?.toString(),
      linkedUid: data['linkedUid']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'nationalId': nationalId,
      if (dob != null) 'dob': dob,
      if (placeOfBirth != null) 'placeOfBirth': placeOfBirth,
      if (location != null) 'location': location,
      if (houseAddress != null) 'houseadress': houseAddress,
      if (paynum != null) 'paynum': paynum,
      if (identifiers.isNotEmpty) 'identifiers': identifiers,
      if (primaryPhone != null) 'phone': primaryPhone,
      if (motherName != null) 'motherName': motherName,
      if (fatherName != null) 'fatherName': fatherName,
      if (linkedUid != null) 'linkedUid': linkedUid,
      if (email != null) 'email': email,
    };
  }
}
