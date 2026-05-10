import 'dart:convert';

class ComplainModel {
  final String phoneNumber;
  final String description;
  final String employee;
  final String? id;
  final String? userId;

  ComplainModel({
    required this.phoneNumber,
    required this.description,
    required this.employee,
    this.id,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'phoneNumber': phoneNumber,
      'description': description,
      'employee': employee,
      'id': id,
      'userId': userId,
    };
  }

  factory ComplainModel.fromMap(Map<String, dynamic> map) {
    return ComplainModel(
      phoneNumber: map['phoneNumber'] ?? '',
      description: map['description'] ?? '',
      employee: map['employee'] ?? '',
      id: map['_id'] ?? '',
      userId: map['userId'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ComplainModel.fromJson(String source) =>
      ComplainModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
