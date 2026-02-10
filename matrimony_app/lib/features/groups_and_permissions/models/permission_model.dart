import 'dart:convert';

class PermissionModel {
  final int id;
  final String name;
  final int contentType;
  final String codename;
  final String modelName;

  PermissionModel({
    required this.id,
    required this.name,
    required this.contentType,
    required this.codename,
    required this.modelName,
  });

  PermissionModel copyWith({
    int? id,
    String? name,
    int? contentType,
    String? codename,
    String? modelName,
  }) {
    return PermissionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      contentType: contentType ?? this.contentType,
      codename: codename ?? this.codename,
      modelName: modelName ?? this.modelName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'content_type': contentType,
      'codename': codename,
      'model_name': modelName,
    };
  }

  factory PermissionModel.fromMap(Map<String, dynamic> map) {
    return PermissionModel(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      contentType: map['content_type']?.toInt() ?? 0,
      codename: map['codename'] ?? '',
      modelName: map['model_name'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory PermissionModel.fromJson(String source) =>
      PermissionModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PermissionModel(id: $id, name: $name, contentType: $contentType, codename: $codename, modelName: $modelName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PermissionModel &&
        other.id == id &&
        other.name == name &&
        other.contentType == contentType &&
        other.codename == codename &&
        other.modelName == modelName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        contentType.hashCode ^
        codename.hashCode ^
        modelName.hashCode;
  }
}
