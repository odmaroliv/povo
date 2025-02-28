import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:povo/app/controllers/auth_controller.dart';
import 'package:povo/app/core/constants/color_constants.dart';
import 'package:povo/app/ui/widgets/buttons/custom_button.dart';
import 'package:povo/app/ui/widgets/buttons/social_button.dart';

class SignupScreen extends GetView<AuthController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // Create Account Text
              Text(
                'Crear cuenta',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ColorConstants.primaryColor,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Únete y captura momentos increíbles',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Name Field
              Obx(() => TextField(
                    controller: controller.nameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorText: !controller.isValidName.value &&
                              controller.nameController.text.isNotEmpty
                          ? 'Ingrese un nombre válido'
                          : null,
                    ),
                  )),

              const SizedBox(height: 16),

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
                      errorText: !controller.isValidPassword.value &&
                              controller.passwordController.text.isNotEmpty
                          ? 'La contraseña debe tener al menos 6 caracteres'
                          : null,
                    ),
                  )),

              const SizedBox(height: 16),

              // Confirm Password Field
              Obx(() => TextField(
                    controller: controller.confirmPasswordController,
                    obscureText: !controller.confirmPasswordVisible.value,
                    decoration: InputDecoration(
                      labelText: 'Confirmar contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.confirmPasswordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: controller.toggleConfirmPasswordVisibility,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorText: !controller.isValidConfirmPassword.value &&
                              controller
                                  .confirmPasswordController.text.isNotEmpty
                          ? 'Las contraseñas no coinciden'
                          : null,
                    ),
                  )),

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

              // Terms & Privacy Policy
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Al registrarte, aceptas nuestros Términos de Servicio y Política de Privacidad.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Sign Up Button
              Obx(() => CustomButton(
                    text: 'Crear cuenta',
                    onPressed: controller.isSignUpFormValid
                        ? controller.signUpWithEmail
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

              // Google Sign In Button
              Obx(() => SocialButton(
                    text: 'Continuar con Google',
                    icon: 'assets/icons/google.png',
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.signInWithGoogle,
                  )),

              const SizedBox(height: 32),

              // Sign In Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿Ya tienes una cuenta?',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Inicia sesión'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
