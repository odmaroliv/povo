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
      Get.putAsync<FirebaseService>(() => FirebaseService().init());
    }

    if (!Get.isRegistered<StorageService>()) {
      Get.putAsync<StorageService>(() => StorageService().init());
    }

    if (!Get.isRegistered<AuthService>()) {
      Get.putAsync<AuthService>(() => AuthService().init());
    }

    Get.putAsync<CameraService>(() => CameraService().init());

    // Repositories
    Get.lazyPut<PhotoRepository>(() => PhotoRepository());

    // Controllers
    Get.lazyPut<CameraController>(() => CameraController());
  }
}
