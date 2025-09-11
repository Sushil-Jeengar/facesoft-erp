class Quality {
  final int? id;
  final int? userId;
  final String? qualityName;
  final String? qualityCode;
  final String? color;
  final String? composition;
  final String? gsm;
  final String? width;
  final String? details;
  final String? image;
  final bool? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? ownerName;

  Quality({
    this.id,
    this.userId,
    this.qualityName,
    this.qualityCode,
    this.color,
    this.composition,
    this.gsm,
    this.width,
    this.details,
    this.image,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.ownerName,
  });

  factory Quality.fromJson(Map<String, dynamic> json) {
    return Quality(
      id: json['id'] ?? 0,
      userId: json['user_id'],
      qualityName: json['quality_name'] ?? 'No Name',
      qualityCode: json['quality_code'],
      color: json['color'],
      composition: json['composition'],
      gsm: json['gsm'],
      width: json['width'],
      details: json['details'],
      image: json['image'],
      status: json['status'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      ownerName: json['owner_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'quality_name': qualityName,
      'quality_code': qualityCode,
      'color': color,
      'composition': composition,
      'gsm': gsm,
      'width': width,
      'details': details,
      'image': image,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'owner_name': ownerName,
    };
  }
}
