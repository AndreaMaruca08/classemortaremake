import 'package:classemortaremake/core/extension/spacing_extension.dart';
import 'package:classemortaremake/core/extension/theme_extension.dart';
import 'package:classemortaremake/core/widgets/drawer.dart';
import 'package:classemortaremake/core/widgets/title.dart';
import 'package:flutter/material.dart';
import 'student_card.dart';

class StudentDetail extends StatefulWidget {
  final StudentCard card;
  const StudentDetail({super.key, required this.card});

  @override
  State<StudentDetail> createState() => _StudentDetailState();
}

class _StudentDetailState extends State<StudentDetail> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final card = widget.card;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageTitle(text: "Dettagli Studente", scaffoldKey: _scaffoldKey),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: context.containerDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Versione 3.0.0 Classemorta plus",
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    24.height,
                    _SectionTitle(title: "Informazioni studente"),
                    _DetailRow(label: "Nome e Cognome:", value: "${card.firstName} ${card.lastName}"),
                    _DetailRow(label: "Data di nascita:", value: card.birthDate),
                    _DetailRow(label: "Codice fiscale:", value: card.fiscalCode),
                    24.height,
                    _SectionTitle(title: "Informazioni scuola"),
                    _DetailRow(label: "Codice scuola:", value: card.schoolCode),
                    _DetailRow(label: "Codice MIUR:", value: card.miurSchoolCode),
                    _DetailRow(label: "Nome scuola:", value: "${card.schoolName} - ${card.schoolDedication}"),
                    _DetailRow(label: "Città:", value: card.schoolCity),
                    _DetailRow(label: "Provincia:", value: card.schoolProv),
                    24.height,
                    _SectionTitle(title: "Informazioni account"),
                    _DetailRow(
                      label: "Tipo utente:",
                      value: card.userType == "S"
                          ? "Studente"
                          : card.userType == "P"
                              ? "Professore"
                              : "Genitore",
                    ),
                    _DetailRow(label: "Codice account:", value: card.ident),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: context.textTheme.titleMedium,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label ",
            style: context.textTheme.bodySmall,
          ),
          Expanded(
            child: Text(value, style : context.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
