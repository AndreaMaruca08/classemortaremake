import 'dart:convert';
import '../core/api/http_client.dart';
import 'note.dart';

class NotesService {
  final HttpClient _client = HttpClient();

  Future<List<List<Note>>> fetchAllNotes() async {
    final endpoint = "students/${_client.numericCode}/notes/all";
    final response = await _client.get(endpoint);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final notesCategories = Note.getNotes(json);
      
      final List<String> types = ["NTCL", "NTTE", "NTST", "NTWN"];

      // Fetch full content for notes that have "..." as placeholder
      for (int i = 0; i < notesCategories.length; i++) {
        final categoryType = types[i];
        final List<Note> categoryList = notesCategories[i];
        
        for (Note note in categoryList) {
          if (note.message == "...") {
            await _fetchNoteDetail(note, categoryType);
          }
        }
      }
      
      return notesCategories;
    } else {
      throw Exception("Failed to fetch notes");
    }
  }

  Future<void> _fetchNoteDetail(Note note, String type) async {
    final endpoint = "students/${_client.numericCode}/notes/$type/read/${note.id}";
    final response = await _client.post(endpoint);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['event'] != null && json['event']['evtText'] != null) {
        note.message = json['event']['evtText'];
        note.isRead = true;
      }
    }
  }
}
