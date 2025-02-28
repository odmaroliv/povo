import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String name;
  final String hostId;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final String? coverImage;
  final String? locationName;
  final GeoPoint? locationCoordinates;
  final bool requiresModeration;
  final List<String> participantIds;
  final List<String> photoIds;
  final String status; // active, completed, cancelled
  final String joinCode;
  final DateTime createdAt;
  final Map<String, dynamic>? settings;

  EventModel({
    required this.id,
    required this.name,
    required this.hostId,
    this.description,
    required this.startDate,
    this.endDate,
    this.coverImage,
    this.locationName,
    this.locationCoordinates,
    this.requiresModeration = true,
    this.participantIds = const [],
    this.photoIds = const [],
    this.status = 'active',
    required this.joinCode,
    required this.createdAt,
    this.settings,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      name: json['name'] as String,
      hostId: json['hostId'] as String,
      description: json['description'] as String?,
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: json['endDate'] != null
          ? (json['endDate'] as Timestamp).toDate()
          : null,
      coverImage: json['coverImage'] as String?,
      locationName: json['locationName'] as String?,
      locationCoordinates: json['locationCoordinates'] as GeoPoint?,
      requiresModeration: json['requiresModeration'] as bool? ?? true,
      participantIds: List<String>.from(json['participantIds'] ?? []),
      photoIds: List<String>.from(json['photoIds'] ?? []),
      status: json['status'] as String? ?? 'active',
      joinCode: json['joinCode'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      settings: json['settings'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hostId': hostId,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'coverImage': coverImage,
      'locationName': locationName,
      'locationCoordinates': locationCoordinates,
      'requiresModeration': requiresModeration,
      'participantIds': participantIds,
      'photoIds': photoIds,
      'status': status,
      'joinCode': joinCode,
      'createdAt': Timestamp.fromDate(createdAt),
      'settings': settings,
    };
  }

  EventModel copyWith({
    String? id,
    String? name,
    String? hostId,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? coverImage,
    String? locationName,
    GeoPoint? locationCoordinates,
    bool? requiresModeration,
    List<String>? participantIds,
    List<String>? photoIds,
    String? status,
    String? joinCode,
    DateTime? createdAt,
    Map<String, dynamic>? settings,
  }) {
    return EventModel(
      id: id ?? this.id,
      name: name ?? this.name,
      hostId: hostId ?? this.hostId,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      coverImage: coverImage ?? this.coverImage,
      locationName: locationName ?? this.locationName,
      locationCoordinates: locationCoordinates ?? this.locationCoordinates,
      requiresModeration: requiresModeration ?? this.requiresModeration,
      participantIds: participantIds ?? this.participantIds,
      photoIds: photoIds ?? this.photoIds,
      status: status ?? this.status,
      joinCode: joinCode ?? this.joinCode,
      createdAt: createdAt ?? this.createdAt,
      settings: settings ?? this.settings,
    );
  }
}
