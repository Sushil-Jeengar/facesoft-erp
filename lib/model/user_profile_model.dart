class UserProfile {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? userName;
  final String? profileImage;
  final String? phoneNumber;
  final int? roleId;
  final bool? status;
  final String? country;
  final String? city;
  final String? state;
  final int? pincode;
  final String? address;
  final int? age;
  final String? gender;
  final String? bio;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? roleName;

  UserProfile({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.userName,
    this.profileImage,
    this.phoneNumber,
    this.roleId,
    this.status,
    this.country,
    this.city,
    this.state,
    this.pincode,
    this.address,
    this.age,
    this.gender,
    this.bio,
    this.createdAt,
    this.updatedAt,
    this.roleName,
  });

  // Factory method to create a UserProfile from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      userName: json['user_name'],
      profileImage: json['profile_image'],
      phoneNumber: json['phone_number'],
      roleId: json['role_id'],
      status: json['status'],
      country: json['country'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      address: json['address'],
      age: json['age'],
      gender: json['gender'],
      bio: json['bio'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      roleName: json['role_name'],
    );
  }

  // Method to convert UserProfile to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'user_name': userName,
      'profile_image': profileImage,
      'phone_number': phoneNumber,
      'role_id': roleId,
      'status': status,
      'country': country,
      'city': city,
      'state': state,
      'pincode': pincode,
      'address': address,
      'age': age,
      'gender': gender,
      'bio': bio,
      'created_at': createdAt!.toIso8601String(),
      'updated_at': updatedAt!.toIso8601String(),
      'role_name': roleName,
    };
  }
}
