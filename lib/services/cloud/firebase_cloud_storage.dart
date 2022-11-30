import 'package:bootleg_google_keep_app/models/cloud_notes_model.dart';
import 'package:bootleg_google_keep_app/services/cloud/cloud_notes.dart';
import 'package:bootleg_google_keep_app/services/cloud/cloud_storage_exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final CloudNotesModel cloudNotesModel = CloudNotesModel();
final ownerUserIdField = '${cloudNotesModel.fields['userId']}';
final titleField = '${cloudNotesModel.fields['title']}';
final bodyField = '${cloudNotesModel.fields['body']}';

class FirebaseCloudStorage {
  final notes =
      FirebaseFirestore.instance.collection(cloudNotesModel.collectionName);

  Stream<Iterable<CloudNotes>> allNotes({required String ownerUserId}) =>
      notes.snapshots().map((event) => event.docs
          .map((doc) => CloudNotes.fromSnapshot(doc))
          .where((note) => note.ownerUserId == ownerUserId));

  Future<Iterable<CloudNotes>> getNotes({required String ownerUserId}) async {
    try {
      final value =
          await notes.where(ownerUserId, isEqualTo: ownerUserId).get();
      return value.docs.map((doc) => CloudNotes(
          documentId: doc.id,
          ownerUserId: doc.data()[ownerUserIdField],
          title: doc.data()[titleField],
          body: doc.data()[bodyField]));
    } catch (e) {
      throw CouldNotGetNotesException();
    }
  }

  void createNewNote({required String ownerUserId}) async {
    await notes.add({
      ownerUserIdField: ownerUserId,
      titleField: '',
      bodyField: '',
    });
  }

  // Singleton
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
