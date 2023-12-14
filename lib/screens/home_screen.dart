import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotesList extends StatefulWidget {
  const NotesList({super.key});

  @override
  State<NotesList> createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  late SharedPreferences _prefs;
  List<String> notes = [];
  late TextEditingController _notesController;

  @override
  void initState() {
    _notesController = TextEditingController();
    _initSharedPreferences();
    super.initState();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadNotesFromStorage();
  }

  void _loadNotesFromStorage() {
    List<String>? storedNotes = _prefs.getStringList('notes');
    if (storedNotes != null) {
      setState(() {
        notes = storedNotes;
      });
    }
  }

  void _saveNotesToStorage() {
    _prefs.setStringList('notes', notes);
  }

  void _addNote(String note) {
    setState(() {
      notes.add(note);
    });
    _saveNotesToStorage();
  }

  void _deleteNote(int index) {
    setState(() {
      notes.removeAt(index);
    });
    _saveNotesToStorage();
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Note'),
          content: TextField(
            controller: _notesController,
            decoration: const InputDecoration(hintText: 'Enter your note'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _notesController.clear();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_notesController.text.isNotEmpty) {
                  _addNote(_notesController.text);
                  Navigator.of(context).pop();
                  _notesController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fill in the blanks.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotesList() {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(notes[index]),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteNote(index),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes List'),
      ),
      body: _buildNotesList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteDialog,
        tooltip: 'Add note',
        child: const Icon(Icons.add),
      ),
    );
  }
}
