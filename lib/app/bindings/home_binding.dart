import 'package:get/get.dart';
import 'package:povo/app/controllers/home_controller.dart';
import 'package:povo/app/data/repositories/event_repository.dart';
import 'package:povo/app/data/repositories/user_repository.dart';
import 'package:povo/app/services/auth_service.dart';
import 'package:povo/app/services/firebase_service.dart';
import 'package:povo/app/services/notification_service.dart';
import 'package:povo/app/services/storage_service.dart';

class HomeBinding extends Bindings {
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

    // Repositories
    Get.put<UserRepository>(UserRepository());
    Get.put<EventRepository>(EventRepository());

    // Controllers
    Get.put<HomeController>(HomeController());
  }
}
