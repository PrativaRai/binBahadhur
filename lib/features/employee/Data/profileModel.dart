class UserProfile {
  final String name;
  final String phone;
  final String? profilePic;
  final int taken;
  final int completed;

  UserProfile({
    required this.name,
    required this.phone,
    this.profilePic,
    required this.taken,
    required this.completed,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      phone: json['phone'],
      profilePic: json['profilePic'],
      taken: json['tasksTaken'] ?? 0,
      completed: json['tasksCompleted'] ?? 0,
    );
  }
}
