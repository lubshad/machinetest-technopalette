import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'permission_model.dart';

class GroupModel {
  final int id;
  final String name;
  final List<PermissionModel> permissions;

  GroupModel({required this.id, required this.name, required this.permissions});

  GroupModel copyWith({
    int? id,
    String? name,
    List<PermissionModel>? permissions,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      permissions: permissions ?? this.permissions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'permissions': permissions.map((x) => x.toMap()).toList(),
    };
  }

  /// Map for creating/updating where permissions are IDs
  Map<String, dynamic> toRequestMap() {
    return {'name': name, 'permissions': permissions.map((x) => x.id).toList()};
  }

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      permissions: List<PermissionModel>.from(
        map['permissions']?.map((x) => PermissionModel.fromMap(x)) ?? const [],
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory GroupModel.fromJson(String source) =>
      GroupModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'GroupModel(id: $id, name: $name, permissions: $permissions)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GroupModel &&
        other.id == id &&
        other.name == name &&
        listEquals(other.permissions, permissions);
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ permissions.hashCode;
}
