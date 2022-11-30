import 'package:bootleg_google_keep_app/constants/routes.dart';
import 'package:bootleg_google_keep_app/utils/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:bootleg_google_keep_app/utils/generics/get_arguments.dart';
import 'package:bootleg_google_keep_app/services/cloud/cloud_notes.dart';
import 'package:bootleg_google_keep_app/services/cloud/firebase_cloud_storage.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class UpdateNotePage extends StatefulWidget {
  const UpdateNotePage({Key? key}) : super(key: key);

  @override
  State<UpdateNotePage> createState() => _UpdateNotePageState();
}

class _UpdateNotePageState extends State<UpdateNotePage> {
  CloudNotes? _note;
  late final FirebaseCloudStorage _notesService;

  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  Future<CloudNotes?> getNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNotes>();

    if (widgetNote != null) {
      _note = widgetNote;
      _titleController.text = widgetNote.title;
      _bodyController.text = widgetNote.body;
      return widgetNote;
    }
  }

  Future<CloudNotes?> updateNote() async {
    try {
      final existingNote = _note;
      if (existingNote == null) {
        return null;
      }

      if (_titleController.text.isNotEmpty && _bodyController.text.isNotEmpty) {
        await _notesService.updateNote(
            documentId: existingNote.documentId,
            title: _titleController.text,
            body: _bodyController.text);
      }

      return null;
    } catch (e) {
      throw UnimplementedError();
    }
  }

  Future<void> onUpdatePress() async {
    final result = await updateNote();
    print('resultto: $result');
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
          title: const Text('Update Note'),
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
        body: FutureBuilder(
            future: getNote(context),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  return Column(
                    children: [
                      TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                              hintText: 'Your Note Title')),
                      TextField(
                        controller: _bodyController,
                        decoration: const InputDecoration(
                            hintText: 'Write your note here'),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                      ),
                      TextButton(
                          onPressed: onUpdatePress,
                          child: const Text('Update Note'))
                    ],
                  );
                default:
                  return const CircularProgressIndicator();
              }
            }));
  }
}
