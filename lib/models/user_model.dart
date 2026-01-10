class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final int dailyActivityGoal;
  final int inactivityThreshold;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
    this.dailyActivityGoal = 10000,
    this.inactivityThreshold = 30,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt.toIso8601String(),
      'dailyActivityGoal': dailyActivityGoal,
      'inactivityThreshold': inactivityThreshold,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      dailyActivityGoal: map['dailyActivityGoal'] ?? 10000,
      inactivityThreshold: map['inactivityThreshold'] ?? 30,
    );
  }
}
