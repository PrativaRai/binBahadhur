// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class User {
  final String id;
  final String phone;
  final String password;
  final String name;
  final String token;
  final String type;
  final int points; // 1. Added points field

  User({
    required this.id,
    required this.phone,
    required this.password,
    required this.name,
    required this.type,
    required this.token,
    required this.points, // 2. Added to constructor
  });

  // A handy empty/initial constructor for setting up default states in your Provider
  factory User.empty() {
    return User(
      id: '',
      phone: '',
      password: '',
      name: '',
      type: '',
      token: '',
      points: 0,
    );
  }

  bool get isAdmin => type == 'admin';
  bool get isUser => type == 'user';
  bool get isEmployee => type == 'employee';
  bool get isProvider => type == 'user_provider';

  // 3. Updated copyWith to handle points modification
  User copyWith({
    String? id,
    String? phone,
    String? password,
    String? name,
    String? token,
    String? type,
    int? points,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      name: name ?? this.name,
      token: token ?? this.token,
      type: type ?? this.type,
      points: points ?? this.points,
    );
  }

  // 4. Added points map entry for backend updates
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'phone': phone,
      'password': password,
      'name': name,
      'type': type,
      'token': token,
      'points': points,
    };
  }

  // 5. Safely parse points from your API payload
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: (map['_id'] ?? map['id'] ?? '') as String,
      phone: (map['phone'] ?? '') as String,
      password: (map['password'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      type: (map['type'] ?? '') as String,
      token: (map['token'] ?? '') as String,
      points: (map['points'] ?? 0) as int, // Catches JSON integers cleanly
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);
}
