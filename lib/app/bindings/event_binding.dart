import 'package:get/get.dart';
import 'package:povo/app/controllers/event_controller.dart';
import 'package:povo/app/controllers/gallery_controller.dart';
import 'package:povo/app/data/repositories/event_repository.dart';
import 'package:povo/app/data/repositories/photo_repository.dart';
import 'package:povo/app/data/repositories/user_repository.dart';
import 'package:povo/app/services/auth_service.dart';
import 'package:povo/app/services/camera_service.dart';
import 'package:povo/app/services/firebase_service.dart';
import 'package:povo/app/services/notification_service.dart';
import 'package:povo/app/services/storage_service.dart';

class EventBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    if (!Get.isRegistered<FirebaseService>()) {
      Get.put<FirebaseService>(FirebaseService());
    }

    if (!Get.isRegistered<StorageService>()) {
      Get.put<StorageService>(StorageService());
    }

    if (!Get.isRegistered<AuthService>()) {
      Get.put<AuthService>(AuthService());
    }

    if (!Get.isRegistered<NotificationService>()) {
      Get.put<NotificationService>(NotificationService());
    }
    // Añadir CameraService
    if (!Get.isRegistered<CameraService>()) {
      Get.put<CameraService>(CameraService());
    }

    // Repositories
    Get.put<UserRepository>(UserRepository());
    Get.put<EventRepository>(EventRepository());
    Get.put<PhotoRepository>(PhotoRepository());

    // Controllers
    Get.put<EventController>(EventController());
    Get.put<GalleryController>(GalleryController());
  }
}
