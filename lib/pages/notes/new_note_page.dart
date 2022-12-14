import 'dart:developer';

import 'package:bootleg_google_keep_app/constants/routes.dart';
import 'package:bootleg_google_keep_app/services/auth/auth_service.dart';
import 'package:bootleg_google_keep_app/services/cloud/cloud_notes.dart';
import 'package:bootleg_google_keep_app/services/cloud/firebase_cloud_storage.dart';
import 'package:bootleg_google_keep_app/utils/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class NewNotePage extends StatefulWidget {
  const NewNotePage({Key? key}) : super(key: key);

  @override
  State<NewNotePage> createState() => _NewNotePageState();
}

class _NewNotePageState extends State<NewNotePage> {
  CloudNotes? _note;
  late final FirebaseCloudStorage _notesService;

  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  Future<CloudNotes?> createNewNote() async {
    try {
      final existingNote = _note;
      print(existingNote.toString());
      if (existingNote != null) {
        return existingNote;
      }

      if (_titleController.text.isNotEmpty && _bodyController.text.isNotEmpty) {
        final currentUser = AuthService.firebase().currentUser!;
        final userId = currentUser.id;
        final newNote = await _notesService.createNewNote(
            ownerUserId: userId,
            title: _titleController.text,
            body: _bodyController.text);
        log('newNote is: ${newNote}');
        return newNote;
      }

      return null;
    } catch (e) {
      throw UnimplementedError();
    }
  }

  Future<void> onSavePress() async {
    final result = await createNewNote();
    print('result is ${result}');
    if (result != null) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(notesRoute, (route) => false);
    }
  }

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('New Note'),
          actions: [
            IconButton(
                onPressed: () async {
                  final title = _titleController.text;
                  final body = _bodyController.text;

                  if (_note == null || title.isEmpty || body.isEmpty) {
                    await showCannotShareEmptyDialog(context);
                  } else {
                    Share.share('Note:\n$title\n\n$body');
                  }
                },
                icon: const Icon(Icons.share))
          ],
        ),
        body: Column(
          children: [
            TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'Your Note Title')),
            TextField(
              controller: _bodyController,
              decoration:
                  const InputDecoration(hintText: 'Write your note here'),
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
            TextButton(onPressed: onSavePress, child: const Text('Save Note'))
          ],
        ));
  }
}
