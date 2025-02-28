import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:povo/app/data/models/user_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  AuthService() {
    // Inicializar en el constructor
    _init();
  }

  void _init() {
    firebaseUser.value = _auth.currentUser;

    _auth.userChanges().listen((User? user) {
      firebaseUser.value = user;
    });
  }

  // Store the current user
  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> user = Rx<UserModel?>(null);

  // Getters
  bool get isLoggedIn => firebaseUser.value != null;
  String? get userId => firebaseUser.value?.uid;
  User? get currentUser => _auth.currentUser;

  // Auth state changes
  Stream<User?> get userChanges => _auth.userChanges();
  Stream<UserModel?> get userModelChanges =>
      _auth.userChanges().asyncMap((User? firebaseUser) async {
        if (firebaseUser == null) {
          user.value = null;
          return null;
        }

        // Get user profile from Firestore
        final doc =
            await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (doc.exists) {
          final userModel =
              UserModel.fromJson(doc.data() as Map<String, dynamic>);
          user.value = userModel;
          return userModel;
        }

        return null;
      });

  // Email/Password Authentication
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      firebaseUser.value = credential.user;
      return credential;
    } catch (e) {
      print('Error signing in with email: $e');
      rethrow;
    }
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      firebaseUser.value = credential.user;
      return credential;
    } catch (e) {
      print('Error signing up with email: $e');
      rethrow;
    }
  }

  // Google Authentication
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null; // User canceled the sign-in
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      firebaseUser.value = userCredential.user;

      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Create or update user profile
  Future<void> createUserProfile(UserModel userModel) async {
    try {
      await _firestore
          .collection('users')
          .doc(userModel.id)
          .set(userModel.toJson());
      user.value = userModel;
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile(UserModel userModel) async {
    try {
      await _firestore
          .collection('users')
          .doc(userModel.id)
          .update(userModel.toJson());
      user.value = userModel;
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Get user profile
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      firebaseUser.value = null;
      user.value = null;
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Password reset
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error sending password reset email: $e');
      rethrow;
    }
  }

  // Update email
  Future<void> updateEmail(String newEmail) async {
    try {
      await _auth.currentUser?.updateEmail(newEmail);
    } catch (e) {
      print('Error updating email: $e');
      rethrow;
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } catch (e) {
      print('Error updating password: $e');
      rethrow;
    }
  }

  // Initialize service
  Future<AuthService> init() async {
    // Set up auth state listener
    firebaseUser.value = _auth.currentUser;

    _auth.userChanges().listen((User? user) {
      firebaseUser.value = user;
    });

    return this;
  }
}
