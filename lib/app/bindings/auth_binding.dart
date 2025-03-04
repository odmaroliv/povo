import 'package:get/get.dart';
import 'package:povo/app/controllers/auth_controller.dart';
import 'package:povo/app/data/repositories/user_repository.dart';
import 'package:povo/app/services/auth_service.dart';
import 'package:povo/app/services/firebase_service.dart';
import 'package:povo/app/services/notification_service.dart';
import 'package:povo/app/services/storage_service.dart';
import 'package:povo/app/services/secured_storage_service.dart'; // Añadir esta importación

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Services - registro síncrono
    Get.put<FirebaseService>(FirebaseService());
    Get.put<StorageService>(StorageService());
    Get.put<AuthService>(AuthService());
    Get.put<NotificationService>(NotificationService());
    Get.put<SecuredStorageService>(SecuredStorageService());

    // Repositories
    Get.put<UserRepository>(UserRepository());

    // Controllers
    Get.put<AuthController>(AuthController());
  }
}
