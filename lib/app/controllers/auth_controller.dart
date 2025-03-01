import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:povo/app/core/routes/app_routes.dart';
import 'package:povo/app/core/utils/validators.dart';
import 'package:povo/app/data/models/user_model.dart';
import 'package:povo/app/data/repositories/user_repository.dart';
import 'package:povo/app/services/auth_service.dart';
import 'package:povo/app/services/notification_service.dart';

class AuthController extends GetxController {
  late final AuthService _authService;
  final UserRepository _userRepository = Get.find<UserRepository>();
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  // Form controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // State variables
  final RxBool isLoading = false.obs;
  final RxBool passwordVisible = false.obs;
  final RxBool confirmPasswordVisible = false.obs;
  final RxBool isValidEmail = false.obs;
  final RxBool isValidPassword = false.obs;
  final RxBool isValidName = false.obs;
  final RxBool isValidConfirmPassword = false.obs;
  final RxString errorMessage = ''.obs;

  // Current user from auth service
  Rx<User?> get firebaseUser => _authService.firebaseUser;
  Rx<UserModel?> get user => _authService.user;

  @override
  void onInit() {
    super.onInit();
    _authService = Get.find<AuthService>();
    // Set up listeners for text fields
    emailController.addListener(_validateEmail);
    passwordController.addListener(_validatePassword);
    nameController.addListener(_validateName);
    confirmPasswordController.addListener(_validateConfirmPassword);

    // Listen to auth state changes
    ever(firebaseUser, _handleAuthChanged);
  }

  void _handleAuthChanged(User? user) {
    if (user == null) {
      // User is not logged in
      Get.offAllNamed(AppRoutes.LOGIN);
    } else {
      // User is logged in
      Get.offAllNamed(AppRoutes.HOME);
    }
  }

  // Validation methods
  void _validateEmail() {
    isValidEmail.value = Validators.isValidEmail(emailController.text.trim());
  }

  void _validatePassword() {
    isValidPassword.value = Validators.isValidPassword(passwordController.text);
    _validateConfirmPassword();
  }

  void _validateName() {
    isValidName.value = Validators.isValidName(nameController.text);
  }

  void _validateConfirmPassword() {
    isValidConfirmPassword.value =
        confirmPasswordController.text == passwordController.text &&
            confirmPasswordController.text.isNotEmpty;
  }

  // Form validation
  bool get isLoginFormValid =>
      isValidEmail.value && passwordController.text.isNotEmpty;

  bool get isSignUpFormValid =>
      isValidEmail.value &&
      isValidPassword.value &&
      isValidName.value &&
      isValidConfirmPassword.value;

  // Toggle password visibility
  void togglePasswordVisibility() {
    passwordVisible.value = !passwordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    confirmPasswordVisible.value = !confirmPasswordVisible.value;
  }

  // Sign in with email and password
  Future<void> signInWithEmail() async {
    if (!isLoginFormValid) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.signInWithEmail(
        emailController.text.trim(),
        passwordController.text,
      );

      // Register FCM token
      if (_authService.userId != null) {
        await _notificationService.saveFCMToken(_authService.userId!);
      }

      // Clear form
      _clearLoginForm();
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      errorMessage.value =
          'Ha ocurrido un error inesperado. Intente nuevamente.';
      print('Sign in error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Sign up with email and password
  Future<void> signUpWithEmail() async {
    if (!isSignUpFormValid) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Create user in Firebase Auth
      final credential = await _authService.signUpWithEmail(
        emailController.text.trim(),
        passwordController.text,
      );

      // Create user profile in Firestore
      if (credential.user != null) {
        await _userRepository.createUser(
          id: credential.user!.uid,
          email: emailController.text.trim(),
          name: nameController.text.trim(),
        );

        // Register FCM token
        await _notificationService.saveFCMToken(credential.user!.uid);
      }

      // Clear form
      _clearSignUpForm();
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      errorMessage.value =
          'Ha ocurrido un error inesperado. Intente nuevamente.';
      print('Sign up error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final credential = await _authService.signInWithGoogle();

      // If user canceled the sign in, do nothing
      if (credential == null) {
        isLoading.value = false;
        return;
      }

      // Check if user exists in Firestore
      final user = await _userRepository.getUser(credential.user!.uid);

      // If user doesn't exist, create a profile
      if (user == null) {
        await _userRepository.createUser(
          id: credential.user!.uid,
          email: credential.user!.email!,
          name: credential.user!.displayName ?? 'Usuario',
          profileImagePath: credential.user!.photoURL,
        );
      }

      // Register FCM token
      await _notificationService.saveFCMToken(credential.user!.uid);
    } catch (e) {
      errorMessage.value =
          'Error al iniciar sesión con Google. Intente nuevamente.';
      print('Google sign in error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      isLoading.value = true;

      // Unregister FCM token
      if (_authService.userId != null) {
        final fcmToken = await _notificationService.getFCMToken();
        if (fcmToken != null) {
          await _userRepository.removeFCMToken(_authService.userId!, fcmToken);
        }
      }

      await _authService.signOut();
    } catch (e) {
      print('Sign out error: $e');
      Get.snackbar(
        'Error',
        'No se pudo cerrar sesión. Intente nuevamente.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.resetPassword(email);

      Get.snackbar(
        'Éxito',
        'Se ha enviado un correo para restablecer la contraseña.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      errorMessage.value =
          'Ha ocurrido un error inesperado. Intente nuevamente.';
      print('Reset password error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Handle Firebase Auth errors
  void _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        errorMessage.value =
            'No existe una cuenta con este correo electrónico.';
        break;
      case 'wrong-password':
        errorMessage.value = 'Contraseña incorrecta.';
        break;
      case 'email-already-in-use':
        errorMessage.value =
            'Ya existe una cuenta con este correo electrónico.';
        break;
      case 'invalid-email':
        errorMessage.value = 'El correo electrónico no es válido.';
        break;
      case 'weak-password':
        errorMessage.value = 'La contraseña es demasiado débil.';
        break;
      case 'operation-not-allowed':
        errorMessage.value = 'Operación no permitida. Contacte al soporte.';
        break;
      case 'too-many-requests':
        errorMessage.value = 'Demasiados intentos fallidos. Intente más tarde.';
        break;
      default:
        errorMessage.value = 'Error de autenticación: ${e.message}';
        break;
    }
  }

  // Clear forms
  void _clearLoginForm() {
    emailController.clear();
    passwordController.clear();
    errorMessage.value = '';
  }

  void _clearSignUpForm() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    confirmPasswordController.clear();
    errorMessage.value = '';
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
