import 'course_grade.dart';

class GPACalculation {
  final double currentGPA;

  final double newGPA;

  final List<CourseGrade> courses;

  final double totalCreditHours;

  final double totalGradePoints;

  const GPACalculation({
    required this.currentGPA,
    required this.newGPA,
    required this.courses,
    required this.totalCreditHours,
    required this.totalGradePoints,
  });

  factory GPACalculation.empty() {
    return const GPACalculation(
      currentGPA: 0.0,
      newGPA: 0.0,
      courses: [],
      totalCreditHours: 0.0,
      totalGradePoints: 0.0,
    );
  }
}
