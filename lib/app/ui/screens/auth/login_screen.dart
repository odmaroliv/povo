import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:povo/app/controllers/auth_controller.dart';
import 'package:povo/app/core/constants/color_constants.dart';
import 'package:povo/app/core/routes/app_routes.dart';
import 'package:povo/app/ui/widgets/buttons/custom_button.dart';
import 'package:povo/app/ui/widgets/buttons/social_button.dart';

class LoginScreen extends GetView<AuthController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Logo alternativo: Mostrar "POVO" en vez de imagen
              Center(
                child: Text(
                  'POVO',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ColorConstants.primaryColor,
                      ),
                ),
              ),

              const SizedBox(height: 32),

              // Welcome Text
              Text(
                'Bienvenido a povo',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ColorConstants.primaryColor,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Captura los mejores momentos juntos',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Email Field
              Obx(() => TextField(
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorText: !controller.isValidEmail.value &&
                              controller.emailController.text.isNotEmpty
                          ? 'Ingrese un correo electrónico válido'
                          : null,
                    ),
                  )),

              const SizedBox(height: 16),

              // Password Field
              Obx(() => TextField(
                    controller: controller.passwordController,
                    obscureText: !controller.passwordVisible.value,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.passwordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )),

              const SizedBox(height: 8),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Mostrar diálogo de restablecer contraseña
                    _showResetPasswordDialog(context);
                  },
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
              ),

              const SizedBox(height: 24),

              // Error Message
              Obx(() => controller.errorMessage.value.isNotEmpty
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

              // Login Button
              Obx(() => CustomButton(
                    text: 'Iniciar sesión',
                    onPressed: controller.isLoginFormValid
                        ? controller.signInWithEmail
                        : null,
                    isLoading: controller.isLoading.value,
                  )),

              const SizedBox(height: 24),

              // OR Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey[300],
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'O',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.grey[300],
                      thickness: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Google Sign In Button usando imagen de red como icono
              Obx(() => SocialButton(
                    text: 'Continuar con Google',
                    // Usamos una imagen de red para el logo de Google
                    icon:
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/512px-Google_%22G%22_Logo.svg.png',
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.signInWithGoogle,
                  )),

              const SizedBox(height: 32),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿No tienes una cuenta?',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.SIGNUP),
                    child: const Text('Regístrate'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Diálogo para restablecer contraseña
  void _showResetPasswordDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Restablecer contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa tu correo electrónico para recibir un enlace para restablecer tu contraseña.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.isNotEmpty) {
                controller.resetPassword(emailController.text.trim());
                Get.back();
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}

class SocialButton extends StatelessWidget {
  final String text;
  final String icon;
  final VoidCallback? onPressed;

  const SocialButton({
    Key? key,
    required this.text,
    required this.icon,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Detecta si la cadena es una URL y selecciona el widget de imagen correspondiente
    final Widget iconWidget = icon.startsWith('http')
        ? Image.network(
            icon,
            height: 24,
            width: 24,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.error, size: 24);
            },
          )
        : Image.asset(
            icon,
            height: 24,
            width: 24,
            fit: BoxFit.contain,
          );

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: iconWidget,
      label: Text(text),
      style: ElevatedButton.styleFrom(
        // Establece un padding adecuado para evitar desbordamientos
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }
}
