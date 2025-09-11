class Company {
  final int? id;
  final int userId;
  final String? name;
  final String? website;
  final String? email;
  final String? phone;
  final String? phoneCode;
  final String? gst;
  final String? openingBalance;
  final String? image;
  final String? note;
  final String? address;
  final String? code;
  final String? city;
  final String? state;
  final String? country;
  final bool? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? ownerName;

  Company({
    this.id,
    required this.userId,
    this.name,
    this.website,
    this.email,
    this.phone,
    this.phoneCode,
    this.gst,
    this.openingBalance,
    this.image,
    this.note,
    this.address,
    this.code,
    this.city,
    this.state,
    this.country,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.ownerName,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      website: json['website'],
      email: json['email'],
      phone: json['phone'],
      phoneCode: json['phone_code'],
      gst: json['gst'],
      openingBalance: json['opening_balance'],
      image: json['image'],
      note: json['note'],
      address: json['address'],
      code: json['code'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      ownerName: json['owner_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'website': website,
      'email': email,
      'phone': phone,
      'phone_code': phoneCode,
      'gst': gst,
      'opening_balance': openingBalance,
      'image': image,
      'note': note,
      'address': address,
      'code': code,
      'city': city,
      'state': state,
      'country': country,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'owner_name': ownerName,
    };
  }
}
