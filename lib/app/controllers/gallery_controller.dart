import 'package:get/get.dart';
import 'package:povo/app/data/models/event_model.dart';
import 'package:povo/app/data/models/photo_model.dart';
import 'package:povo/app/data/models/user_model.dart';
import 'package:povo/app/data/repositories/event_repository.dart';
import 'package:povo/app/data/repositories/photo_repository.dart';
import 'package:povo/app/data/repositories/user_repository.dart';
import 'package:povo/app/services/auth_service.dart';

class GalleryController extends GetxController {
  final PhotoRepository _photoRepository = Get.find<PhotoRepository>();
  final EventRepository _eventRepository = Get.find<EventRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();
  final AuthService _authService = Get.find<AuthService>();

  // State variables
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString currentEventId = ''.obs;
  final RxInt currentPhotoIndex = 0.obs;

  // Data
  final Rx<EventModel?> currentEvent = Rx<EventModel?>(null);
  final RxList<PhotoModel> photos = <PhotoModel>[].obs;
  final RxMap<String, UserModel> userMap = <String, UserModel>{}.obs;

  // Getters
  String get userId => _authService.userId!;

  @override
  void onInit() {
    super.onInit();
    // Get event ID from arguments if available
    if (Get.arguments != null) {
      currentEventId.value = Get.arguments as String;
      loadEventAndPhotos();
    }
  }

  // Load event and approved photos
  Future<void> loadEventAndPhotos() async {
    if (currentEventId.value.isEmpty) return;

    try {
      isLoading.value = true;
      hasError.value = false;

      // Load event details
      final event = await _eventRepository.getEvent(currentEventId.value);

      if (event != null) {
        currentEvent.value = event;

        // Load approved photos
        await _loadApprovedPhotos();

        // Load user data for photos
        await _loadPhotoUsers();
      } else {
        hasError.value = true;
        errorMessage.value = 'Evento no encontrado.';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error al cargar los datos. Intente nuevamente.';
      print('Error loading event and photos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load approved photos
  Future<void> _loadApprovedPhotos() async {
    final eventPhotos = await _photoRepository.getEventPhotos(
      currentEventId.value,
      status: 'approved',
    );
    photos.assignAll(eventPhotos);
  }

  // Load user data for photos
  Future<void> _loadPhotoUsers() async {
    // Collect all user IDs from photos
    final Set<String> userIds = {};

    for (final photo in photos) {
      userIds.add(photo.userId);
    }

    // Fetch user data
    if (userIds.isNotEmpty) {
      final users = await _userRepository.getUsersByIds(userIds.toList());

      // Create a map for easy access
      final Map<String, UserModel> map = {};
      for (final user in users) {
        map[user.id] = user;
      }

      userMap.assignAll(map);
    }
  }

  // Set current photo index
  void setCurrentPhotoIndex(int index) {
    if (index >= 0 && index < photos.length) {
      currentPhotoIndex.value = index;
    }
  }

  // Get next photo
  void nextPhoto() {
    if (currentPhotoIndex.value < photos.length - 1) {
      currentPhotoIndex.value++;
    }
  }

  // Get previous photo
  void previousPhoto() {
    if (currentPhotoIndex.value > 0) {
      currentPhotoIndex.value--;
    }
  }

  // Like a photo
  Future<void> likePhoto(String photoId) async {
    try {
      final index = photos.indexWhere((photo) => photo.id == photoId);

      if (index != -1) {
        final photo = photos[index];

        // Check if already liked
        if (photo.likedByUserIds.contains(userId)) {
          return;
        }

        await _photoRepository.likePhoto(photoId, userId);

        // Update local photo
        final updatedPhoto = photo.copyWith(
          likedByUserIds: [...photo.likedByUserIds, userId],
        );

        photos[index] = updatedPhoto;
      }
    } catch (e) {
      print('Error liking photo: $e');
    }
  }

  // Unlike a photo
  Future<void> unlikePhoto(String photoId) async {
    try {
      final index = photos.indexWhere((photo) => photo.id == photoId);

      if (index != -1) {
        final photo = photos[index];

        // Check if not liked
        if (!photo.likedByUserIds.contains(userId)) {
          return;
        }

        await _photoRepository.unlikePhoto(photoId, userId);

        // Update local photo
        final updatedPhoto = photo.copyWith(
          likedByUserIds:
              photo.likedByUserIds.where((id) => id != userId).toList(),
        );

        photos[index] = updatedPhoto;
      }
    } catch (e) {
      print('Error unliking photo: $e');
    }
  }

  // Check if current user liked a photo
  bool isPhotoLiked(String photoId) {
    final index = photos.indexWhere((photo) => photo.id == photoId);

    if (index != -1) {
      return photos[index].likedByUserIds.contains(userId);
    }

    return false;
  }

  // Get likes count for a photo
  int getLikesCount(String photoId) {
    final index = photos.indexWhere((photo) => photo.id == photoId);

    if (index != -1) {
      return photos[index].likedByUserIds.length;
    }

    return 0;
  }

  // Get user name for a photo
  String getUserName(String userId) {
    return userMap[userId]?.name ?? 'Usuario';
  }

  // Share a photo
  Future<void> sharePhoto(String photoUrl) async {
    try {
      // This would be implemented using the share_plus package
      // to share the photo URL or download and share the image
      print('Sharing photo: $photoUrl');

      Get.snackbar(
        'Compartiendo',
        'Compartiendo la foto...',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo compartir la foto. Intente nuevamente.',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error sharing photo: $e');
    }
  }

  // Download a photo
  Future<void> downloadPhoto(String photoUrl) async {
    try {
      // This would be implemented using platform channels or plugins
      // to save the image to the gallery
      print('Downloading photo: $photoUrl');

      Get.snackbar(
        'Descargando',
        'Guardando foto en la galería...',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo guardar la foto. Intente nuevamente.',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error downloading photo: $e');
    }
  }

  // Refresh gallery
  Future<void> refreshGallery() async {
    await loadEventAndPhotos();
  }
}
