class Supplier {
  final int? id;
  final int userId;
  final int? partyId;
  final String? title;
  final String? description;
  final String? contactPerson;
  final String? email;
  final String? phone;
  final String? phoneCode;
  final String? gst;
  final String? openingBalance;
  final String? image;
  final String? note;
  final String? city;
  final String? state;
  final String? country;
  final String? code;
  final String? address;
  final bool? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? ownerName;
  final String? companyName;

  Supplier({
    this.id,
    required this.userId,
    this.partyId,
    this.title,
    this.description,
    this.contactPerson,
    this.email,
    this.phone,
    this.phoneCode,
    this.gst,
    this.openingBalance,
    this.image,
    this.note,
    this.city,
    this.state,
    this.country,
    this.code,
    this.address,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.ownerName,
    this.companyName,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      userId: json['user_id'],
      partyId: json['party_id'],
      title: json['title'],
      description: json['description'],
      contactPerson: json['contact_person'],
      email: json['email'],
      phone: json['phone'],
      phoneCode: json['phone_code'],
      gst: json['gst'],
      openingBalance: json['opening_balance'],
      image: json['image'],
      note: json['note'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      code: json['code'],
      address: json['address'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      ownerName: json['owner_name'],
      companyName: json['company_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'party_id': partyId,
      'title': title,
      'description': description,
      'contact_person': contactPerson,
      'email': email,
      'phone': phone,
      'phone_code': phoneCode,
      'gst': gst,
      'opening_balance': openingBalance,
      'image': image,
      'note': note,
      'city': city,
      'state': state,
      'country': country,
      'code': code,
      'address': address,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'owner_name': ownerName,
      'company_name': companyName,
    };
  }
}
