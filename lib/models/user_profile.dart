import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UserProfileModel {
  final int id;
  final String name;
  final String email;
  final String? role;
  final String status;
  final DateTime? emailVerifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserDetailModel? detail;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    required this.status,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.detail,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) => _$UserProfileModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileModelToJson(this);

  // Convenience getters
  String get displayName => name;
  String get initials => name.isNotEmpty ? name.split(' ').map((n) => n[0]).take(2).join().toUpperCase() : 'U';
  bool get isEmailVerified => emailVerifiedAt != null;
  String get formattedJoinDate => createdAt?.toIso8601String().split('T')[0] ?? '';
  
  // Role helpers
  bool get isStudent => (role ?? 'student') == 'student';
  bool get isOrganizer => role == 'organizer';
  bool get isAdmin => role == 'admin' || role == 'super_admin' || role == 'staff_admin';
  
  // Status helpers
  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';
  bool get isSuspended => status == 'suspended';

  UserProfileModel copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? status,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserDetailModel? detail,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      detail: detail ?? this.detail,
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UserDetailModel {
  final int? id;
  final int? userId;
  final int? departmentId;
  final String? studentCode;
  final String? phone;
  final DateTime? dob;
  final String? gender;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserDetailModel({
    this.id,
    this.userId,
    this.departmentId,
    this.studentCode,
    this.phone,
    this.dob,
    this.gender,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory UserDetailModel.fromJson(Map<String, dynamic> json) => _$UserDetailModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserDetailModelToJson(this);

  // Convenience getters
  String get formattedDob => dob?.toIso8601String().split('T')[0] ?? '';
  String get genderDisplay => gender?.toUpperCase() ?? '';
  String get phoneDisplay => phone ?? '';
  String get studentCodeDisplay => studentCode ?? '';
  
  // Gender helpers
  bool get isMale => gender?.toLowerCase() == 'male';
  bool get isFemale => gender?.toLowerCase() == 'female';
  bool get isOther => gender?.toLowerCase() == 'other';

  UserDetailModel copyWith({
    int? id,
    int? userId,
    int? departmentId,
    String? studentCode,
    String? phone,
    DateTime? dob,
    String? gender,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserDetailModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      departmentId: departmentId ?? this.departmentId,
      studentCode: studentCode ?? this.studentCode,
      phone: phone ?? this.phone,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
