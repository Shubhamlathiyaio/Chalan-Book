class Chalan {
  final String id;
  final String organizationId;
  final String createdBy;
  final String chalanNumber;
  final String? description;
  final String? imageUrl;
  final DateTime dateTime;

  Chalan({
    required this.id,
    required this.organizationId,
    required this.createdBy,
    required this.chalanNumber,
    this.description,
    this.imageUrl,
    required this.dateTime,
  });

  factory Chalan.fromJson(Map<String, dynamic> json) {
    return Chalan(
      id: json['id'],
      organizationId: json['organization_id'],
      createdBy: json['created_by'],
      chalanNumber: json['chalan_number'],
      description: json['description'],
      imageUrl: json['image_url'],
      dateTime: DateTime.parse(json['date_time']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'created_by': createdBy,
      'chalan_number': chalanNumber,
      'description': description,
      'image_url': imageUrl,
      'date_time': dateTime.toIso8601String(),
    };
  }
}
