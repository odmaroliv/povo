// app_constants.dart
class AppConstants {
  // App Info
  static const String appName = 'Povo';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String eventsCollection = 'events';
  static const String photosCollection = 'photos';

  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String eventCoversPath = 'event_covers';
  static const String photosPath = 'photos';
  static const String thumbnailsPath = 'thumbnails';

  // Photo Status
  static const String photoStatusPending = 'pending';
  static const String photoStatusApproved = 'approved';
  static const String photoStatusRejected = 'rejected';

  // Event Status
  static const String eventStatusActive = 'active';
  static const String eventStatusCompleted = 'completed';
  static const String eventStatusCancelled = 'cancelled';

  // Image Constants
  static const int maxImageSizeMB = 5;
  static const int thumbnailWidth = 300;
  static const int thumbnailHeight = 300;
  static const int imageQuality = 85;

  // Cache Settings
  static const Duration cacheDuration = Duration(days: 7);

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 350);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Deep Link Prefix
  static const String deepLinkPrefix = 'povo://';
  static const String joinEventDeepLink = 'povo://join';
}
