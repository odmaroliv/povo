import 'package:flutter/material.dart';
import 'package:povo/app/core/constants/color_constants.dart';

class CameraControls extends StatelessWidget {
  final VoidCallback? onCapture;
  final VoidCallback onSwitchCamera;
  final bool isCapturing;

  const CameraControls({
    Key? key,
    required this.onCapture,
    required this.onSwitchCamera,
    this.isCapturing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Spacer for alignment
        const SizedBox(width: 60),

        // Capture Button
        GestureDetector(
          onTap: isCapturing ? null : onCapture,
          child: Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.8),
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: isCapturing
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ColorConstants.primaryColor,
                      ),
                    )
                  : Container(
                      height: 70,
                      width: 70,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),

        // Switch Camera Button
        IconButton(
          onPressed: onSwitchCamera,
          icon: const Icon(
            Icons.flip_camera_ios,
            color: Colors.white,
            size: 36,
          ),
          padding: const EdgeInsets.all(12),
          tooltip: 'Cambiar cámara',
        ),
      ],
    );
  }
}
