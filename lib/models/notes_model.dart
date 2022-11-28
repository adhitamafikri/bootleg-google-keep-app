class NotesModel {
  String get tableName => 'notes';
  Map<String, String> get notesColumn => {
        'id': 'id',
        'userId': 'user_id',
        'title': 'title',
        'body': 'body',
        'isSyncedWithCloud': 'is_synced_with_cloud',
      };
}
