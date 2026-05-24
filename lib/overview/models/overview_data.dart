import '../../absences/attendance.dart';
import '../../achievement/achievement.dart';
import '../../agenda/info.dart';
import '../../grades/grade.dart';
import '../../lessons/lesson_hour.dart';
import '../../notes/note.dart';

class OverviewData {
  final List<Achievement> achievements;
  final List<Grade> grades;
  final List<Attendance> absences;
  final List<Attendance> delays;
  final List<Attendance> shortDelays;
  final List<Attendance> exits;
  final List<Note> disciplinaryNotes;
  final List<Note> annotations;
  final List<Note> classNotes;
  final List<Note> noteNotices;
  final List<LessonHour> lessons;
  final List<Info> homeworks;
  final List<Info> agendaItems;
  final List<Info> tests;
  final List<Info> otherAgenda;
  final List<Info> forTomorrow;

  OverviewData({
    required this.achievements,
    required this.grades,
    required this.absences,
    required this.delays,
    required this.shortDelays,
    required this.exits,
    required this.disciplinaryNotes,
    required this.annotations,
    required this.classNotes,
    required this.noteNotices,
    required this.lessons,
    required this.homeworks,
    required this.agendaItems,
    required this.tests,
    required this.otherAgenda,
    required this.forTomorrow,
  });

  factory OverviewData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> eventsJson = json['events'] ?? [];
    final List<dynamic> gradesJson = json['grades'] ?? [];
    final Map<String, dynamic> notesJson = json['notes'] ?? {};
    final List<Map<String, dynamic>> agendaJson =
        (json['agenda'] as List<dynamic>?)?.map((e) => e as Map<String, dynamic>).toList() ??
            [];

    final List<List<Note>> parsedNotes = Note.getNotes(notesJson);
    final List<Note> disciplinary = parsedNotes[0];
    final List<Note> annotations = parsedNotes[1];
    final List<Note> classNotes = parsedNotes[2];
    final List<Note> notices = parsedNotes[3];

    final List<Attendance> absences = Attendance.forAchievement(eventsJson, "ABA0");
    final List<Attendance> delays = Attendance.forAchievement(eventsJson, "ABR0");
    final List<Attendance> shortDelays = Attendance.forAchievement(eventsJson, "ABR1");
    final List<Attendance> exits = Attendance.forAchievement(eventsJson, "ABU0");

    final List<Grade> grades = Grade.forAchievement(gradesJson);

    final List<Achievement> achievements = Achievement.getAchievements(
      disciplinary,
      annotations,
      grades,
      absences,
      delays,
      shortDelays,
      exits,
    );

    final List<LessonHour> lessons = LessonHour.fromJsonList(json);

    return OverviewData(
      achievements: achievements,
      grades: grades,
      absences: absences,
      delays: delays,
      shortDelays: shortDelays,
      exits: exits,
      disciplinaryNotes: disciplinary,
      annotations: annotations,
      classNotes: classNotes,
      noteNotices: notices,
      lessons: lessons,
      homeworks: Info.fromJsonListHomeworks(agendaJson),
      agendaItems: Info.fromJsonListAgenda(agendaJson),
      tests: Info.fromJsonListTests(agendaJson),
      otherAgenda: Info.fromJsonOther(agendaJson),
      forTomorrow: Info.fromJsonForTomorrow(agendaJson),
    );
  }

  Map<String, double> get averages {
    final validGrades = grades.where((g) =>
        !g.isCanceled &&
        g.value > 0 &&
        g.subjectCode.toUpperCase() != "REL" &&
        g.subjectFullName.toUpperCase() != "RELIGIONE");

    if (validGrades.isEmpty) return {"total": 0, "p1": 0, "p2": 0};

    double sumTotal = 0;
    int countTotal = 0;
    double sumP1 = 0;
    int countP1 = 0;
    double sumP2 = 0;
    int countP2 = 0;

    for (var g in validGrades) {
      sumTotal += g.value;
      countTotal++;
      if (g.period == 1) {
        sumP1 += g.value;
        countP1++;
      } else if (g.period == 2) {
        sumP2 += g.value;
        countP2++;
      }
    }

    return {
      "total": countTotal > 0 ? sumTotal / countTotal : 0,
      "p1": countP1 > 0 ? sumP1 / countP1 : 0,
      "p2": countP2 > 0 ? sumP2 / countP2 : 0,
    };
  }
}
