class Agent {
  final int? id;
  final int? userId;
  final String? title;
  final String? description;
  final String? agentName;
  final String? contactPerson;
  final String? email;
  final String? phone;
  final String? phoneCode;
  final String? gst;
  final String? image;
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

  Agent({
    this.id,
    this.userId,
    this.title,
    this.description,
    this.agentName,
    this.contactPerson,
    this.email,
    this.phone,
    this.phoneCode,
    this.gst,
    this.image,
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

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['id'] ?? 0,
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      agentName: json['agent_name'] ?? 'No Name',
      contactPerson: json['contact_person'],
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      phoneCode: json['phone_code'],
      gst: json['gst'],
      image: json['image'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      code: json['code'],
      address: json['address'],
      status: json['status'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      ownerName: json['owner_name'] ?? '',
      companyName: json['company_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'agent_name': agentName,
      'contact_person': contactPerson,
      'email': email,
      'phone': phone,
      'phone_code': phoneCode,
      'gst': gst,
      'image': image,
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
