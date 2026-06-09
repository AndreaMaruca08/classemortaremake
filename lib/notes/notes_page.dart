import 'package:classemortaremake/core/widgets/drawer.dart';
import 'package:classemortaremake/core/widgets/title.dart';
import 'package:flutter/material.dart';
import 'package:classemortaremake/core/extension/spacing_extension.dart';
import 'note.dart';
import 'notes_service.dart';
import 'widgets/note_card.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final NotesService _service = NotesService();
  late Future<List<List<Note>>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _notesFuture = _service.fetchAllNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: FutureBuilder<List<List<Note>>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              children: [
                PageTitle(text: "Note", scaffoldKey: _scaffoldKey),
                const Expanded(child: Center(child: CircularProgressIndicator())),
              ],
            );
          }
          if (snapshot.hasError) {
            return Column(
              children: [
                PageTitle(text: "Note", scaffoldKey: _scaffoldKey),
                Expanded(child: Center(child: Text("Errore: ${snapshot.error}"))),
              ],
            );
          }

          final disciplinary = snapshot.data?[0] ?? [];
          final annotations = snapshot.data?[1] ?? [];
          final classNotes = snapshot.data?[2] ?? [];
          final warnings = snapshot.data?[3] ?? [];

          if (disciplinary.isEmpty && annotations.isEmpty && classNotes.isEmpty && warnings.isEmpty) {
            return Column(
              children: [
                PageTitle(text: "Note", scaffoldKey: _scaffoldKey),
                const Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'Nessuna nota presente sul registro.',
                        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageTitle(text: "Note", scaffoldKey: _scaffoldKey),
                if (disciplinary.isNotEmpty)
                  _buildHorizontalSection("Note Disciplinari", disciplinary, Colors.red),
                if (annotations.isNotEmpty)
                  _buildHorizontalSection("Annotazioni", annotations, Colors.orange),
                if (classNotes.isNotEmpty)
                  _buildHorizontalSection("Note di Classe", classNotes, Colors.blue),
                if (warnings.isNotEmpty)
                  _buildHorizontalSection("Avvisi", warnings, Colors.amber),
                100.height,
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalSection(String title, List<Note> notes, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 12.0),
          child: Text(
            "$title (${notes.length})",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: NoteCard(note: notes[index], color: color),
              );
            },
          ),
        ),
      ],
    );
  }
}
