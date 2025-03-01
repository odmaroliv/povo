import 'package:get/get.dart';
import 'package:povo/app/controllers/camera_controller.dart';
import 'package:povo/app/data/repositories/photo_repository.dart';
import 'package:povo/app/services/auth_service.dart';
import 'package:povo/app/services/camera_service.dart';
import 'package:povo/app/services/firebase_service.dart';
import 'package:povo/app/services/storage_service.dart';

class CameraBinding extends Bindings {
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

    Get.put<CameraService>(CameraService());

    // Repositories
    Get.put<PhotoRepository>(PhotoRepository());

    // Controllers
    Get.put<CameraController>(CameraController());
  }
}
