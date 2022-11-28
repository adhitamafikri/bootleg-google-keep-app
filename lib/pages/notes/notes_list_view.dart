import 'package:bootleg_google_keep_app/services/notes/notes_service.dart';
import 'package:bootleg_google_keep_app/utils/dialogs/delete_dialog.dart';
import 'package:flutter/material.dart';

typedef DeleteNoteCallback = void Function(NotesDatabase note);

class NotesListView extends StatelessWidget {
  final List<NotesDatabase> notes;
  final DeleteNoteCallback onDeleteNote;
  const NotesListView(
      {Key? key, required this.notes, required this.onDeleteNote})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return ListTile(
            title: Text(
              note.title,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(note.body,
                maxLines: 1, softWrap: true, overflow: TextOverflow.ellipsis),
            trailing: IconButton(
              onPressed: () async {
                final shouldDelete = await showDeleteDialog(context);
                if (shouldDelete) {
                  onDeleteNote(note);
                }
              },
              icon: const Icon(Icons.delete),
            ),
          );
        });
  }
}
