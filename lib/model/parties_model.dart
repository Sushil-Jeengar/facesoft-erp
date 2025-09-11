class Party {
  final int? id;
  final int userId;
  final String partyType;
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
  final bool status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? ownerName;
  final String? companyName;

  Party({
    this.id,
    required this.userId,
    required this.partyType,
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
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.ownerName,
    this.companyName,
  });

  factory Party.fromJson(Map<String, dynamic> json) {
    return Party(
      id: json['id'],
      userId: json['user_id'],
      partyType: json['party_type'],
      title: json['title'],
      description: json['description'],
      contactPerson: json['contact_person'],
      email: json['email'],
      phone: json['phone'],
      phoneCode: json['phone_code'],
      gst: json['gst'],
      openingBalance: json['opening_balance']?.toString() ?? '0.00',
      image: json['image'],
      note: json['note'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      code: json['code'],
      address: json['address'],
      status: json['status'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      ownerName: json['owner_name'],
      companyName: json['company_name'],
    );
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'user_id': userId,
      'party_type': partyType,
      'contact_person': contactPerson,
      'email': email,
      'phone': phone,
      'phone_code': phoneCode,
      'gst': gst,
      'opening_balance': openingBalance,
      'status': status,
    };
    // Add optional fields only if they are not null
    if (description != null) data['description'] = description;
    if (image != null) data['image'] = image;
    if (note != null) data['note'] = note;
    if (city != null) data['city'] = city;
    if (state != null) data['state'] = state;
    if (country != null) data['country'] = country;
    if (code != null) data['code'] = code;
    if (address != null) data['address'] = address;
    if (ownerName != null) data['owner_name'] = ownerName;
    if (companyName != null) data['company_name'] = companyName;
    return data;
  }

}


