import 'package:bootleg_google_keep_app/models/cloud_notes_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final CloudNotesModel cloudNotesModel = CloudNotesModel();

class CloudNotes {
  final String documentId;
  final String ownerUserId;
  final String title;
  final String body;

  const CloudNotes(
      {required this.documentId,
      required this.ownerUserId,
      required this.title,
      required this.body});

  CloudNotes.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[cloudNotesModel.fields['userId']],
        title = snapshot.data()[cloudNotesModel.fields['title']] as String,
        body = snapshot.data()[cloudNotesModel.fields['body']] as String;
}
