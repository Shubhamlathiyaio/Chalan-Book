class OrganizationMember {
  final String id;
  final String organizationId;
  final String userId;
  final String email;
  final String name;
  final String role;
  final DateTime joinedAt;

  OrganizationMember({
    required this.id,
    required this.organizationId,
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
    required this.joinedAt,
  });

  factory OrganizationMember.fromJson(Map<String, dynamic> json) {
    return OrganizationMember(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      userId: json['user_id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'user_id': userId,
      'email': email,
      'name': name,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}
