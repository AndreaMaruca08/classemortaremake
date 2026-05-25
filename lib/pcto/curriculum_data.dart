import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class CurriculumData {
  final String phpSessId;
  final String expectedHoursRaw;
  final String totalAttendanceHoursRaw;
  final List<Experience> experiences;

  int get expectedHours => _parseHours(expectedHoursRaw);
  int get totalAttendanceHours => _parseHours(totalAttendanceHoursRaw);

  CurriculumData({
    required this.phpSessId,
    required this.expectedHoursRaw,
    required this.totalAttendanceHoursRaw,
    required this.experiences,
  });

  static int _parseHours(String? hourString) {
    if (hourString == null || hourString.trim().isEmpty || hourString == 'N/A') {
      return 0;
    }
    
    // Improved parsing for ClasseViva formats like "119h 30m" or "119:30"
    // We try to extract the hour part before any 'h', ':', or space
    String normalized = hourString.toLowerCase().trim();
    
    // If it contains 'h', take everything before it
    if (normalized.contains('h')) {
      final part = normalized.split('h').first.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(part) ?? 0;
    }
    
    // If it contains ':', take everything before it
    if (normalized.contains(':')) {
      final part = normalized.split(':').first.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(part) ?? 0;
    }

    // Default fallback: just numbers
    final numericPart = normalized.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericPart.isEmpty) return 0;
    return int.tryParse(numericPart) ?? 0;
  }
}

class Experience {
  final String locationName;
  final String experienceHoursRaw;
  final String attendanceHoursRaw;

  int get experienceHours => CurriculumData._parseHours(experienceHoursRaw);
  int get attendanceHours => CurriculumData._parseHours(attendanceHoursRaw);

  Experience({
    required this.locationName,
    required this.experienceHoursRaw,
    required this.attendanceHoursRaw,
  });
}

CurriculumData? parseCurriculumHtml(String htmlContent, String phpsessId) {
  try {
    var document = parse(htmlContent);

    String expectedHoursStr = 'N/A';
    String totalAttendanceHoursStr = 'N/A';

    Element? summaryRow;
    final allRows = document.querySelectorAll('table.ele-prog tr');
    for (var row in allRows) {
      if (row.text.contains('Ore totali previste')) {
        summaryRow = row;
        break;
      }
    }

    if (summaryRow != null) {
      expectedHoursStr = summaryRow.querySelector('p.font_size_16')?.text.trim() ?? 'N/A';
      totalAttendanceHoursStr = summaryRow.querySelector('p.font_size_14.greentext')?.text.trim() ?? 'N/A';
    }

    List<Experience> experiencesList = [];
    List<Element> experienceRows = document.querySelectorAll('table.ele-prog tbody tr[id]');

    for (var row in experienceRows) {
      if (row.id == 'placeholder_row') continue;

      String locationName = row.querySelector('a p strong')?.text.trim() ?? 'N/A';
      if (locationName == 'N/A') {
        locationName = row.querySelector('p.opensans_condensed strong')?.text.trim() ?? 'N/A';
      }

      String experienceHours = row.querySelector('div[class*="curriculum_col_view"] span[class*="font_size_20"]')?.text.trim() ?? 'N/A';
      String attendanceHours = 'N/A';

      var presenceDivVisible = row.querySelector('div[style*="display: ;"] div[style*="rgba(50, 205, 0"] p');
      if (presenceDivVisible != null && presenceDivVisible.text.trim().isNotEmpty) {
        attendanceHours = presenceDivVisible.text.trim();
      }

      if (attendanceHours == 'N/A') {
        var presenceDivHidden = row.querySelector('div[style*="display: none"] div[style*="rgba(50, 205, 0"] p');
        if (presenceDivHidden != null && presenceDivHidden.text.trim().isNotEmpty) {
          attendanceHours = presenceDivHidden.text.trim();
        }
      }

      if (attendanceHours == 'N/A' && CurriculumData._parseHours(experienceHours) > 0) {
        var schoolYearHeader = row.previousElementSibling;
        if (schoolYearHeader != null && schoolYearHeader.text.contains('20')) {
          String yearHoursText = schoolYearHeader.querySelector('span.greentext')?.text.trim() ?? '';
          if (yearHoursText.isNotEmpty && CurriculumData._parseHours(experienceHours) == CurriculumData._parseHours(yearHoursText)) {
            attendanceHours = yearHoursText;
          }
        }
      }

      if (attendanceHours == 'N/A') {
        attendanceHours = '0h0m';
      }

      if (locationName != 'N/A') {
        experiencesList.add(Experience(
          locationName: locationName,
          experienceHoursRaw: experienceHours,
          attendanceHoursRaw: attendanceHours,
        ));
      }
    }

    return CurriculumData(
      phpSessId: phpsessId,
      expectedHoursRaw: expectedHoursStr,
      totalAttendanceHoursRaw: totalAttendanceHoursStr,
      experiences: experiencesList,
    );
  } catch (e) {
    print('Error during HTML parsing: $e');
    return null;
  }
}
