class UserModel {
  final int cid;
  final String fullName;
  final String gender;
  final String phone;
  final String email;
  final String photo;

  UserModel({
    required this.cid,
    required this.fullName,
    required this.gender,
    required this.phone,
    required this.email,
    required this.photo,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      cid: json['cid'] ?? 0,
      fullName: json['full_name'] ?? '',
      gender: json['gender'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      photo: json['photo'] ?? '',
    );
  }
}
