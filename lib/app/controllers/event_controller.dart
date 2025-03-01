import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:povo/app/core/routes/app_routes.dart';
import 'package:povo/app/data/models/event_model.dart';
import 'package:povo/app/data/repositories/event_repository.dart';
import 'package:povo/app/services/auth_service.dart';
import 'package:povo/app/services/notification_service.dart';

class EventController extends GetxController {
  final EventRepository _eventRepository = Get.find<EventRepository>();
  final AuthService _authService = Get.find<AuthService>();
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  // State variables
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final RxBool requiresModeration = true.obs;
  final Rx<File?> coverImage = Rx<File?>(null);
  final RxString joinCode = ''.obs;

  // Current event
  final Rx<EventModel?> currentEvent = Rx<EventModel?>(null);

  // Events lists
  final RxList<EventModel> hostedEvents = <EventModel>[].obs;
  final RxList<EventModel> participatedEvents = <EventModel>[].obs;

  // Getters
  String get userId => _authService.userId!;
  String get formattedStartDate =>
      DateFormat('dd/MM/yyyy').format(startDate.value);
  String get formattedEndDate => endDate.value != null
      ? DateFormat('dd/MM/yyyy').format(endDate.value!)
      : 'No definida';

  @override
  void onInit() {
    super.onInit();
    fetchUserEvents();
  }

  // Fetch all events for the current user
  Future<void> fetchUserEvents() async {
    if (_authService.userId == null) return;

    try {
      isLoading.value = true;

      // Get hosted events
      final hosted =
          await _eventRepository.getHostedEvents(_authService.userId!);
      hostedEvents.assignAll(hosted);

      // Get participated events
      final participated =
          await _eventRepository.getParticipatedEvents(_authService.userId!);
      participatedEvents.assignAll(participated);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error al cargar los eventos. Intente nuevamente.';
      print('Error fetching user events: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleModeration(String eventId) async {
    try {
      isLoading.value = true;
      // Invierte el estado de la moderación
      bool newModeration = !requiresModeration.value;

      // Actualiza el estado de moderación en el repositorio (asegúrate de que este método exista o créalo)
      await _eventRepository.updateEventModeration(eventId, newModeration);

      // Actualiza el valor local
      requiresModeration.value = newModeration;

      // Si el evento actual está cargado, actualiza su propiedad también
      if (currentEvent.value != null) {
        currentEvent.value =
            currentEvent.value!.copyWith(requiresModeration: newModeration);
      }

      Get.snackbar(
        'Éxito',
        newModeration ? 'Moderación activada' : 'Moderación desactivada',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar la moderación',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error updating moderation: $e');
    } finally {
      isLoading.value = false;
    }
  }

// Navegar a la pantalla de cámara
  void goToCamera(String eventId) {
    Get.toNamed(AppRoutes.CAMERA, arguments: {'eventId': eventId});
  }

// Navegar a la pantalla de galería
  void goToGallery(String eventId) {
    Get.toNamed(AppRoutes.GALLERY, arguments: {'eventId': eventId});
  }

// Navegar a la pantalla de moderación
  void goToModeration(String eventId) {
    Get.toNamed(AppRoutes.MODERATION, arguments: {'eventId': eventId});
  }

  // Create a new event
  Future<void> createEvent() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      // Validate required fields
      if (nameController.text.isEmpty) {
        hasError.value = true;
        errorMessage.value = 'Nombre del evento es requerido';
        return;
      }

      // Create the event
      final event = await _eventRepository.createEvent(
        name: nameController.text.trim(),
        hostId: userId,
        description: descriptionController.text.trim(),
        startDate: startDate.value,
        endDate: endDate.value,
        coverImagePath: coverImage.value?.path,
        locationName: locationController.text.trim(),
        requiresModeration: requiresModeration.value,
      );

      // Set current event and join code
      currentEvent.value = event;
      joinCode.value = event.joinCode;

      // Add to hosted events
      hostedEvents.add(event);

      // Subscribe to event notifications
      await _notificationService.subscribeToEvent(event.id);

      // Clear form
      _clearEventForm();

      // Navigate to event details
      Get.offNamed(AppRoutes.EVENT_DETAILS, arguments: event.id);

      Get.snackbar(
        'Éxito',
        'El evento se ha creado correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error al crear el evento. Intente nuevamente.';
      print('Error creating event: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load event details
  Future<void> loadEvent(String eventId) async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final event = await _eventRepository.getEvent(eventId);

      if (event != null) {
        currentEvent.value = event;
        joinCode.value = event.joinCode;

        // Subscribe to event notifications
        await _notificationService.subscribeToEvent(event.id);
      } else {
        hasError.value = true;
        errorMessage.value = 'Evento no encontrado';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error al cargar el evento. Intente nuevamente.';
      print('Error loading event: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Join an event by code
  Future<void> joinEventByCode(String code) async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final event = await _eventRepository.getEventByJoinCode(code);

      if (event != null) {
        // Check if user is already a participant
        if (event.participantIds.contains(userId)) {
          Get.snackbar(
            'Información',
            'Ya eres participante de este evento',
            snackPosition: SnackPosition.BOTTOM,
          );

          // Navigate to event details
          Get.offNamed(AppRoutes.EVENT_DETAILS, arguments: event.id);
          return;
        }

        // Join the event
        await _eventRepository.joinEvent(event.id, userId);

        // Subscribe to event notifications
        await _notificationService.subscribeToEvent(event.id);

        // Add to participated events
        participatedEvents.add(event);

        // Navigate to event details
        Get.offNamed(AppRoutes.EVENT_DETAILS, arguments: event.id);

        Get.snackbar(
          'Éxito',
          'Te has unido al evento "${event.name}"',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        hasError.value = true;
        errorMessage.value = 'Código de evento inválido o evento inactivo';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error al unirse al evento. Intente nuevamente.';
      print('Error joining event: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Leave an event
  Future<void> leaveEvent(String eventId) async {
    try {
      isLoading.value = true;

      await _eventRepository.leaveEvent(eventId, userId);

      // Unsubscribe from event notifications
      await _notificationService.unsubscribeFromEvent(eventId);

      // Remove from participated events
      participatedEvents.removeWhere((event) => event.id == eventId);

      Get.offNamed(AppRoutes.HOME);

      Get.snackbar(
        'Éxito',
        'Has salido del evento',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo salir del evento. Intente nuevamente.',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error leaving event: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete an event
  Future<void> deleteEvent(String eventId) async {
    try {
      isLoading.value = true;

      await _eventRepository.deleteEvent(eventId, userId);

      // Unsubscribe from event notifications
      await _notificationService.unsubscribeFromEvent(eventId);

      // Remove from hosted events
      hostedEvents.removeWhere((event) => event.id == eventId);

      Get.offNamed(AppRoutes.HOME);

      Get.snackbar(
        'Éxito',
        'El evento ha sido eliminado',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar el evento. Intente nuevamente.',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error deleting event: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Regenerate join code
  Future<void> regenerateJoinCode(String eventId) async {
    try {
      isLoading.value = true;

      final newCode = await _eventRepository.regenerateJoinCode(eventId);
      joinCode.value = newCode;

      // Update current event
      if (currentEvent.value != null) {
        currentEvent.value = currentEvent.value!.copyWith(joinCode: newCode);
      }

      Get.snackbar(
        'Éxito',
        'Se ha generado un nuevo código de acceso',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo generar un nuevo código. Intente nuevamente.',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error regenerating join code: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Set start date
  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != startDate.value) {
      startDate.value = picked;

      // If end date is before start date, clear end date
      if (endDate.value != null && endDate.value!.isBefore(picked)) {
        endDate.value = null;
      }
    }
  }

  // Set end date
  Future<void> selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          endDate.value ?? startDate.value.add(const Duration(days: 1)),
      firstDate: startDate.value,
      lastDate: startDate.value.add(const Duration(days: 365)),
    );

    if (picked != null) {
      endDate.value = picked;
    }
  }

  // Pick cover image
  Future<void> pickCoverImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        coverImage.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo seleccionar la imagen. Intente nuevamente.',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error picking image: $e');
    }
  }

  // Navegar a la pantalla de subida de fotos
  void goToUploadPhoto(String eventId) {
    Get.toNamed(AppRoutes.UPLOAD_PHOTO, arguments: {'eventId': eventId});
  }

  // Clear event form
  void _clearEventForm() {
    nameController.clear();
    descriptionController.clear();
    locationController.clear();
    startDate.value = DateTime.now();
    endDate.value = null;
    requiresModeration.value = true;
    coverImage.value = null;
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.onClose();
  }
}
