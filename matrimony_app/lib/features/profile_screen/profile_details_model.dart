import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:matrimony_app/extensions.dart';
import 'package:path/path.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first

/// Enum for gender choices
enum Gender {
  male('Male', 'Male'),
  female('Female', 'Female');

  final String value;
  final String label;

  const Gender(this.value, this.label);

  /// Get Gender from string value
  static Gender? fromValue(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return Gender.values.firstWhere((e) => e.value == value);
    } catch (e) {
      return null;
    }
  }

  /// Convert to JSON-serializable string
  String toJson() => value;
}

/// Enum for family type choices
enum FamilyType {
  nuclear('nuclear', 'Nuclear'),
  joint('joint', 'Joint');

  final String value;
  final String label;

  const FamilyType(this.value, this.label);

  /// Get FamilyType from string value
  static FamilyType? fromValue(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return FamilyType.values.firstWhere((e) => e.value == value);
    } catch (e) {
      return null;
    }
  }

  /// Convert to JSON-serializable string
  String toJson() => value;
}

/// Enum for family status choices
enum FamilyStatus {
  middleClass('middle_class', 'Middle Class'),
  upperMiddleClass('upper_middle_class', 'Upper Middle Class'),
  rich('rich', 'Rich');

  final String value;
  final String label;

  const FamilyStatus(this.value, this.label);

  /// Get FamilyStatus from string value
  static FamilyStatus? fromValue(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return FamilyStatus.values.firstWhere((e) => e.value == value);
    } catch (e) {
      return null;
    }
  }

  /// Convert to JSON-serializable string
  String toJson() => value;
}

class ProfileDetailsModel {
  final int userId;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? photo;
  final Gender? gender;
  final String? phoneNumber;
  final double? height;
  final double? weight;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? fatherName;
  final String? motherName;
  final int? siblings;
  final FamilyType? familyType;
  final FamilyStatus? familyStatus;
  final String? bio;
  final List<int>? interests;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final File? photoFile;

  ProfileDetailsModel({
    required this.userId,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.photo,
    this.gender,
    this.phoneNumber,
    this.height,
    this.weight,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.fatherName,
    this.motherName,
    this.siblings,
    this.familyType,
    this.familyStatus,
    this.bio,
    this.interests,
    this.createdAt,
    this.updatedAt,
    this.photoFile,
  });

  String get fullName => '$firstName $lastName'.trim();

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user': userId,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'photo': photo,
      'gender': gender?.value,
      'phone_number': phoneNumber,
      'height': height,
      'weight': weight,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'father_name': fatherName,
      'mother_name': motherName,
      'siblings': siblings,
      'family_type': familyType?.value,
      'family_status': familyStatus?.value,
      'bio': bio,
      'interests': interests,
    }..clearFields();
  }

  Future<FormData> get toFormData async {
    final map = <String, dynamic>{
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'gender': gender?.value,
      'phone_number': phoneNumber,
      'height': height,
      'weight': weight,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'father_name': fatherName,
      'mother_name': motherName,
      'siblings': siblings,
      'family_type': familyType?.value,
      'family_status': familyStatus?.value,
      'bio': bio,
    }..clearFields();

    // Handle photo upload if it's a local file path
    if (photoFile != null) {
      if (await photoFile!.exists()) {
        map['photo'] = await MultipartFile.fromFile(
          photoFile!.path,
          filename: basename(photoFile!.path),
        );
      }
    }

    return FormData.fromMap(map);
  }

  factory ProfileDetailsModel.fromMap(Map<String, dynamic> map) {
    return ProfileDetailsModel(
      userId: map['user'] as int,
      username: map['username'] as String? ?? '',
      email: map['email'] as String? ?? '',
      firstName: map['first_name'] as String? ?? '',
      lastName: map['last_name'] as String? ?? '',
      photo: map['photo'] as String?,
      gender: Gender.fromValue(map['gender'] as String?),
      phoneNumber: map['phone_number'] as String?,
      height: map['height'] != null
          ? double.tryParse(map['height'].toString())
          : null,
      weight: map['weight'] != null
          ? double.tryParse(map['weight'].toString())
          : null,
      addressLine1: map['address_line1'] as String?,
      addressLine2: map['address_line2'] as String?,
      city: map['city'] as String?,
      state: map['state'] as String?,
      country: map['country'] as String?,
      postalCode: map['postal_code'] as String?,
      fatherName: map['father_name'] as String?,
      motherName: map['mother_name'] as String?,
      siblings: map['siblings'] as int?,
      familyType: FamilyType.fromValue(map['family_type'] as String?),
      familyStatus: FamilyStatus.fromValue(map['family_status'] as String?),
      bio: map['bio'] as String?,
      interests: (map['interests'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProfileDetailsModel.fromJson(String source) =>
      ProfileDetailsModel.fromMap(json.decode(source) as Map<String, dynamic>);

  ProfileDetailsModel copyWith({
    int? userId,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? photo,
    Gender? gender,
    String? phoneNumber,
    double? height,
    double? weight,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? fatherName,
    String? motherName,
    int? siblings,
    FamilyType? familyType,
    FamilyStatus? familyStatus,
    String? bio,
    List<int>? interests,
    DateTime? createdAt,
    DateTime? updatedAt,
    File? photoFile,
  }) {
    return ProfileDetailsModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      photo: photo ?? this.photo,
      gender: gender ?? this.gender,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      fatherName: fatherName ?? this.fatherName,
      motherName: motherName ?? this.motherName,
      siblings: siblings ?? this.siblings,
      familyType: familyType ?? this.familyType,
      familyStatus: familyStatus ?? this.familyStatus,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      photoFile: photoFile ?? this.photoFile,
    );
  }
}
