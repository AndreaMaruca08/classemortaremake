import 'grade.dart';

class Subject {
  String subjectCode;
  String subjectFullName;
  String lastGradeDate = "";
  String teacherName;
  List<Grade> grades;

  Subject({
    required this.subjectCode,
    required this.subjectFullName,
    required this.teacherName,
    required this.grades,
  });

  static List<double> ratio(List<Grade> gradesParam) {
    double positive = 0;
    double negative = 0;
    double mid = 0;
    for (Grade grade in gradesParam) {
      if (grade.isCanceled) {
        continue;
      }

      if (grade.value >= 6) {
        positive++;
      } else if (grade.value >= 5) {
        mid++;
      } else {
        negative++;
      }
    }

    if (gradesParam.isEmpty) return [0, 0, 0, 0, 0, 0];

    double percPositive = (positive / gradesParam.length) * 100;
    double percNegative = (negative / gradesParam.length) * 100;
    double percMid = (mid / gradesParam.length) * 100;

    return [positive, negative, mid, percPositive, percNegative, percMid];
  }
}
