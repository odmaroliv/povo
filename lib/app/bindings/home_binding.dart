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
      Get.putAsync<FirebaseService>(() => FirebaseService().init());
    }

    if (!Get.isRegistered<StorageService>()) {
      Get.putAsync<StorageService>(() => StorageService().init());
    }

    if (!Get.isRegistered<AuthService>()) {
      Get.putAsync<AuthService>(() => AuthService().init());
    }

    if (!Get.isRegistered<NotificationService>()) {
      Get.putAsync<NotificationService>(() => NotificationService().init());
    }

    // Repositories
    Get.lazyPut<UserRepository>(() => UserRepository());
    Get.lazyPut<EventRepository>(() => EventRepository());

    // Controllers
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
