class CourseGrade {
  final String grade;

  final double creditHours;

  final double gradePoint;

  CourseGrade({
    required this.grade,
    required this.creditHours,
    required this.gradePoint,
  });

  double get totalPoints => gradePoint * creditHours;

  factory CourseGrade.fromInput(
    String grade,
    double creditHours,
    double gradePoint,
  ) {
    return CourseGrade(
      grade: grade,
      creditHours: creditHours,
      gradePoint: gradePoint,
    );
  }
}
