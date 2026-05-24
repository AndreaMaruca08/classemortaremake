class Info {
  final String subject;
  final String teacherName;
  final String description;
  final String date;
  final String endDate;
  final String time;

  Info({
    required this.subject,
    required this.teacherName,
    required this.description,
    required this.date,
    required this.time,
    required this.endDate,
  });

  String get storageKey => "done_${subject}_${date}_${description.hashCode}";

  factory Info.fromJson(Map<String, dynamic> json) {
    final begin = json['evtDatetimeBegin']?.toString() ?? "";
    final end = json['evtDatetimeEnd']?.toString() ?? "";

    String timeStr = "Orario non disponibile";
    if (begin.length >= 16 && end.length >= 16) {
      timeStr = "${begin.substring(11, 16)} - ${end.substring(11, 16)}";
    }

    return Info(
      subject: json['subjectDesc'] as String? ?? "Non specificata",
      teacherName: json['authorName'] as String? ?? "Insegnante sconosciuto",
      description: json['notes'] as String? ?? "Nessuna descrizione",
      date: begin.isNotEmpty ? begin : "Data non disponibile",
      endDate: end.isNotEmpty ? end : "Data non disponibile",
      time: timeStr,
    );
  }

  static List<Info> fromJsonList(List<Map<String, dynamic>> jsonInput) {
    final list = jsonInput.map((json) => Info.fromJson(json)).toList();
    _sortInfoList(list);
    return list;
  }

  static void _sortInfoList(List<Info> list) {
    list.sort((a, b) {
      final da = DateTime.tryParse(a.date.substring(0, 10)) ?? DateTime(2100);
      final db = DateTime.tryParse(b.date.substring(0, 10)) ?? DateTime(2100);
      return da.compareTo(db);
    });
  }

  static List<int> getTimes(List<Map<String, dynamic>> jsonInput) {
    final infoList = fromJsonList(jsonInput);
    int countTomorrow = 0,
        countDayAfterTomorrow = 0,
        count3Days = 0,
        count4To7Days = 0,
        count8To14Days = 0,
        countMoreThan14Days = 0;

    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);

    for (final i in infoList) {
      final dataScadenza = DateTime.tryParse(i.endDate.split('T')[0]) ??
          DateTime.tryParse(i.endDate.substring(0, 10)) ??
          DateTime(2100);

      final difference = dataScadenza.difference(todayDateOnly).inDays;

      if (difference == 1) {
        countTomorrow++;
      } else if (difference == 2) {
        countDayAfterTomorrow++;
      } else if (difference == 3) {
        count3Days++;
      } else if (difference > 3 && difference <= 7) {
        count4To7Days++;
      } else if (difference >= 8 && difference <= 14) {
        count8To14Days++;
      } else if (difference > 14) {
        countMoreThan14Days++;
      }
    }
    return [
      countTomorrow,
      countDayAfterTomorrow,
      count3Days,
      count4To7Days,
      count8To14Days,
      countMoreThan14Days
    ];
  }

  static bool _isHomework(String desc) {
    final d = desc.toLowerCase();
    final keywords = [
      "es.",
      "eserc",
      "compit",
      "consegna",
      "invalsi",
      "studia",
      "n.",
      "scheda",
      "finire",
      "leggere",
      "version"
    ];
    final excludes = ["verific", "interroga"];
    return keywords.any((k) => d.contains(k)) &&
        !excludes.any((e) => d.contains(e));
  }

  static bool _isAgenda(String desc) {
    final d = desc.toLowerCase();
    return (d.contains("porta") || d.contains("entrambi")) &&
        !d.contains("verific");
  }

  static bool _isTest(String desc) {
    final d = desc.toLowerCase();
    final keywords = [
      "verific",
      "interroga",
      "compito in classe",
      "recuper",
      "writ",
      "speak",
      "liste",
      "test",
      "presentazion",
      "tema"
    ];
    final excludes = ["porta", "entrambi"];
    return keywords.any((k) => d.contains(k)) &&
        !excludes.any((e) => d.contains(e));
  }

  static List<Info> fromJsonListHomeworks(List<Map<String, dynamic>> jsonInput) {
    return fromJsonList(jsonInput.where((item) {
      final notes = item['notes']?.toString() ?? "";
      return _isHomework(notes);
    }).toList());
  }

  static List<Info> fromJsonListAgenda(List<Map<String, dynamic>> jsonInput) {
    return fromJsonList(jsonInput.where((item) {
      final notes = item['notes']?.toString() ?? "";
      return _isAgenda(notes);
    }).toList());
  }

  static List<Info> fromJsonListTests(List<Map<String, dynamic>> jsonInput) {
    return fromJsonList(jsonInput.where((item) {
      final notes = item['notes']?.toString() ?? "";
      return _isTest(notes);
    }).toList());
  }

  static List<Info> fromJsonForTomorrow(List<Map<String, dynamic>> jsonInput) {
    final today = DateTime.now();
    final filtered = jsonInput.where((item) {
      final dataStr = item['evtDatetimeEnd']?.toString();
      if (dataStr == null) return false;
      final dataScadenza =
          DateTime.tryParse(dataStr.substring(0, 10)) ?? DateTime(2100);
      return dataScadenza
                  .difference(DateTime(today.year, today.month, today.day))
                  .inDays ==
              1 &&
          dataScadenza.isAfter(today);
    }).toList();
    return fromJsonList(filtered);
  }

  static List<Info> fromJsonOther(List<Map<String, dynamic>> jsonInput) {
    return fromJsonList(jsonInput.where((item) {
      final notes = item['notes']?.toString() ?? "";
      return !_isHomework(notes) && !_isAgenda(notes) && !_isTest(notes);
    }).toList());
  }
}
