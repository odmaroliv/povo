import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:povo/app/controllers/event_controller.dart';
import 'package:povo/app/core/constants/color_constants.dart';
import 'package:povo/app/ui/widgets/buttons/custom_button.dart';

class CreateEventScreen extends GetView<EventController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Evento'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover Image Selector
            Obx(() => GestureDetector(
                  onTap: controller.pickCoverImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      image: controller.coverImage.value != null
                          ? DecorationImage(
                              image: FileImage(controller.coverImage.value!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: controller.coverImage.value == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 50,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Agregar foto de portada',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                              onPressed: controller.pickCoverImage,
                            ),
                          ),
                  ),
                )),

            const SizedBox(height: 24),

            // Event Name
            TextField(
              controller: controller.nameController,
              decoration: InputDecoration(
                labelText: 'Nombre del evento*',
                hintText: 'Ej: Fiesta de cumpleaños',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.event),
              ),
            ),

            const SizedBox(height: 16),

            // Event Description
            TextField(
              controller: controller.descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Descripción (opcional)',
                hintText: 'Describe de qué trata el evento',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
            ),

            const SizedBox(height: 16),

            // Event Date Selector
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => controller.selectStartDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fecha inicio*',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Obx(() => Text(
                                    controller.formattedStartDate,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => controller.selectEndDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event_available),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fecha fin (opcional)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Obx(() => Text(
                                    controller.endDate.value != null
                                        ? controller.formattedEndDate
                                        : 'No definida',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Event Location
            TextField(
              controller: controller.locationController,
              decoration: InputDecoration(
                labelText: 'Ubicación (opcional)',
                hintText: 'Ej: Casa de Juan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),

            const SizedBox(height: 24),

            // Moderation Switch
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Configuración de moderación',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Activa la moderación para aprobar las fotos antes de que sean visibles para todos los participantes.',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Requerir aprobación de fotos',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Obx(() => Switch(
                            value: controller.requiresModeration.value,
                            onChanged: (value) {
                              controller.requiresModeration.value = value;
                            },
                            activeColor: ColorConstants.primaryColor,
                          )),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

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

            const SizedBox(height: 16),

            // Create Button
            Obx(() => CustomButton(
                  text: 'Crear Evento',
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.createEvent,
                  isLoading: controller.isLoading.value,
                )),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
