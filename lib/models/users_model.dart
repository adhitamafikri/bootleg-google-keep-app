class UsersModel {
  String get tableName => 'users';
  Map<String, String> get usersColumn => {
        'id': 'id',
        'email': 'email',
      };
}
