import 'package:get/get.dart';
import 'package:povo/app/bindings/auth_binding.dart';
import 'package:povo/app/bindings/camera_binding.dart';
import 'package:povo/app/bindings/event_binding.dart';
import 'package:povo/app/bindings/home_binding.dart';
import 'package:povo/app/bindings/moderator_binding.dart';
import 'package:povo/app/bindings/upload_photo_binding.dart';
import 'package:povo/app/core/routes/app_routes.dart';
import 'package:povo/app/ui/screens/auth/login_screen.dart';
import 'package:povo/app/ui/screens/auth/signup_screen.dart';
import 'package:povo/app/ui/screens/camera/camera_screen.dart';
import 'package:povo/app/ui/screens/camera/photo_preview_screen.dart';
import 'package:povo/app/ui/screens/camera/upload_photo_screen.dart';
import 'package:povo/app/ui/screens/event/create_event_screen.dart';
import 'package:povo/app/ui/screens/event/event_details_screen.dart';
import 'package:povo/app/ui/screens/event/join_event_screen.dart';
import 'package:povo/app/ui/screens/event/qr_generator_screen.dart';
import 'package:povo/app/ui/screens/gallery/gallery_screen.dart';
import 'package:povo/app/ui/screens/home/home_screen.dart';
import 'package:povo/app/ui/screens/moderation/moderation_screen.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.SIGNUP,
      page: () => SignupScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.CREATE_EVENT,
      page: () => CreateEventScreen(),
      binding: EventBinding(),
    ),
    GetPage(
      name: AppRoutes.EVENT_DETAILS,
      page: () => EventDetailsScreen(),
      binding: EventBinding(),
    ),
    GetPage(
      name: AppRoutes.JOIN_EVENT,
      page: () => JoinEventScreen(),
      binding: EventBinding(),
    ),
    GetPage(
      name: AppRoutes.QR_GENERATOR,
      page: () => QRGeneratorScreen(),
      binding: EventBinding(),
    ),
    GetPage(
      name: AppRoutes.CAMERA,
      page: () => CameraScreen(),
      binding: CameraBinding(),
    ),
    GetPage(
      name: AppRoutes.PHOTO_PREVIEW,
      page: () => PhotoPreviewScreen(),
      binding: CameraBinding(),
    ),
    GetPage(
      name: AppRoutes.GALLERY,
      page: () => GalleryScreen(),
      binding: EventBinding(),
    ),
    GetPage(
      name: AppRoutes.MODERATION,
      page: () => ModerationScreen(),
      binding: ModeratorBinding(),
    ),
    GetPage(
      name: AppRoutes.UPLOAD_PHOTO,
      page: () => UploadPhotoScreen(),
      binding: UploadPhotoBinding(),
    ),
  ];
}
