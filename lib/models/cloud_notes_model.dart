class CloudNotesModel {
  String get collectionName => 'notes';
  Map<String, String> get fields => {
        'id': 'id',
        'userId': 'user_id',
        'title': 'title',
        'body': 'body',
        'isSyncedWithCloud': 'is_synced_with_cloud',
      };
}
