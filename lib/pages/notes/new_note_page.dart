import 'package:bootleg_google_keep_app/services/auth/auth_service.dart';
import 'package:bootleg_google_keep_app/services/notes/notes_service.dart';
import 'package:flutter/material.dart';

class NewNotePage extends StatefulWidget {
  const NewNotePage({Key? key}) : super(key: key);

  @override
  State<NewNotePage> createState() => _NewNotePageState();
}

class _NewNotePageState extends State<NewNotePage> {
  NotesDatabase? _note;
  late final NotesService _notesService;

  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  Future<NotesDatabase> createNewNote() async {
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    return await _notesService.createNote(
        owner: owner, title: _titleController.text, body: _bodyController.text);
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_titleController.text.isEmpty &&
        _bodyController.text.isEmpty &&
        note != null) {
      _notesService.deleteNote(id: note.id);
    }
  }

  void _saveNoteIfTextIsNotEmpty() async {
    final note = _note;
    if (_titleController.text.isNotEmpty &&
        _bodyController.text.isNotEmpty &&
        note != null) {
      await _notesService.updateNote(
          note: note, title: _titleController.text, body: _bodyController.text);
    }
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }

    final title = _titleController.text;
    final body = _bodyController.text;
    await _notesService.updateNote(note: note, title: title, body: body);
  }

  void setupTextControllerListener() {
    _titleController.removeListener(_textControllerListener);
    _bodyController.removeListener(_textControllerListener);

    _titleController.addListener(_textControllerListener);
    _bodyController.addListener(_textControllerListener);
  }

  @override
  void initState() {
    _notesService = NotesService();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextIsNotEmpty();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Note')),
      body: FutureBuilder(
          future: createNewNote(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                _note = snapshot.data as NotesDatabase;
                setupTextControllerListener();

                return Column(
                  children: [
                    TextField(
                        controller: _titleController,
                        decoration:
                            const InputDecoration(hintText: 'Your Note Title')),
                    TextField(
                      controller: _bodyController,
                      decoration: const InputDecoration(
                          hintText: 'Write your note here'),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    ),
                  ],
                );
              default:
                return const CircularProgressIndicator();
            }
          }),
    );
  }
}
