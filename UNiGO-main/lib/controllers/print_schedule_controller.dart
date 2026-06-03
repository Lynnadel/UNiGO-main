import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/schedule_course.dart';

class PrintScheduleController extends ChangeNotifier {
  PrintScheduleController({this.studentUidOverride});

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final String? studentUidOverride;

  bool loading = false;
  String? errorMessage;

  List<String> semesters = [];

  String? selectedSemester;

  List<ScheduleCourse> semesterCourses = [];

  final List<_PrevCourseEntry> _allPrevCourses = [];

  String studentName = '';
  String studentId = '';
  String major = '';
  String faculty = '';

  bool get isAdminView => studentUidOverride != null;

  String? get _effectiveUid => studentUidOverride ?? _auth.currentUser?.uid;

  String get academicYear {
    final sem = selectedSemester;
    if (sem == null) return '';
    final parts = sem.split(' ');
    if (parts.length != 2) return '';
    final season = parts[0];
    final y = int.tryParse(parts[1]);
    if (y == null) return '';
    if (season == 'Fall') {
      return '$y/${y + 1}';
    } else {
      return '${y - 1}/$y';
    }
  }

  Future<void> loadInitial() async {
    loading = true;
    errorMessage = null;
    semesters = [];
    semesterCourses = [];
    _allPrevCourses.clear();
    notifyListeners();

    try {
      final uid = _effectiveUid;
      if (uid == null || uid.isEmpty) {
        throw Exception('No user selected.');
      }

      final userSnap = await _db.collection('users').doc(uid).get();
      final data = userSnap.data();
      if (data == null) {
        throw Exception('User document not found');
      }

      studentName =
          (data['fullName'] ?? data['name'] ?? data['studentName'] ?? '')
              .toString();

      studentId =
          (data['studentId'] ??
                  data['universityId'] ??
                  data['uniId'] ??
                  data['id'] ??
                  '')
              .toString();

      major =
          (data['major'] ?? data['specialization'] ?? data['department'] ?? '')
              .toString();

      faculty = (data['faculty'] ?? data['college'] ?? data['school'] ?? '')
          .toString();

      final prevRaw = data['previousCourses'];
      if (prevRaw is Map) {
        prevRaw.forEach((key, value) {
          if (value is Map) {
            final m = Map<String, dynamic>.from(value);
            final code = key.toString();
            final grade = (m['grade'] ?? '').toString();
            final semester = (m['semester'] ?? '').toString();
            final sectionId = (m['sectionId'] ?? '').toString();

            if (semester.isEmpty) return;

            _allPrevCourses.add(
              _PrevCourseEntry(
                code: code,
                semester: semester,
                grade: grade,
                sectionId: sectionId,
              ),
            );
          }
        });
      }

      final semSet = <String>{};
      for (final p in _allPrevCourses) {
        semSet.add(p.semester);
      }
      semesters = semSet.toList()..sort(_semesterSort);

      if (semesters.isNotEmpty) {
        selectedSemester ??= semesters.first;
        await _loadSemesterCourses(selectedSemester!);
      } else {
        semesterCourses = [];
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> changeSemester(String sem) async {
    if (sem == selectedSemester) return;
    selectedSemester = sem;
    loading = true;
    errorMessage = null;
    semesterCourses = [];
    notifyListeners();

    try {
      await _loadSemesterCourses(sem);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> _loadSemesterCourses(String sem) async {
    final entries = _allPrevCourses.where((p) => p.semester == sem).toList();
    if (entries.isEmpty) {
      semesterCourses = [];
      return;
    }

    final futures = <Future<DocumentSnapshot>>[];
    for (final e in entries) {
      futures.add(_db.collection('courses').doc(e.code).get());
    }
    final snaps = await Future.wait(futures);

    final List<ScheduleCourse> result = [];

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final snap = snaps[i];

      String name = entry.code;
      int credits = 0;
      List<dynamic> rawSections = const [];

      if (snap.exists) {
        final cdata = snap.data() as Map<String, dynamic>;
        name = (cdata['name'] ?? name).toString();

        final creditsRaw = cdata['credits'];
        if (creditsRaw is int) {
          credits = creditsRaw;
        } else if (creditsRaw != null) {
          credits = int.tryParse(creditsRaw.toString()) ?? 0;
        }

        rawSections = (cdata['sections'] ?? []) as List<dynamic>;
      }

      String daysText = '';
      String timeText = '';
      String location = '';
      String doctorName = '';

      if (rawSections.isNotEmpty && entry.sectionId.isNotEmpty) {
        for (final rs in rawSections) {
          if (rs is Map) {
            final m = Map<String, dynamic>.from(rs);
            if (m['id']?.toString() == entry.sectionId) {
              final days =
                  (m['days'] as List?)?.map((e) => e.toString()).toList() ?? [];
              final startTime = (m['startTime'] ?? '').toString();
              final endTime = (m['endTime'] ?? '').toString();
              doctorName = (m['doctorName'] ?? '').toString();
              location = (m['location'] ?? '').toString();

              if (days.isNotEmpty) {
                daysText = days.join(', ');
              }
              if (startTime.isNotEmpty && endTime.isNotEmpty) {
                timeText = '$startTime–$endTime';
              } else if (startTime.isNotEmpty) {
                timeText = startTime;
              }
              break;
            }
          }
        }
      }

      if (location.isEmpty) location = '-';

      result.add(
        ScheduleCourse(
          code: entry.code,
          name: name,
          credits: credits,
          sectionId: entry.sectionId,
          daysText: daysText,
          timeText: timeText,
          location: location,
          doctorName: doctorName,
          grade: entry.grade,
        ),
      );
    }

    semesterCourses = result;
  }

  int _semesterSort(String a, String b) {
    int seasonRank(String s) {
      if (s.startsWith('Fall')) return 0;
      if (s.startsWith('Spring')) return 1;
      if (s.startsWith('Summer')) return 2;
      return 3;
    }

    String season(String s) => s.split(' ').first;
    int year(String s) => int.tryParse(s.split(' ').last) ?? 0;

    final ya = year(a);
    final yb = year(b);
    if (ya != yb) return ya.compareTo(yb);
    return seasonRank(season(a)).compareTo(seasonRank(season(b)));
  }

  Future<Uint8List> buildPdfBytes() async {
    if (selectedSemester == null) {
      throw Exception('No semester selected');
    }

    final pdf = pw.Document();

    final List<ScheduleCourse> rows = List.of(semesterCourses);
    final sem = selectedSemester!;
    final yearText = academicYear;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'The University of Jordan',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Admission & Registration Unit',
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Student Schedule',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Date: ${_formatDate(DateTime.now())}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Academic Year: $yearText',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        'Semester: $sem',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 12),

              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Student Name: ${studentName.isEmpty ? '-' : studentName}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        pw.Text(
                          'Student ID: ${studentId.isEmpty ? '-' : studentId}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Faculty: ${faculty.isEmpty ? '-' : faculty}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        pw.Text(
                          'Major: ${major.isEmpty ? '-' : major}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 10),

              // ---------- Table ----------
              pw.Expanded(
                // ignore: deprecated_member_use
                child: pw.Table.fromTextArray(
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFE0E0E0),
                  ),
                  headerStyle: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  cellAlignment: pw.Alignment.centerLeft,
                  columnWidths: {
                    0: const pw.FlexColumnWidth(1.2), // Code
                    1: const pw.FlexColumnWidth(2.6), // Course Name
                    2: const pw.FlexColumnWidth(0.7), // Cr
                    3: const pw.FlexColumnWidth(0.7), // Sec
                    4: const pw.FlexColumnWidth(1.6), // Days
                    5: const pw.FlexColumnWidth(1.6), // Time
                    6: const pw.FlexColumnWidth(1.6), // Location
                    7: const pw.FlexColumnWidth(1.9), // Doctor
                    8: const pw.FlexColumnWidth(0.8), // Grade
                  },
                  headers: const [
                    'Code',
                    'Course Name',
                    'Cr',
                    'Sec',
                    'Days',
                    'Time',
                    'Location',
                    'Doctor',
                    'Grade',
                  ],
                  data: rows
                      .map(
                        (c) => [
                          c.code,
                          c.name,
                          c.credits.toString(),
                          c.sectionId,
                          c.daysText,
                          c.timeText,
                          c.location,
                          c.doctorName,
                          c.grade,
                        ],
                      )
                      .toList(),
                ),
              ),

              pw.SizedBox(height: 6),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Generated by UniGO',
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    return '$d/$m/$y';
  }
}

class _PrevCourseEntry {
  final String code;
  final String semester;
  final String grade;
  final String sectionId;

  _PrevCourseEntry({
    required this.code,
    required this.semester,
    required this.grade,
    required this.sectionId,
  });
}
