class UserModel {
  final int id;
  final String email;
  final String? displayName;
  final String? phone;
  final String? gender;
  final String? location; // Map từ 'address' của backend
  final String? avatarUrl; // Thêm trường này
  final String? role;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.phone,
    this.gender,
    this.location,
    this.avatarUrl,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      displayName: json['displayName'],
      phone: json['phoneNumber'],
      gender: json['gender'],
      location: json['address'],
      avatarUrl: json['avatarUrl'],
      role: json['role']?.toString(),
    );
  }

}