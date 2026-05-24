import 'package:flutter/material.dart';

import '../absences/attendance.dart';
import '../notes/note.dart';
import '../grades/grade.dart';
import 'enums/achievement_type.dart';
import 'enums/achievement_rarity.dart';

class Achievement {
  double valueToReach;
  int count;
  bool reached;
  Icon display;
  String title;
  String description;
  String subject;
  bool isPositive;
  AchievementType type;
  AchievementRarity rarity;

  Achievement({
    required this.valueToReach,
    required this.count,
    required this.reached,
    required this.display,
    required this.title,
    required this.description,
    required this.subject,
    required this.isPositive,
    required this.type,
    required this.rarity
  });

  static List<Achievement> getAchievements(
    List<Note> disciplinary,
    List<Note> annotations,
    List<Grade> grades,
    List<Attendance> absences,
    List<Attendance> delays,
    List<Attendance> shortDelays,
    List<Attendance> exits
  ) {
    List<Achievement> achievements = [];
    List<Attendance> allDelays = [...delays, ...shortDelays];

    for (Achievement a in allAchievements()) {
      a.reached = isReached(a, disciplinary, annotations, grades, absences, allDelays, exits);
      achievements.add(a);
    }

    return achievements;
  }

  static bool isReached(
    Achievement trophy,
    List<Note> disciplinary,
    List<Note> annotations,
    List<Grade> grades,
    List<Attendance> absences,
    List<Attendance> delays,
    List<Attendance> exits
  ) {
    switch (trophy.type) {
      case AchievementType.GRADES:
        return checkGrades(trophy, grades);
      case AchievementType.GRADES_NUMBER:
        return checkGradesNumbered(trophy, grades);
      case AchievementType.ABSENCE:
        return checkEvent(trophy, absences);
      case AchievementType.DELAY:
        return checkEvent(trophy, delays);
      case AchievementType.EXITS:
        return checkEvent(trophy, exits);
      case AchievementType.DISCIPLINARY_NOTE:
        return checkNotes(trophy, disciplinary);
      case AchievementType.ANNOTATION:
        return checkNotes(trophy, annotations);
      case AchievementType.CONSECUTIVE_GRADES:
        return checkConsecutiveGrades(trophy, grades);
    }
  }

  static bool checkGrades(Achievement trophy, List<Grade> grades) {
    for (Grade grade in grades) {
      if (trophy.subject == "null") {
        if (grade.value >= trophy.valueToReach && trophy.isPositive) {
          return true;
        } else if (grade.value < trophy.valueToReach && !trophy.isPositive) {
          return true;
        }
      } else if (trophy.subject.contains(grade.subjectCode)) {
        if (grade.value >= trophy.valueToReach && trophy.isPositive) {
          return true;
        } else if (grade.value < trophy.valueToReach && !trophy.isPositive) {
          return true;
        }
      }
    }
    return false;
  }

  static bool checkGradesNumbered(Achievement trophy, List<Grade> grades) {
    int count = 0;
    for (Grade grade in grades) {
      if (trophy.subject == "null") {
        if (grade.value >= trophy.valueToReach && trophy.isPositive) {
          count++;
        } else if (grade.value < trophy.valueToReach && !trophy.isPositive) {
          count++;
        }
      } else if (trophy.subject.contains(grade.subjectCode)) {
        if (grade.value >= trophy.valueToReach && trophy.isPositive) {
          count++;
        } else if (grade.value < trophy.valueToReach && !trophy.isPositive) {
          count++;
        }
      }
    }
    return count >= trophy.count;
  }

  static bool checkConsecutiveGrades(Achievement trophy, List<Grade> grades) {
    int count = 0;
    List<Grade> gradesToCheck;

    if (trophy.subject == "null") {
      gradesToCheck = grades;
    } else {
      gradesToCheck = grades.where((grade) => trophy.subject.contains(grade.subjectCode)).toList();
    }

    for (Grade grade in gradesToCheck) {
      if (grade.displayValue == "n.c. " || grade.isCanceled || grade.value == 0) {
        continue;
      }

      bool conditionMet = trophy.isPositive 
          ? (grade.value >= trophy.valueToReach)
          : (grade.value < trophy.valueToReach);

      if (conditionMet) {
        count++;
      } else {
        count = 0;
      }
      if (count == trophy.count) {
        return true;
      }
    }
    return false;
  }

  static bool checkEvent(Achievement trophy, List<Attendance> events) {
    if (trophy.isPositive) {
      return trophy.count >= events.length;
    } else {
      return trophy.count <= events.length;
    }
  }

  static bool checkNotes(Achievement trophy, List<Note> notes) {
    if (trophy.isPositive) {
      return trophy.count >= notes.length;
    } else {
      if (trophy.subject == "telefono") {
        return notes.any((n) => n.message.toLowerCase().contains("telefono") || n.message.toLowerCase().contains("cellulare"));
      } else {
        return trophy.count <= notes.length;
      }
    }
  }

  static List<Achievement> allAchievements() {
    List<Achievement> achievements = [];
    double sizeIcon = 60;

    achievements.add(Achievement(
        valueToReach: 10,
        count: 1,
        reached: false,
        display: Icon(Icons.workspace_premium_outlined, color: getColorByRarity(AchievementRarity.SILVER), size: sizeIcon),
        title: "Numero Uno",
        description: "Ottieni il tuo primo 10 dell'anno",
        subject: "null",
        isPositive: true,
        type: AchievementType.GRADES,
        rarity: AchievementRarity.SILVER));

    achievements.add(Achievement(
        valueToReach: 6,
        count: 5,
        reached: false,
        display: Icon(Icons.workspace_premium_outlined, color: getColorByRarity(AchievementRarity.SILVER), size: sizeIcon),
        title: "Streak promettente",
        description: "Ottieni una streak di 5 almeno una volta",
        subject: "null",
        isPositive: true,
        type: AchievementType.CONSECUTIVE_GRADES,
        rarity: AchievementRarity.SILVER));

    achievements.add(Achievement(
        valueToReach: 6,
        count: 10,
        reached: false,
        display: Icon(Icons.workspace_premium_outlined, color: getColorByRarity(AchievementRarity.PLATINUM), size: sizeIcon),
        title: "Streak miracolosa",
        description: "Ottieni una streak di 10 almeno una volta",
        subject: "null",
        isPositive: true,
        type: AchievementType.CONSECUTIVE_GRADES,
        rarity: AchievementRarity.PLATINUM));

    achievements.add(Achievement(
        valueToReach: 6,
        count: 15,
        reached: false,
        display: Icon(Icons.workspace_premium_outlined, color: getColorByRarity(AchievementRarity.LEGENDARY), size: sizeIcon),
        title: "GOAT",
        description: "Ottieni una streak di 15 almeno una volta",
        subject: "null",
        isPositive: true,
        type: AchievementType.CONSECUTIVE_GRADES,
        rarity: AchievementRarity.LEGENDARY));

    achievements.add(Achievement(
        valueToReach: 6,
        count: 3,
        reached: false,
        display: Icon(Icons.workspace_premium_outlined, color: getColorByRarity(AchievementRarity.SILVER), size: sizeIcon),
        title: "GIT GUD",
        description: "Ottieni una streak negativa di 3 almeno una volta",
        subject: "null",
        isPositive: false,
        type: AchievementType.CONSECUTIVE_GRADES,
        rarity: AchievementRarity.SILVER));

    achievements.add(Achievement(
        valueToReach: 6,
        count: 5,
        reached: false,
        display: Icon(Icons.workspace_premium_outlined, color: getColorByRarity(AchievementRarity.LEGENDARY), size: sizeIcon),
        title: "Disastro",
        description: "Ottieni una streak negativa di 5 almeno una volta",
        subject: "null",
        isPositive: false,
        type: AchievementType.CONSECUTIVE_GRADES,
        rarity: AchievementRarity.LEGENDARY));

    achievements.add(Achievement(
        valueToReach: 5,
        count: 4,
        reached: false,
        display: Icon(Icons.workspace_premium_outlined, color: getColorByRarity(AchievementRarity.PLATINUM), size: sizeIcon),
        title: "I Fantastici 4",
        description: "Ottieni in tutto l'anno almeno 4 volte 4",
        subject: "null",
        isPositive: false,
        type: AchievementType.GRADES_NUMBER,
        rarity: AchievementRarity.PLATINUM));

    achievements.add(Achievement(
        valueToReach: 7,
        count: 7,
        reached: false,
        display: Icon(Icons.workspace_premium_outlined, color: getColorByRarity(AchievementRarity.PLATINUM), size: sizeIcon),
        title: "I Fantastici 7",
        description: "Ottieni in tutto l'anno almeno 7 volte 7",
        subject: "null",
        isPositive: true,
        type: AchievementType.GRADES_NUMBER,
        rarity: AchievementRarity.PLATINUM));

    achievements.add(Achievement(
        valueToReach: 7,
        count: 3,
        reached: false,
        display: Icon(Icons.shield_outlined, color: getColorByRarity(AchievementRarity.SILVER), size: sizeIcon),
        title: "Sopra la media",
        description: "Ottieni 3 voti superiori o uguali a 7 consecutivamente",
        subject: "null",
        isPositive: true,
        type: AchievementType.CONSECUTIVE_GRADES,
        rarity: AchievementRarity.SILVER));

    achievements.add(Achievement(
        valueToReach: 10,
        count: 1,
        reached: false,
        display: Icon(Icons.grass, color: getColorByRarity(AchievementRarity.SILVER), size: sizeIcon),
        title: "Programmatore",
        description: "Ottieni 10 di informatica",
        subject: "INF STI",
        isPositive: true,
        type: AchievementType.GRADES,
        rarity: AchievementRarity.SILVER));

    achievements.add(Achievement(
        valueToReach: 8,
        count: 3,
        reached: false,
        display: Icon(Icons.grass, color: getColorByRarity(AchievementRarity.GOLD), size: sizeIcon),
        title: "Esci di casa",
        description: "Ottieni 3 volte di fila 8 o più di informatica",
        subject: "INF STI",
        isPositive: true,
        type: AchievementType.CONSECUTIVE_GRADES,
        rarity: AchievementRarity.GOLD));

    achievements.add(Achievement(
        valueToReach: 10,
        count: 1,
        reached: false,
        display: Icon(Icons.book, color: getColorByRarity(AchievementRarity.SILVER), size: sizeIcon),
        title: "Dante Alighieri",
        description: "Ottieni 10 di italiano",
        subject: "ITA",
        isPositive: true,
        type: AchievementType.GRADES,
        rarity: AchievementRarity.SILVER));

    achievements.add(Achievement(
        valueToReach: 10,
        count: 1,
        reached: false,
        display: Icon(Icons.emoji_events, color: getColorByRarity(AchievementRarity.BRONZE), size: sizeIcon),
        title: "Usain Bolt",
        description: "Ottieni 10 di motoria",
        subject: "MOT",
        isPositive: true,
        type: AchievementType.GRADES,
        rarity: AchievementRarity.BRONZE));

    achievements.add(Achievement(
        valueToReach: 6,
        count: 1,
        reached: false,
        display: Icon(Icons.emoji_events, color: getColorByRarity(AchievementRarity.PLATINUM), size: sizeIcon),
        title: "Alzati dal divano",
        description: "Ottieni un voto sotto il 6 di motoria",
        subject: "MOT",
        isPositive: false,
        type: AchievementType.GRADES,
        rarity: AchievementRarity.PLATINUM));

    achievements.add(Achievement(
        valueToReach: 10,
        count: 1,
        reached: false,
        display: Icon(Icons.calculate, color:getColorByRarity(AchievementRarity.SILVER), size: sizeIcon),
        title: "Pitagora chi?",
        description: "Ottieni 10 di matematica",
        subject: "MAT",
        isPositive: true,
        type: AchievementType.GRADES,
        rarity: AchievementRarity.SILVER));

    achievements.add(Achievement(
        valueToReach: 8,
        count: 4,
        reached: false,
        display: Icon(Icons.calculate, color: getColorByRarity(AchievementRarity.PLATINUM), size: sizeIcon),
        title: "MateGoat",
        description: "Ottieni 4 volte di fila 7 o più di matematica",
        subject: "MAT",
        isPositive: true,
        type: AchievementType.CONSECUTIVE_GRADES,
        rarity: AchievementRarity.PLATINUM));

    achievements.add(Achievement(
        valueToReach: 10,
        count: 1,
        reached: false,
        display: Icon(Icons.language, color: getColorByRarity(AchievementRarity.SILVER), size: sizeIcon),
        title: "Nativo inglese",
        description: "Ottieni 10 di inglese",
        subject: "ING",
        isPositive: true,
        type: AchievementType.GRADES,
        rarity: AchievementRarity.SILVER));

    achievements.add(Achievement(
        valueToReach: 8,
        count: 1,
        reached: false,
        display: Icon(Icons.language, color: getColorByRarity(AchievementRarity.BRONZE), size: sizeIcon),
        title: "Pretty good",
        description: "Ottieni 8 di inglese",
        subject: "ING",
        isPositive: true,
        type: AchievementType.GRADES,
        rarity: AchievementRarity.BRONZE));

    achievements.add(Achievement(
        valueToReach: 7.5,
        count: 3,
        reached: false,
        display: Icon(Icons.language, color: getColorByRarity(AchievementRarity.GOLD), size: sizeIcon),
        title: "Pretty GOD",
        description: "Ottieni 3 volte di fila 7,5 o più di inglese",
        subject: "ING",
        isPositive: true,
        type: AchievementType.CONSECUTIVE_GRADES,
        rarity: AchievementRarity.GOLD));

    achievements.add(Achievement(
        valueToReach: 8,
        count: 1,
        reached: false,
        display: Icon(Icons.shield_outlined, color: getColorByRarity(AchievementRarity.BRONZE), size: sizeIcon),
        title: "Storico",
        description: "Ottieni 8 o più di storia",
        subject: "STO",
        isPositive: true,
        type: AchievementType.GRADES,
        rarity: AchievementRarity.BRONZE));

    achievements.add(Achievement(
        valueToReach: 10,
        count: 1,
        reached: false,
        display: Icon(Icons.history, color: getColorByRarity(AchievementRarity.GOLD), size: sizeIcon),
        title: "Alberto Angela",
        description: "Ottieni 10 di storia",
        subject: "STO",
        isPositive: true,
        type: AchievementType.GRADES,
        rarity: AchievementRarity.GOLD));

    achievements.add(Achievement(
        valueToReach: 6,
        count: 1,
        reached: false,
        display: Icon(Icons.shield_moon, color: getColorByRarity(AchievementRarity.SILVER), size: sizeIcon),
        title: "La prima",
        description: "Si spera non di molte (1 insufficienza)",
        subject: "null",
        isPositive: false,
        type: AchievementType.GRADES,
        rarity: AchievementRarity.SILVER));

    achievements.add(Achievement(
        valueToReach: 0,
        count: 0,
        reached: false,
        display: Icon(Icons.gpp_good, color: getColorByRarity(AchievementRarity.SILVER), size: sizeIcon),
        title: "Studente Modello",
        description: "Non avere note disciplinari",
        subject: "null",
        isPositive: true,
        type: AchievementType.DISCIPLINARY_NOTE,
        rarity: AchievementRarity.SILVER));

    achievements.add(Achievement(
        valueToReach: 0,
        count: 1,
        reached: false,
        display: Icon(Icons.gpp_bad, color: getColorByRarity(AchievementRarity.BRONZE), size: sizeIcon),
        title: "Piccolo ribelle",
        description: "Una nota sola? Tutti iniziano da qualche parte.",
        subject: "null",
        isPositive: false,
        type: AchievementType.DISCIPLINARY_NOTE,
        rarity: AchievementRarity.BRONZE));

    achievements.add(Achievement(
        valueToReach: 0,
        count: 3,
        reached: false,
        display: Icon(Icons.gpp_bad, color: getColorByRarity(AchievementRarity.GOLD), size: sizeIcon),
        title: "Genio Incompreso",
        description: "Forse non ti capiscono… o forse sì, e per questo ti scrivono. (3 o più note)",
        subject: "null",
        isPositive: false,
        type: AchievementType.DISCIPLINARY_NOTE,
        rarity: AchievementRarity.GOLD));

    achievements.add(Achievement(
        valueToReach: 0,
        count: 10,
        reached: false,
        display: Icon(Icons.gpp_bad, color: getColorByRarity(AchievementRarity.LEGENDARY), size: sizeIcon),
        title: "Pericolo Pubblico",
        description: "Il tuo comportamento è materia di avviso ufficiale. (10 o più note)",
        subject: "null",
        isPositive: false,
        type: AchievementType.DISCIPLINARY_NOTE,
        rarity: AchievementRarity.LEGENDARY));

    achievements.add(Achievement(
        valueToReach: 0,
        count: 0,
        reached: false,
        display: Icon(Icons.gpp_good, color: getColorByRarity(AchievementRarity.PLATINUM), size: sizeIcon),
        title: "Niente richiami",
        description: "Non avere annotazioni",
        isPositive: true,
        subject: "null",
        type: AchievementType.ANNOTATION,
        rarity: AchievementRarity.PLATINUM));

    achievements.add(Achievement(
        valueToReach: 0,
        count: 1,
        reached: false,
        display: Icon(Icons.gpp_bad, color: getColorByRarity(AchievementRarity.BRONZE), size: sizeIcon),
        title: "Traccia Leggera",
        description: "Una piccola macchia sul registro, ma sei stato notato. (1 annotazione)",
        subject: "null",
        isPositive: false,
        type: AchievementType.ANNOTATION,
        rarity: AchievementRarity.BRONZE));

    achievements.add(Achievement(
        valueToReach: 0,
        count: 10,
        reached: false,
        display: Icon(Icons.gpp_bad, color: getColorByRarity(AchievementRarity.SILVER), size: sizeIcon),
        title: "Ape Fastidiosa",
        description: "Ronzando tra le regole, cominci a dare fastidio. (10 annotazione)",
        subject: "null",
        isPositive: false,
        type: AchievementType.ANNOTATION,
        rarity: AchievementRarity.SILVER));

    achievements.add(Achievement(
        valueToReach: 0,
        count: 0,
        reached: false,
        display: Icon(Icons.event_available, color: getColorByRarity(AchievementRarity.PLATINUM), size: sizeIcon),
        title: "Sempre Presente",
        description: "Non avere assenze",
        subject: "null",
        isPositive: true,
        type: AchievementType.ABSENCE,
        rarity: AchievementRarity.PLATINUM));

    achievements.add(Achievement(
        valueToReach: 0,
        count: 7,
        reached: false,
        display: Icon(Icons.event_busy, color: getColorByRarity(AchievementRarity.SILVER), size: sizeIcon),
        title: "Colazione Lunga",
        description: "Ti sei fermato al bar… e poi direttamente a casa. (7 o più assenze)",
        subject: "null",
        isPositive: false,
        type: AchievementType.ABSENCE,
        rarity: AchievementRarity.SILVER));

    achievements.add(Achievement(
        valueToReach: 0,
        count: 20,
        reached: false,
        display: Icon(Icons.event_busy, color: getColorByRarity(AchievementRarity.BRONZE), size: sizeIcon),
        title: "Sospeso (Onorario)",
        description: "Non serve la preside: ti punisci da solo. (20 o più assenze)",
        subject: "null",
        isPositive: false,
        type: AchievementType.ABSENCE,
        rarity: AchievementRarity.LEGENDARY));

    achievements.add(Achievement(
        valueToReach: 0,
        count: 0,
        reached: false,
        display: Icon(Icons.alarm_on, color: getColorByRarity(AchievementRarity.GOLD), size: sizeIcon),
        title: "Spaccare il Minuto",
        description: "Nessun ritardo fino ad ora",
        subject: "null",
        isPositive: true,
        type: AchievementType.DELAY,
        rarity: AchievementRarity.GOLD));

    achievements.add(Achievement(
        valueToReach: 0,
        count: 3,
        reached: false,
        display: Icon(Icons.alarm_off, color: getColorByRarity(AchievementRarity.GOLD), size: sizeIcon),
        title: "Ritardatario",
        description: "Sei arrivato in ritardo più di 3 volte",
        subject: "null",
        isPositive: false,
        type: AchievementType.DELAY,
        rarity: AchievementRarity.GOLD));

    achievements.add(Achievement(
        valueToReach: 0,
        count: 10,
        reached: false,
        display: Icon(Icons.alarm_off, color: getColorByRarity(AchievementRarity.PLATINUM), size: sizeIcon),
        title: "Ritardato",
        description: "Ormai è un'abitudine (oltre i 10 ritardi)",
        subject: "null",
        isPositive: false,
        type: AchievementType.DELAY,
        rarity: AchievementRarity.PLATINUM));

    achievements.add(Achievement(
        valueToReach: 0,
        count: 1,
        reached: false,
        display: Icon(Icons.hourglass_bottom, color: getColorByRarity(AchievementRarity.PLATINUM),  size: sizeIcon),
        title: "Fino alla Fine",
        description: "nessuna uscita anticipata fino ad ora",
        subject: "null",
        isPositive: true,
        type: AchievementType.EXITS,
        rarity: AchievementRarity.PLATINUM));

    achievements.add(Achievement(
        valueToReach: 0,
        count: 5,
        reached: false,
        display: Icon(Icons.hourglass_disabled, color: getColorByRarity(AchievementRarity.BRONZE),  size: sizeIcon),
        title: "Fuga strategica",
        description: "Esci più di 5 volte in anticipo",
        subject: "null",
        isPositive: false,
        type: AchievementType.EXITS,
        rarity: AchievementRarity.BRONZE));

    achievements.add(Achievement(
        valueToReach: 0,
        count: 15,
        reached: false,
        display: Icon(Icons.hourglass_disabled, color: getColorByRarity(AchievementRarity.LEGENDARY),  size: sizeIcon),
        title: "Campione della Fuga",
        description: "Hai trasformato l’uscita anticipata in uno sport. (esci 15 volte)",
        subject: "null",
        isPositive: false,
        type: AchievementType.EXITS,
        rarity: AchievementRarity.LEGENDARY));

    achievements.add(Achievement(
        valueToReach: 0,
        count: 0,
        reached: false,
        title: "4K",
        description: "Beccato in 4k a usare il telefono",
        subject: "telefono",
        isPositive: false,
        display: Icon(Icons.workspace_premium_sharp, color: getColorByRarity(AchievementRarity.GOLD), size: sizeIcon),
        type: AchievementType.DISCIPLINARY_NOTE,
        rarity: AchievementRarity.GOLD));

    return achievements;
  }

  static Color getColorByRarity(AchievementRarity rarity) {
    return switch(rarity) {
      AchievementRarity.SILVER => Colors.grey[500]!,
      AchievementRarity.BRONZE => Colors.orange[900]!,
      AchievementRarity.GOLD => Colors.yellow,
      AchievementRarity.PLATINUM => Colors.blueGrey[800]!,
      AchievementRarity.LEGENDARY => Colors.blue,
    };
  }
}
