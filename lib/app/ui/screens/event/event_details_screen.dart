import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:povo/app/controllers/event_controller.dart';
import 'package:povo/app/core/constants/color_constants.dart';
import 'package:povo/app/core/routes/app_routes.dart';
import 'package:povo/app/ui/widgets/buttons/custom_button.dart';
import 'package:povo/app/ui/widgets/common/loading_widget.dart';
import 'package:povo/app/ui/widgets/common/error_widget.dart';

class EventDetailsScreen extends GetView<EventController> {
  @override
  Widget build(BuildContext context) {
    // Get the event ID from the route arguments
    final String eventId = Get.arguments as String;

    // Load the event
    controller.loadEvent(eventId);

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget();
        }

        if (controller.hasError.value) {
          return CustomErrorWidget(
            message: controller.errorMessage.value,
            onRetry: () => controller.loadEvent(eventId),
          );
        }

        if (controller.currentEvent.value == null) {
          return const Center(
            child: Text('Evento no encontrado'),
          );
        }

        return _buildEventDetails(context, controller.currentEvent.value!);
      }),
    );
  }

  Widget _buildEventDetails(BuildContext context, dynamic event) {
    final bool isHost = event.hostId == controller.userId;
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

    return CustomScrollView(
      slivers: [
        // App Bar with Cover Image
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: event.coverImage != null
                ? Image.network(
                    event.coverImage,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: ColorConstants.primaryColor.withOpacity(0.8),
                    child: Center(
                      child: Icon(
                        Icons.event,
                        size: 80,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
          ),
          actions: [
            if (isHost)
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Editar evento'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'qr',
                    child: Row(
                      children: [
                        Icon(Icons.qr_code, size: 20),
                        SizedBox(width: 8),
                        Text('Código QR'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Eliminar evento',
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      // Edit event
                      break;
                    case 'qr':
                      Get.toNamed(
                        AppRoutes.QR_GENERATOR,
                        arguments: {
                          'eventId': event.id,
                          'joinCode': controller.joinCode.value
                        },
                      );
                      break;
                    case 'delete':
                      _showDeleteEventDialog(context, event.id);
                      break;
                  }
                },
              ),
            if (!isHost)
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'leave',
                    child: Row(
                      children: [
                        Icon(Icons.exit_to_app, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Salir del evento',
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'leave') {
                    _showLeaveEventDialog(context, event.id);
                  }
                },
              ),
          ],
        ),

        // Event Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Name
                Text(
                  event.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 8),

                // Event Dates
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event.endDate != null
                          ? '${dateFormat.format(event.startDate)} - ${dateFormat.format(event.endDate!)}'
                          : dateFormat.format(event.startDate),
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                if (event.locationName != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.locationName!,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // Event Description
                if (event.description != null &&
                    event.description!.isNotEmpty) ...[
                  Text(
                    event.description!,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Join Code
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
                        'Código de acceso',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Comparte este código con los participantes para que se unan al evento.',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    controller.joinCode.value,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      letterSpacing: 4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isHost) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () =>
                                  controller.regenerateJoinCode(event.id),
                              icon: const Icon(Icons.refresh),
                              tooltip: 'Generar nuevo código',
                            ),
                          ],
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              // Copy to clipboard and show snackbar
                              // Implement clipboard functionality
                              Get.snackbar(
                                'Código copiado',
                                'El código de acceso ha sido copiado al portapapeles',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                            icon: const Icon(Icons.copy),
                            tooltip: 'Copiar código',
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              Get.toNamed(
                                AppRoutes.QR_GENERATOR,
                                arguments: {
                                  'eventId': event.id,
                                  'joinCode': controller.joinCode.value
                                },
                              );
                            },
                            icon: const Icon(Icons.qr_code),
                            tooltip: 'Mostrar QR',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Tomar fotos',
                        icon: Icons.camera_alt,
                        onPressed: () => controller.goToCamera(event.id),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Ver galería',
                        icon: Icons.photo_library,
                        onPressed: () => controller.goToGallery(event.id),
                        backgroundColor: Colors.teal,
                      ),
                    ),
                  ],
                ),

                if (isHost && event.requiresModeration) ...[
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Moderar fotos',
                    icon: Icons.admin_panel_settings,
                    onPressed: () => controller.goToModeration(event.id),
                    backgroundColor: Colors.amber[800]!,
                  ),
                ],

                const SizedBox(height: 32),

                // Moderation Status
                if (isHost) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: event.requiresModeration
                          ? Colors.blue[50]
                          : Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: event.requiresModeration
                            ? Colors.blue[200]!
                            : Colors.green[200]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          event.requiresModeration
                              ? Icons.verified_user
                              : Icons.public,
                          color: event.requiresModeration
                              ? Colors.blue[700]
                              : Colors.green[700],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.requiresModeration
                                    ? 'Moderación activada'
                                    : 'Moderación desactivada',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: event.requiresModeration
                                      ? Colors.blue[700]
                                      : Colors.green[700],
                                ),
                              ),
                              Text(
                                event.requiresModeration
                                    ? 'Las fotos deben ser aprobadas antes de aparecer en la galería.'
                                    : 'Las fotos aparecen inmediatamente en la galería.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: event.requiresModeration
                                      ? Colors.blue[700]
                                      : Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              //TODO Revisar eto
                              controller.toggleModeration(event.id),
                          child: Text(
                            event.requiresModeration ? 'Desactivar' : 'Activar',
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (event.requiresModeration) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Las fotos que captures serán revisadas por el anfitrión antes de aparecer en la galería.',
                            style: TextStyle(
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteEventDialog(BuildContext context, String eventId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Eliminar evento'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este evento? Esta acción no se puede deshacer y se eliminarán todas las fotos asociadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteEvent(eventId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showLeaveEventDialog(BuildContext context, String eventId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Salir del evento'),
        content: const Text(
          '¿Estás seguro de que quieres salir de este evento? Ya no podrás ver las fotos ni añadir nuevas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.leaveEvent(eventId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}
