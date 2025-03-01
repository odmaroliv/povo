// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:povo/app/core/routes/app_routes.dart';
// import 'package:video_player/video_player.dart';
// import 'package:povo/app/controllers/camera_controller.dart';
// import 'package:povo/app/core/constants/color_constants.dart';
// import 'package:povo/app/ui/widgets/common/loading_widget.dart';

// class VideoPreviewScreen extends StatefulWidget {
//   const VideoPreviewScreen({Key? key}) : super(key: key);

//   @override
//   State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
// }

// class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
//   VideoPlayerController? _videoPlayerController = null;
//   final RxBool _isInitialized = false.obs;
//   final RxBool _isPlaying = false.obs;
//   final controller = Get.find<CameraController>();

//   @override
//   Widget build(BuildContext context) {
//     // Initialize the video player when the screen is first built
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeVideoPlayer();
//     });

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Obx(() {
//           if (controller.capturedVideoPath.value.isEmpty) {
//             return const Center(
//               child: Text(
//                 'No video to display',
//                 style: TextStyle(color: Colors.white),
//               ),
//             );
//           }

//           return Stack(
//             children: [
//               // Video Preview
//               Positioned.fill(
//                 child: _buildVideoPreview(),
//               ),

//               // Top Bar with Close Button
//               Positioned(
//                 top: 16,
//                 left: 16,
//                 right: 16,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     IconButton(
//                       icon: const Icon(
//                         Icons.close,
//                         color: Colors.white,
//                         size: 30,
//                       ),
//                       onPressed: () {
//                         _disposeVideoPlayer();
//                         controller.discardVideo();
//                       },
//                     ),
//                   ],
//                 ),
//               ),

//               // Bottom Controls (Use Video, Retake)
//               Positioned(
//                 bottom: 0,
//                 left: 0,
//                 right: 0,
//                 child: Container(
//                   padding: const EdgeInsets.all(24),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.bottomCenter,
//                       end: Alignment.topCenter,
//                       colors: [
//                         Colors.black.withOpacity(0.7),
//                         Colors.transparent,
//                       ],
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       // Video Player Controls
//                       if (_isInitialized.value)
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             IconButton(
//                               icon: Icon(
//                                 _isPlaying.value
//                                     ? Icons.pause
//                                     : Icons.play_arrow,
//                                 color: Colors.white,
//                                 size: 36,
//                               ),
//                               onPressed: _togglePlayPause,
//                             ),
//                           ],
//                         ),

//                       const SizedBox(height: 16),

//                       // Caption Text Field
//                       TextField(
//                         controller: controller.captionController,
//                         style: const TextStyle(color: Colors.white),
//                         decoration: InputDecoration(
//                           hintText: 'Add a description... (optional)',
//                           hintStyle:
//                               TextStyle(color: Colors.white.withOpacity(0.7)),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(
//                                 color: Colors.white.withOpacity(0.3)),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: const BorderSide(color: Colors.white),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(
//                                 color: Colors.white.withOpacity(0.3)),
//                           ),
//                           filled: true,
//                           fillColor: Colors.black.withOpacity(0.3),
//                           contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 12,
//                           ),
//                         ),
//                         maxLines: 3,
//                       ),

//                       const SizedBox(height: 24),

//                       // Action Buttons
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           // Retake Button
//                           TextButton.icon(
//                             onPressed: () {
//                               _disposeVideoPlayer();
//                               controller.discardVideo();
//                             },
//                             icon: const Icon(
//                               Icons.refresh,
//                               color: Colors.white,
//                             ),
//                             label: const Text(
//                               'Retake',
//                               style: TextStyle(color: Colors.white),
//                             ),
//                             style: TextButton.styleFrom(
//                               backgroundColor: Colors.black.withOpacity(0.5),
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 12,
//                               ),
//                             ),
//                           ),

//                           // Upload Button
//                           Obx(() => ElevatedButton.icon(
//                                 onPressed: controller.isLoading.value
//                                     ? null
//                                     : _uploadVideo,
//                                 icon: controller.isLoading.value
//                                     ? const SizedBox(
//                                         width: 20,
//                                         height: 20,
//                                         child: CircularProgressIndicator(
//                                           strokeWidth: 2,
//                                           color: Colors.white,
//                                         ),
//                                       )
//                                     : const Icon(Icons.check),
//                                 label: const Text('Use Video'),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: ColorConstants.primaryColor,
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 20,
//                                     vertical: 12,
//                                   ),
//                                 ),
//                               )),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               // Loading Indicator
//               if (controller.isLoading.value)
//                 const Positioned.fill(
//                   child: LoadingWidget(),
//                 ),
//             ],
//           );
//         }),
//       ),
//     );
//   }

//   Widget _buildVideoPreview() {
//     if (!_isInitialized.value) {
//       return const Center(
//         child: CircularProgressIndicator(
//           color: Colors.white,
//         ),
//       );
//     }

//     return GestureDetector(
//       onTap: _togglePlayPause,
//       child: AspectRatio(
//         aspectRatio: _videoPlayerController!.value.aspectRatio,
//         child: VideoPlayer(_videoPlayerController!),
//       ),
//     );
//   }

//   void _initializeVideoPlayer() async {
//     if (controller.capturedVideoPath.value.isEmpty) return;

//     final videoPlayerController = VideoPlayerController.file(
//       File(controller.capturedVideoPath.value),
//     );

//     await videoPlayerController.initialize();

//     // Set up listener for playback status
//     videoPlayerController.addListener(() {
//       _isPlaying.value = videoPlayerController.value.isPlaying;
//     });

//     _videoPlayerController = videoPlayerController;
//     _isInitialized.value = true;
//     _videoPlayerController!.play();
//     _isPlaying.value = true;
//   }

//   void _togglePlayPause() {
//     if (_videoPlayerController == null) return;

//     if (_videoPlayerController!.value.isPlaying) {
//       _videoPlayerController!.pause();
//     } else {
//       _videoPlayerController!.play();
//     }
//   }

//   void _disposeVideoPlayer() {
//     _videoPlayerController?.dispose();
//     _isInitialized.value = false;
//     _isPlaying.value = false;
//   }

//   void _uploadVideo() {
//     // You need to implement the video upload logic similar to uploadPhoto
//     // For now, just show a success message and go back
//     Get.snackbar(
//       'Success',
//       'Video uploaded successfully',
//       snackPosition: SnackPosition.BOTTOM,
//     );

//     _disposeVideoPlayer();
//     controller.capturedVideoPath.value = '';
//     controller.captionController.clear();

//     // Navigate back to the event details
//     Get.until((route) => route.settings.name == AppRoutes.EVENT_DETAILS);
//   }
// }
