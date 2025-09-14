import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String name;
  final String role; // student, organizer, admin
  final String? avatar;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isActive;
  final String? phone;
  final String? studentId;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.avatar,
    this.createdAt,
    this.updatedAt,
    this.isActive,
    this.phone,
    this.studentId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? phone,
    String? studentId,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      phone: phone ?? this.phone,
      studentId: studentId ?? this.studentId,
    );
  }
}
