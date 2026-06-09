import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../lessons/day.dart';
import '../../lessons/lesson_hour.dart';
import '../../grades/grade.dart';
import '../../achievement/streak.dart';

class PdfService {
  static Future<void> generateSchedulePdf({
    required List<Day> week,
    required String title,
  }) async {
    try {
      final pdf = pw.Document();
      
      // Load fonts. Using a try-catch because printing plugin might fail on some platforms if not initialized
      pw.Font? font;
      pw.Font? boldFont;
      try {
        font = await PdfGoogleFonts.robotoRegular();
        boldFont = await PdfGoogleFonts.robotoBold();
      } catch (e) {
        print("Font loading error, using default: $e");
        // Fallback to standard fonts (might not support all Unicode symbols)
      }

      final List<String> dayNames = ['Lunedì', 'Martedì', 'Mercoledì', 'Giovedì', 'Venerdì'];
      final List<PdfColor> palette = [
        PdfColors.red300, PdfColors.blue300, PdfColors.green300, PdfColors.orange300,
        PdfColors.purple300, PdfColors.teal300, PdfColors.cyan300, PdfColors.amber300,
        PdfColors.indigo300, PdfColors.pink300, PdfColors.deepOrange300, PdfColors.lightGreen300,
        PdfColors.deepPurple300, PdfColors.lime300, PdfColors.lightBlue300,
      ];

      PdfColor getSubjectColor(String subject) {
        if (subject.isEmpty) return PdfColors.grey;
        String name = subject.trim().toUpperCase();
        int hash = 5381;
        for (int i = 0; i < name.length; i++) {
          hash = ((hash << 5) + hash) + name.codeUnitAt(i);
        }
        return palette[hash.abs() % palette.length];
      }

      final Map<String, List<int>> subjectCounts = {};
      for (int i = 0; i < week.length; i++) {
        for (var hour in week[i].hours) {
          final subject = hour.subject;
          subjectCounts.putIfAbsent(subject, () => List.filled(5, 0));
          if (i < 5) subjectCounts[subject]![i]++;
        }
      }
      final subjects = subjectCounts.keys.toList()..sort();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          orientation: pw.PageOrientation.landscape,
          theme: font != null ? pw.ThemeData.withFont(base: font, bold: boldFont) : null,
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text("ClasseMorta Plus", style: const pw.TextStyle(color: PdfColors.grey)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text("Ora", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    ...dayNames.map((d) => pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(d, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    )),
                  ],
                ),
                ...List.generate(8, (hourIdx) {
                  final hNum = hourIdx + 1;
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text("$hNum", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      ...List.generate(5, (dayIdx) {
                        final day = week[dayIdx];
                        final hour = day.hours.firstWhere((h) => h.hour == hNum, orElse: () => LessonHour(subject: "", teachers: [], hour: 0, description: ""));
                        
                        if (hour.subject.isEmpty) {
                          return pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("-"));
                        }
                        
                        final color = getSubjectColor(hour.subject);
                        return pw.Container(
                          color: color.shade(0.1),
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(hour.subject, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: color.shade(0.9))),
                              pw.Text(hour.teachers.join(", "), style: const pw.TextStyle(fontSize: 7)),
                            ],
                          ),
                        );
                      }),
                    ],
                  );
                }),
              ],
            ),
            
            pw.SizedBox(height: 40),
            pw.Text("Riepilogo Ore Settimanali", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("Materia", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("Tot", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("L", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("M", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("M", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("G", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("V", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                ...subjects.map((sub) {
                  final counts = subjectCounts[sub]!;
                  final total = counts.reduce((a, b) => a + b);
                  return pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(sub, style: const pw.TextStyle(fontSize: 10))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(total.toString(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                      ...counts.map((c) => pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Center(child: pw.Text(c == 0 ? "-" : c.toString(), style: const pw.TextStyle(fontSize: 10))),
                      )),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      );

      // Save the PDF
      final bytes = await pdf.save();
      final tempDir = await getTemporaryDirectory();
      
      // Ensure the directory exists (macOS Sandbox fix)
      if (!await tempDir.exists()) {
        await tempDir.create(recursive: true);
      }
      
      final safeTitle = title.replaceAll(RegExp(r'[^\w\s]+'), '_').replaceAll(' ', '_');
      final filePath = "${tempDir.path}/$safeTitle.pdf";
      final file = File(filePath);
      
      await file.writeAsBytes(bytes, flush: true);

      if (await file.exists()) {
        await OpenOpenFilex(filePath);
      }
    } catch (e) {
      print("PdfService Error: $e");
    }
  }

  static Future<void> OpenOpenFilex(String path) async {
    try {
      await OpenFilex.open(path);
    } catch (e) {
      print("Error opening file: $e");
    }
  }

  static Future<void> generateSubjectReport({
    required String subjectName,
    required String teacherName,
    required List<Grade> grades,
    required double average,
    required double consistency,
    required Streak streak,
  }) async {
    try {
      final pdf = pw.Document();
      final font = await PdfGoogleFonts.robotoRegular();
      final boldFont = await PdfGoogleFonts.robotoBold();

      final validGrades = grades.where((g) => !g.isCanceled).toList();
      final sortedGrades = List<Grade>.from(validGrades)..sort((a, b) => a.date.compareTo(b.date));

      // Distribution data
      final Map<double, int> frequencies = {};
      int maxFreq = 0;
      for (var g in validGrades) {
        frequencies[g.value] = (frequencies[g.value] ?? 0) + 1;
        if (frequencies[g.value]! > maxFreq) maxFreq = frequencies[g.value]!;
      }

      // Ensure a minimum of 5 for the Y axis
      final double yMax = maxFreq < 5 ? 5 : maxFreq.toDouble();
      final List<double> yTicks = List.generate(yMax.toInt() + 1, (i) => i.toDouble());

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(base: font, bold: boldFont),
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Report Materia: $subjectName" ,
                      style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.Text("ClasseMorta Plus", style: const pw.TextStyle(color: PdfColors.grey)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Info Card
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
              ),
              child: pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem("Media", average.toStringAsFixed(2),
                          average >= 6 ? PdfColors.green : PdfColors.red),
                      _buildStatItem("Costanza", "${consistency.toStringAsFixed(1)}%", PdfColors.blue),
                      _buildStatItem("Streak", streak.goodGrades.toString(),
                          streak.isActive ? PdfColors.orange : PdfColors.grey),
                      _buildStatItem("Voti", validGrades.length.toString(), PdfColors.black),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  pw.Divider(),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    children: [
                      pw.Text("Docente: ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(teacherName),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 30),

            // Trend Chart
            pw.Text("Andamento Voti", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Container(
              height: 200,
              child: pw.Chart(
                grid: pw.CartesianGrid(
                  xAxis: pw.FixedAxis(
                    List.generate(sortedGrades.length, (i) => i.toDouble()),
                    buildLabel: (value) => pw.Text(""),
                  ),
                  yAxis: pw.FixedAxis(
                    [0, 2, 4, 6, 8, 10],
                    divisions: true,
                  ),
                ),
                datasets: [
                  pw.LineDataSet(
                    color: PdfColors.blue,
                    drawPoints: true,
                    pointSize: 3,
                    data: List.generate(
                      sortedGrades.length,
                      (i) => pw.PointChartValue(i.toDouble(), sortedGrades[i].value),
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 30),

            // Distribution Chart
            pw.Text("Distribuzione Voti", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Container(
              height: 200,
              child: pw.Chart(
                grid: pw.CartesianGrid(
                  xAxis: pw.FixedAxis(
                    List.generate(11, (i) => i.toDouble()),
                    divisions: true,
                  ),
                  yAxis: pw.FixedAxis(
                    yTicks,
                    divisions: true,
                  ),
                ),
                datasets: [
                  pw.BarDataSet(
                    color: PdfColors.blue,
                    width: 10,
                    data: List.generate(21, (i) {
                      final val = i * 0.5;
                      return pw.PointChartValue(val, (frequencies[val] ?? 0).toDouble());
                    }),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 30),

            // List of grades
            pw.Text("Dettaglio Voti", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: const {
                0: pw.FlexColumnWidth(1.2), // Data
                1: pw.FlexColumnWidth(0.6), // Voto
                2: pw.FlexColumnWidth(1.2), // Tipo
                3: pw.FlexColumnWidth(2.5), // Commento
                4: pw.FlexColumnWidth(1.5), // Docente
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("Data", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("Voto", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("Tipo", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("Commento", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("Docente", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                  ],
                ),
                ...validGrades.map((g) => pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(g.date, style: const pw.TextStyle(fontSize: 8))),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(g.displayValue,
                          style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: g.value >= 6 ? PdfColors.green : PdfColors.red)),
                    ),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(g.type, style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(g.description, style: const pw.TextStyle(fontSize: 8))),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(g.teacherName, style: const pw.TextStyle(fontSize: 8))),
                  ],
                )),
              ],
            ),
          ],
        ),
      );

      final bytes = await pdf.save();
      final tempDir = await getTemporaryDirectory();
      if (!await tempDir.exists()) await tempDir.create(recursive: true);

      final safeName = subjectName.replaceAll(RegExp(r'[^\w\s]+'), '_').replaceAll(' ', '_');
      final filePath = "${tempDir.path}/Report_$safeName.pdf";
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);
      await OpenOpenFilex(filePath);
    } catch (e) {
      print("Error generating subject report: $e");
    }
  }

  static pw.Widget _buildStatItem(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
        pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: color)),
      ],
    );
  }
}
