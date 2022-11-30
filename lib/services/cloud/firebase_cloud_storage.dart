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
      return value.docs.map((doc) => CloudNotes.fromSnapshot(doc));
    } catch (e) {
      throw CouldNotGetNotesException();
    }
  }

  Future<CloudNotes> createNewNote(
      {required String ownerUserId,
      required String title,
      required String body}) async {
    try {
      final document = await notes.add({
        ownerUserIdField: ownerUserId,
        titleField: title,
        bodyField: body,
      });
      final fetchedNote = await document.get();
      return CloudNotes(
          documentId: fetchedNote.id,
          ownerUserId: ownerUserId,
          title: title,
          body: body);
    } catch (e) {
      throw CouldNotCreateNoteException();
    }
  }

  Future<void> updateNote(
      {required String documentId,
      required String title,
      required String body}) async {
    try {
      await notes.doc(documentId).update({titleField: title, bodyField: body});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteException();
    }
  }

  // Singleton
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
