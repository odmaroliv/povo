import 'package:get/get.dart';
import 'package:povo/app/data/models/event_model.dart';
import 'package:povo/app/data/models/photo_model.dart';
import 'package:povo/app/data/models/user_model.dart';
import 'package:povo/app/data/repositories/event_repository.dart';
import 'package:povo/app/data/repositories/photo_repository.dart';
import 'package:povo/app/data/repositories/user_repository.dart';
import 'package:povo/app/services/auth_service.dart';

class ModeratorController extends GetxController {
  final PhotoRepository _photoRepository = Get.find<PhotoRepository>();
  final EventRepository _eventRepository = Get.find<EventRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();
  final AuthService _authService = Get.find<AuthService>();

  // State variables
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString currentEventId = ''.obs;

  // Data
  final Rx<EventModel?> currentEvent = Rx<EventModel?>(null);
  final RxList<PhotoModel> pendingPhotos = <PhotoModel>[].obs;
  final RxList<PhotoModel> approvedPhotos = <PhotoModel>[].obs;
  final RxList<PhotoModel> rejectedPhotos = <PhotoModel>[].obs;
  final RxMap<String, UserModel> photoUserMap = <String, UserModel>{}.obs;

  // Getters
  String get userId => _authService.userId!;

  // Check if user is the event host
  bool isEventHost(String eventId) {
    return currentEvent.value?.hostId == userId;
  }

  @override
  void onInit() {
    super.onInit();

    // Extraer el eventId del mapa de argumentos
    if (Get.arguments != null) {
      String eventId;

      if (Get.arguments is Map) {
        // Si es un mapa, obtener el valor de 'eventId'
        eventId = Get.arguments['eventId'];
      } else if (Get.arguments is String) {
        // Para mantener compatibilidad por si antes se pasaba como String
        eventId = Get.arguments;
      } else {
        // Si no es ni un mapa ni un String, mostrar error
        hasError.value = true;
        errorMessage.value = 'Formato de argumentos no válido';
        return;
      }

      if (eventId != null) {
        loadData(eventId);
      } else {
        hasError.value = true;
        errorMessage.value = 'ID de evento no proporcionado';
      }
    } else {
      hasError.value = true;
      errorMessage.value = 'No se proporcionaron argumentos';
    }
  }

  void loadData(String eventId) {
    try {
      isLoading.value = true;
      hasError.value = false;

      // Resto de tu código para cargar datos...
      currentEventId.value = eventId;

      // Cargar el evento, fotos pendientes, etc.
    } catch (e) {
      print('Error loading moderation data: $e');
      hasError.value = true;
      errorMessage.value = 'Error al cargar los datos: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Load event and photos
  Future<void> loadEventAndPhotos() async {
    if (currentEventId.value.isEmpty) return;

    try {
      isLoading.value = true;
      hasError.value = false;

      // Load event details
      final event = await _eventRepository.getEvent(currentEventId.value);

      if (event != null) {
        currentEvent.value = event;

        // Check if user is host
        if (event.hostId != userId) {
          hasError.value = true;
          errorMessage.value = 'No tienes permisos para moderar este evento.';
          return;
        }

        // Load photos by status
        await Future.wait([
          _loadPendingPhotos(),
          _loadApprovedPhotos(),
          _loadRejectedPhotos(),
        ]);

        // Load user data for all photos
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

  // Load pending photos
  Future<void> _loadPendingPhotos() async {
    final photos = await _photoRepository.getEventPhotos(
      currentEventId.value,
      status: 'pending',
    );
    pendingPhotos.assignAll(photos);
  }

  // Load approved photos
  Future<void> _loadApprovedPhotos() async {
    final photos = await _photoRepository.getEventPhotos(
      currentEventId.value,
      status: 'approved',
    );
    approvedPhotos.assignAll(photos);
  }

  // Load rejected photos
  Future<void> _loadRejectedPhotos() async {
    final photos = await _photoRepository.getEventPhotos(
      currentEventId.value,
      status: 'rejected',
    );
    rejectedPhotos.assignAll(photos);
  }

  // Load user data for photos
  Future<void> _loadPhotoUsers() async {
    // Collect all user IDs from photos
    final Set<String> userIds = {};

    for (final photo in [
      ...pendingPhotos,
      ...approvedPhotos,
      ...rejectedPhotos
    ]) {
      userIds.add(photo.userId);
    }

    // Fetch user data
    if (userIds.isNotEmpty) {
      final users = await _userRepository.getUsersByIds(userIds.toList());

      // Create a map for easy access
      final Map<String, UserModel> userMap = {};
      for (final user in users) {
        userMap[user.id] = user;
      }

      photoUserMap.assignAll(userMap);
    }
  }

  // Approve a photo
  Future<void> approvePhoto(PhotoModel photo) async {
    try {
      isLoading.value = true;

      await _photoRepository.approvePhoto(photo.id);

      // Update local lists
      pendingPhotos.removeWhere((p) => p.id == photo.id);

      final updatedPhoto = photo.copyWith(status: 'approved');
      approvedPhotos.add(updatedPhoto);

      Get.snackbar(
        'Éxito',
        'Foto aprobada correctamente.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo aprobar la foto. Intente nuevamente.',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error approving photo: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Reject a photo
  Future<void> rejectPhoto(PhotoModel photo) async {
    try {
      isLoading.value = true;

      await _photoRepository.rejectPhoto(photo.id);

      // Update local lists
      pendingPhotos.removeWhere((p) => p.id == photo.id);

      final updatedPhoto = photo.copyWith(status: 'rejected');
      rejectedPhotos.add(updatedPhoto);

      Get.snackbar(
        'Información',
        'Foto rechazada.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo rechazar la foto. Intente nuevamente.',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error rejecting photo: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete a photo
  Future<void> deletePhoto(PhotoModel photo) async {
    try {
      isLoading.value = true;

      await _photoRepository.deletePhoto(photo.id);

      // Update local lists based on photo status
      switch (photo.status) {
        case 'pending':
          pendingPhotos.removeWhere((p) => p.id == photo.id);
          break;
        case 'approved':
          approvedPhotos.removeWhere((p) => p.id == photo.id);
          break;
        case 'rejected':
          rejectedPhotos.removeWhere((p) => p.id == photo.id);
          break;
      }

      Get.snackbar(
        'Éxito',
        'Foto eliminada permanentemente.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar la foto. Intente nuevamente.',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error deleting photo: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Approve all pending photos
  Future<void> approveAllPendingPhotos() async {
    try {
      isLoading.value = true;

      // Make a copy to avoid modification during iteration
      final photosToApprove = List<PhotoModel>.from(pendingPhotos);

      for (final photo in photosToApprove) {
        await _photoRepository.approvePhoto(photo.id);

        // Update local lists
        pendingPhotos.removeWhere((p) => p.id == photo.id);
        approvedPhotos.add(photo.copyWith(status: 'approved'));
      }

      Get.snackbar(
        'Éxito',
        'Todas las fotos pendientes han sido aprobadas.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Ocurrió un error al aprobar las fotos. Algunas pueden no haberse aprobado.',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error approving all photos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle moderation requirement for the event
  Future<void> toggleModeration() async {
    if (currentEvent.value == null) return;

    try {
      isLoading.value = true;

      final updatedEvent = currentEvent.value!.copyWith(
        requiresModeration: !currentEvent.value!.requiresModeration,
      );

      await _eventRepository.updateEvent(updatedEvent);

      currentEvent.value = updatedEvent;

      final status =
          updatedEvent.requiresModeration ? 'activada' : 'desactivada';

      Get.snackbar(
        'Éxito',
        'Moderación $status correctamente.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo cambiar la configuración de moderación.',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error toggling moderation: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Get user name for a photo
  String getUserName(String userId) {
    return photoUserMap[userId]?.name ?? 'Usuario';
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadEventAndPhotos();
  }
}
