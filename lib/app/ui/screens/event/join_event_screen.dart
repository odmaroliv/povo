// join_event_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:povo/app/controllers/event_controller.dart';
import 'package:povo/app/core/constants/color_constants.dart';
import 'package:povo/app/ui/widgets/buttons/custom_button.dart';

class JoinEventScreen extends GetView<EventController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unirse a un evento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),

            // Icon
            const Icon(
              Icons.group_add,
              size: 80,
              color: ColorConstants.primaryColor,
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              'Unirse a un evento',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.primaryColor,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              'Ingresa el código de 6 caracteres proporcionado por el anfitrión del evento',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Code Input
            Obx(() => TextField(
                  onChanged: (value) => controller.joinCode.value = value,
                  decoration: InputDecoration(
                    labelText: 'Código de acceso',
                    hintText: 'Ej: ABC123',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                  ),
                )),

            const SizedBox(height: 24),

            // Error Message
            Obx(() => controller.hasError.value
                ? Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(
                      controller.errorMessage.value,
                      style: TextStyle(color: Colors.red[700]),
                      textAlign: TextAlign.center,
                    ),
                  )
                : const SizedBox.shrink()),

            const SizedBox(height: 24),

            // Join Button
            Obx(() => CustomButton(
                  text: 'Unirme al evento',
                  onPressed: controller.isLoading.value
                      ? null
                      : () =>
                          controller.joinEventByCode(controller.joinCode.value),
                  isLoading: controller.isLoading.value,
                )),

            const SizedBox(height: 40),

            // Or scan QR code
            Text(
              'O escanea un código QR',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 16),

            // Scan QR Button
            OutlinedButton.icon(
              onPressed: () {
                // Implementar funcionalidad de escaneo de QR
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Escanear código QR'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
