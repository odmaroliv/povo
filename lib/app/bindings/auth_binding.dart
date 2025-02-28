import 'package:get/get.dart';
import 'package:povo/app/controllers/auth_controller.dart';
import 'package:povo/app/data/repositories/user_repository.dart';
import 'package:povo/app/services/auth_service.dart';
import 'package:povo/app/services/firebase_service.dart';
import 'package:povo/app/services/notification_service.dart';
import 'package:povo/app/services/storage_service.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.putAsync<FirebaseService>(() => FirebaseService().init());
    Get.putAsync<StorageService>(() => StorageService().init());
    Get.putAsync<AuthService>(() => AuthService().init());
    Get.putAsync<NotificationService>(() => NotificationService().init());

    // Repositories
    Get.lazyPut<UserRepository>(() => UserRepository());

    // Controllers
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
