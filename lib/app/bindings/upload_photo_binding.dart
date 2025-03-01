import 'package:get/get.dart';
import 'package:povo/app/controllers/photo_upload_controller.dart';

class UploadPhotoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PhotoUploadController>(() => PhotoUploadController());
  }
}
