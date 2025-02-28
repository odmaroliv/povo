import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? profileImage;
  final DateTime createdAt;
  final List<String> hostedEventIds;
  final List<String> participatedEventIds;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.profileImage,
    required this.createdAt,
    this.hostedEventIds = const [],
    this.participatedEventIds = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      profileImage: json['profileImage'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      hostedEventIds: List<String>.from(json['hostedEventIds'] ?? []),
      participatedEventIds:
          List<String>.from(json['participatedEventIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profileImage': profileImage,
      'createdAt': Timestamp.fromDate(createdAt),
      'hostedEventIds': hostedEventIds,
      'participatedEventIds': participatedEventIds,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImage,
    DateTime? createdAt,
    List<String>? hostedEventIds,
    List<String>? participatedEventIds,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      hostedEventIds: hostedEventIds ?? this.hostedEventIds,
      participatedEventIds: participatedEventIds ?? this.participatedEventIds,
    );
  }
}
