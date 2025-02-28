import 'package:cloud_firestore/cloud_firestore.dart';

class PhotoModel {
  final String id;
  final String eventId;
  final String userId;
  final String url;
  final String thumbnailUrl;
  final String status; // pending, approved, rejected
  final DateTime capturedAt;
  final DateTime uploadedAt;
  final String? caption;
  final List<String> tags;
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? filter;
  final List<String> likedByUserIds;

  PhotoModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.url,
    required this.thumbnailUrl,
    this.status = 'pending',
    required this.capturedAt,
    required this.uploadedAt,
    this.caption,
    this.tags = const [],
    this.metadata,
    this.filter,
    this.likedByUserIds = const [],
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      userId: json['userId'] as String,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      status: json['status'] as String? ?? 'pending',
      capturedAt: (json['capturedAt'] as Timestamp).toDate(),
      uploadedAt: (json['uploadedAt'] as Timestamp).toDate(),
      caption: json['caption'] as String?,
      tags: List<String>.from(json['tags'] ?? []),
      metadata: json['metadata'] as Map<String, dynamic>?,
      filter: json['filter'] as Map<String, dynamic>?,
      likedByUserIds: List<String>.from(json['likedByUserIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'status': status,
      'capturedAt': Timestamp.fromDate(capturedAt),
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'caption': caption,
      'tags': tags,
      'metadata': metadata,
      'filter': filter,
      'likedByUserIds': likedByUserIds,
    };
  }

  PhotoModel copyWith({
    String? id,
    String? eventId,
    String? userId,
    String? url,
    String? thumbnailUrl,
    String? status,
    DateTime? capturedAt,
    DateTime? uploadedAt,
    String? caption,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? filter,
    List<String>? likedByUserIds,
  }) {
    return PhotoModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      status: status ?? this.status,
      capturedAt: capturedAt ?? this.capturedAt,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      caption: caption ?? this.caption,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      filter: filter ?? this.filter,
      likedByUserIds: likedByUserIds ?? this.likedByUserIds,
    );
  }
}
