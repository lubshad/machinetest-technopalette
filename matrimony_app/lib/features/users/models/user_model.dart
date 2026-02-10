import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../groups_and_permissions/models/group_model.dart';

class UserModel {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final bool isActive;
  final bool isStaff;
  final bool isSuperuser;
  final List<GroupModel> groups;
  final String? password; // Write-only often

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isActive,
    required this.isStaff,
    required this.isSuperuser,
    required this.groups,
    this.password,
  });

  String get fullName => "$firstName $lastName".trim();

  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    bool? isActive,
    bool? isStaff,
    bool? isSuperuser,
    List<GroupModel>? groups,
    String? password,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isActive: isActive ?? this.isActive,
      isStaff: isStaff ?? this.isStaff,
      isSuperuser: isSuperuser ?? this.isSuperuser,
      groups: groups ?? this.groups,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'is_active': isActive,
      'is_staff': isStaff,
      'is_superuser': isSuperuser,
      'groups': groups.map((x) => x.toMap()).toList(),
    };
  }

  Map<String, dynamic> toRequestMap() {
    final map = {
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'is_active': isActive,
      'is_staff': isStaff,
      'is_superuser': isSuperuser,
      'groups': groups.map((x) => x.id).toList(),
    };
    if (password != null && password!.isNotEmpty) {
      map['password'] = password!;
    }
    return map;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toInt() ?? 0,
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      isActive: map['is_active'] ?? true,
      isStaff: map['is_staff'] ?? false,
      isSuperuser: map['is_superuser'] ?? false,
      groups: List<GroupModel>.from(
        map['groups']?.map((x) => GroupModel.fromMap(x)) ?? const [],
      ),
    );
  }

  bool hasPermission(String codename) {
    if (isSuperuser) return true;
    for (final group in groups) {
      for (final permission in group.permissions) {
        if (permission.codename == codename) {
          return true;
        }
      }
    }
    return false;
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, email: $email, isActive: $isActive, groups: $groups)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.username == username &&
        other.email == email &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.isActive == isActive &&
        other.isStaff == isStaff &&
        other.isSuperuser == isSuperuser &&
        listEquals(other.groups, groups);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        email.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        isActive.hashCode ^
        isStaff.hashCode ^
        isSuperuser.hashCode ^
        groups.hashCode;
  }
}
