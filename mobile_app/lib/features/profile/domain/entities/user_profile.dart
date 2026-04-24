class UserProfile {
  final String uid;
  final String name;
  final String username;
  final String email;
  final int points;
  final DateTime? createdAt;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    required this.points,
    this.createdAt,
  });
}
