class Profile {
  final String id;
  final String email;
  final String name;
  final DateTime? createdAt;

  Profile({
    required this.id,
    required this.email,
    required this.name,
    this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String? ?? '',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at']),
    );
  }
}
