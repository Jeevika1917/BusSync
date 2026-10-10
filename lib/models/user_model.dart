class UserModel {
  final int id;
  final String email;
  final String role; // 'PASSENGER', 'DRIVER', 'ADMIN'
  final String name;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      email: json['email'] ?? '',
      role: json['role'] ?? 'PASSENGER',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'name': name,
    };
  }

  bool get isDriver => role == 'DRIVER';
  bool get isAdmin => role == 'ADMIN';
  bool get isPassenger => role == 'PASSENGER';
}
