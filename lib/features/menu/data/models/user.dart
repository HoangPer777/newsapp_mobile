class UserModel {
  final int id;
  final String email;
  final String? displayName;
  final String? phone;
  final String? gender;
  final String? location;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.phone,
    this.gender,
    this.location,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      phone: json['phoneNumber'],
      gender: json['gender'],
      location: json['address'],
    );
  }
}
