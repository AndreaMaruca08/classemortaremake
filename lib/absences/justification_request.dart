import '../core/enums/operation.dart';

class JustificationRequest {
  Operation operation;
  int justificationType;
  String reason;
  String absenceStartDate;
  String absenceEndDate;
  String absenceMotivation;
  String entryExitDay;
  String entryExitHour;
  String entryExitMotivation;
  String companion;

  JustificationRequest({
    required this.operation,
    required this.justificationType,
    required this.reason,
    required this.absenceStartDate,
    required this.absenceEndDate,
    required this.absenceMotivation,
    required this.entryExitDay,
    required this.entryExitHour,
    required this.entryExitMotivation,
    required this.companion,
  });
}
