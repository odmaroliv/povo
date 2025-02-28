import 'package:get/get.dart';
import 'package:povo/app/core/routes/app_routes.dart';
import 'package:povo/app/data/models/event_model.dart';
import 'package:povo/app/data/models/user_model.dart';
import 'package:povo/app/data/repositories/event_repository.dart';
import 'package:povo/app/data/repositories/user_repository.dart';
import 'package:povo/app/services/auth_service.dart';

class HomeController extends GetxController {
  final EventRepository _eventRepository = Get.find<EventRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();
  final AuthService _authService = Get.find<AuthService>();

  // State variables
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt currentTabIndex = 0.obs;
  final RxString joinCode = ''.obs;

  // Data
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxList<EventModel> hostedEvents = <EventModel>[].obs;
  final RxList<EventModel> participatedEvents = <EventModel>[].obs;

  // Getters
  String get userId => _authService.userId!;

  @override
  void onInit() {
    super.onInit();
    loadUserAndEvents();
  }

  // Load user profile and events
  Future<void> loadUserAndEvents() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      // Load user profile
      final user = await _userRepository.getUser(userId);

      if (user != null) {
        currentUser.value = user;

        // Load hosted events
        final hosted = await _eventRepository.getHostedEvents(userId);
        hostedEvents.assignAll(hosted);

        // Load participated events
        final participated =
            await _eventRepository.getParticipatedEvents(userId);
        participatedEvents.assignAll(participated);
      } else {
        hasError.value = true;
        errorMessage.value = 'Error al cargar el perfil de usuario.';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error al cargar los datos. Intente nuevamente.';
      print('Error loading user and events: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Change current tab
  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  // Navigate to create event screen
  void goToCreateEvent() {
    Get.toNamed(AppRoutes.CREATE_EVENT);
  }

  // Navigate to event details
  void goToEventDetails(String eventId) {
    Get.toNamed(AppRoutes.EVENT_DETAILS, arguments: eventId);
  }

  // Navigate to camera screen
  void goToCamera(String eventId) {
    Get.toNamed(AppRoutes.CAMERA, arguments: eventId);
  }

  // Navigate to gallery
  void goToGallery(String eventId) {
    Get.toNamed(AppRoutes.GALLERY, arguments: eventId);
  }

  // Navigate to moderation screen
  void goToModeration(String eventId) {
    Get.toNamed(AppRoutes.MODERATION, arguments: eventId);
  }

  // Join event by code
  Future<void> joinEventByCode() async {
    if (joinCode.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Ingrese un código válido.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      final event = await _eventRepository.getEventByJoinCode(joinCode.value);

      if (event != null) {
        // Check if user is already a participant
        if (event.participantIds.contains(userId)) {
          Get.snackbar(
            'Información',
            'Ya eres participante de este evento',
            snackPosition: SnackPosition.BOTTOM,
          );

          // Navigate to event details
          Get.toNamed(AppRoutes.EVENT_DETAILS, arguments: event.id);
          return;
        }

        // Join the event
        await _eventRepository.joinEvent(event.id, userId);

        // Add to participated events
        participatedEvents.add(event);

        // Navigate to event details
        Get.toNamed(AppRoutes.EVENT_DETAILS, arguments: event.id);

        Get.snackbar(
          'Éxito',
          'Te has unido al evento "${event.name}"',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Código de evento inválido o evento inactivo',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al unirse al evento. Intente nuevamente.',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error joining event: $e');
    } finally {
      isLoading.value = false;
      joinCode.value = '';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadUserAndEvents();
  }

  // Check if event has pending photos to moderate
  bool hasEventPendingPhotos(String eventId) {
    // This would require checking the database for pending photos
    // For now, we'll assume all hosted events have pending photos
    final event = hostedEvents.firstWhereOrNull((e) => e.id == eventId);
    return event != null;
  }

  // Get hosted active events count
  int get activeHostedEventsCount =>
      hostedEvents.where((e) => e.status == 'active').length;

  // Get participated active events count
  int get activeParticipatedEventsCount =>
      participatedEvents.where((e) => e.status == 'active').length;
}
