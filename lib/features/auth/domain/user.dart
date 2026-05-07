// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class User {
  final String id;
  final String phone;
  final String password;
  final String name;
  final String token;
  final String type;

  User({
    required this.id,
    required this.phone,
    required this.password,
    required this.name,
    required this.type,
    required this.token,
  });

  bool get isAdmin => type == 'admin';
  bool get isUser => type == 'user';
  bool get isEmployee => type == 'employee';
  bool get isProvider => type == 'user_provider';

  User copyWith({
    String? id,
    String? phone,
    String? password,
    String? name,
    String? token,
    String? type,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      name: name ?? this.name,
      token: token ?? this.token,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'phone': phone,
      'password': password,
      'name': name,
      'type': type,
      'token': token,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: (map['_id'] ?? map['id'] ?? '') as String,
      phone: (map['phone'] ?? '') as String,
      password: (map['password'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      type: (map['type'] ?? '') as String,
      token: (map['token'] ?? '') as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);
}
