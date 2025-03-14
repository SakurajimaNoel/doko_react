/// this defines user to user relation between
/// any two users
class UserRelationInfo {
  const UserRelationInfo({
    required this.requestedBy,
    required this.status,
    required this.addedOn,
  });

  final String requestedBy;
  final String status;
  final DateTime addedOn;

  static UserRelationInfo createEntity({required Map map}) {
    return UserRelationInfo(
      requestedBy: map["requestedBy"],
      status: map["status"],
      addedOn: DateTime.parse(map["addedOn"]).toLocal(),
    );
  }

  UserRelationInfo copyWith({
    String? requestedBy,
    String? status,
    DateTime? addedOn,
  }) {
    return UserRelationInfo(
      requestedBy: requestedBy ?? this.requestedBy,
      status: status ?? this.status,
      addedOn: addedOn ?? this.addedOn,
    );
  }
}
