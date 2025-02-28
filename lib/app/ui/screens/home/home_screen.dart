import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:povo/app/controllers/home_controller.dart';
import 'package:povo/app/core/constants/color_constants.dart';
import 'package:povo/app/ui/widgets/buttons/custom_button.dart';
import 'package:povo/app/ui/widgets/common/loading_widget.dart';
import 'package:povo/app/ui/widgets/common/error_widget.dart';
import 'package:povo/app/ui/widgets/event/event_card.dart';

class HomeScreen extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'povo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // Navigate to profile screen
              // Get.toNamed(AppRoutes.PROFILE);

              // For now, just show a sign out button
              _showSignOutDialog(context);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget();
        }

        if (controller.hasError.value) {
          return CustomErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.refreshData,
          );
        }

        return _buildContent(context);
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showJoinCreateOptions(context),
        label: const Text('Nuevo evento'),
        icon: const Icon(Icons.add),
        backgroundColor: ColorConstants.primaryColor,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar(
            labelColor: ColorConstants.primaryColor,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: ColorConstants.primaryColor,
            onTap: controller.changeTab,
            tabs: [
              Tab(
                text: 'Mis Eventos (${controller.hostedEvents.length})',
                icon: const Icon(Icons.event_available),
              ),
              Tab(
                text: 'Participando (${controller.participatedEvents.length})',
                icon: const Icon(Icons.group),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Hosted Events Tab
                _buildHostedEventsTab(),

                // Participated Events Tab
                _buildParticipatedEventsTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostedEventsTab() {
    if (controller.hostedEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No has creado ningún evento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Crea un evento para comenzar a capturar fotos',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Crear Evento',
              onPressed: controller.goToCreateEvent,
              width: 200,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.hostedEvents.length,
        itemBuilder: (context, index) {
          final event = controller.hostedEvents[index];
          return EventCard(
            event: event,
            isHost: true,
            hasPendingPhotos: controller.hasEventPendingPhotos(event.id),
            onPressed: () => controller.goToEventDetails(event.id),
          );
        },
      ),
    );
  }

  Widget _buildParticipatedEventsTab(BuildContext context) {
    if (controller.participatedEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No estás participando en ningún evento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Únete a un evento con un código de acceso',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Unirme a Evento',
              onPressed: () => _showJoinEventDialog(context),
              width: 200,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.participatedEvents.length,
        itemBuilder: (context, index) {
          final event = controller.participatedEvents[index];
          return EventCard(
            event: event,
            isHost: false,
            onPressed: () => controller.goToEventDetails(event.id),
          );
        },
      ),
    );
  }

  void _showJoinCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¿Qué quieres hacer?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorConstants.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_circle_outline,
                    color: ColorConstants.primaryColor,
                  ),
                ),
                title: const Text('Crear un nuevo evento'),
                subtitle: const Text('Sé el anfitrión y gestiona tus fotos'),
                onTap: () {
                  Get.back();
                  controller.goToCreateEvent();
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.amber,
                  ),
                ),
                title: const Text('Unirme a un evento'),
                subtitle: const Text('Utiliza el código de acceso del evento'),
                onTap: () {
                  Get.back();
                  _showJoinEventDialog(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showJoinEventDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Unirse a un evento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa el código de acceso proporcionado por el anfitrión del evento.',
            ),
            const SizedBox(height: 16),
            TextField(
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
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.joinEventByCode,
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Unirme'),
              )),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
