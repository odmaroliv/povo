import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:povo/app/data/models/user_model.dart';
import 'package:povo/app/services/auth_service.dart';
import 'package:povo/app/services/firebase_service.dart';
import 'package:povo/app/services/storage_service.dart';

class UserRepository {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final AuthService _authService = Get.find<AuthService>();
  final StorageService _storageService = Get.find<StorageService>();

  // Collection reference
  CollectionReference get usersCollection => _firebaseService.usersCollection;

  // Create a new user
  Future<UserModel> createUser({
    required String id,
    required String email,
    required String name,
    String? profileImagePath,
  }) async {
    try {
      // Upload profile image if provided
      String? profileImageUrl;
      if (profileImagePath != null) {
        profileImageUrl =
            await _storageService.uploadProfileImage(profileImagePath, id);
      }

      // Create user model
      final user = UserModel(
        id: id,
        email: email,
        name: name,
        profileImage: profileImageUrl,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await usersCollection.doc(id).set(user.toJson());

      return user;
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  // Get a user by ID
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await usersCollection.doc(userId).get();

      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      print('Error getting user: $e');
      rethrow;
    }
  }

  // Update a user's profile
  Future<UserModel> updateUserProfile({
    required String userId,
    String? name,
    String? profileImagePath,
  }) async {
    try {
      // Get current user
      final currentUser = await getUser(userId);

      if (currentUser == null) {
        throw Exception('User not found');
      }

      // Upload new profile image if provided
      String? profileImageUrl = currentUser.profileImage;
      if (profileImagePath != null) {
        // Delete old profile image if exists
        if (currentUser.profileImage != null) {
          await _storageService.deleteFile(currentUser.profileImage!);
        }

        // Upload new profile image
        profileImageUrl =
            await _storageService.uploadProfileImage(profileImagePath, userId);
      }

      // Update user model
      final updatedUser = currentUser.copyWith(
        name: name ?? currentUser.name,
        profileImage: profileImageUrl,
      );

      // Save to Firestore
      await usersCollection.doc(userId).update({
        if (name != null) 'name': name,
        if (profileImageUrl != null) 'profileImage': profileImageUrl,
      });

      return updatedUser;
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Get a user by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final querySnapshot =
          await usersCollection.where('email', isEqualTo: email).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        return UserModel.fromJson(
            querySnapshot.docs.first.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      print('Error getting user by email: $e');
      rethrow;
    }
  }

  // Stream of a user's profile
  Stream<UserModel?> userStream(String userId) {
    return usersCollection.doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Get users by IDs
  Future<List<UserModel>> getUsersByIds(List<String> userIds) async {
    try {
      if (userIds.isEmpty) {
        return [];
      }

      // Firestore can only query up to 10 items in a whereIn clause
      // So we need to break it up into chunks
      const chunkSize = 10;
      final usersList = <UserModel>[];

      for (var i = 0; i < userIds.length; i += chunkSize) {
        final end =
            (i + chunkSize < userIds.length) ? i + chunkSize : userIds.length;
        final chunk = userIds.sublist(i, end);

        final querySnapshot = await usersCollection
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        final users = querySnapshot.docs
            .map(
                (doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList();

        usersList.addAll(users);
      }

      return usersList;
    } catch (e) {
      print('Error getting users by IDs: $e');
      rethrow;
    }
  }

  // Get event participants
  Future<List<UserModel>> getEventParticipants(String eventId) async {
    try {
      final event = await _firebaseService.getEvent(eventId);

      if (event == null) {
        return [];
      }

      return getUsersByIds(event.participantIds);
    } catch (e) {
      print('Error getting event participants: $e');
      rethrow;
    }
  }

  // Delete a user (for account deletion)
  Future<void> deleteUser(String userId) async {
    try {
      final user = await getUser(userId);

      if (user != null) {
        // Delete profile image if exists
        if (user.profileImage != null) {
          await _storageService.deleteFile(user.profileImage!);
        }

        // Delete user from Firestore
        await usersCollection.doc(userId).delete();

        // Delete the user from Firebase Auth
        await _authService.currentUser?.delete();
      }
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  // Update FCM token
  Future<void> updateFCMToken(String userId, String token) async {
    try {
      await usersCollection.doc(userId).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
      });
    } catch (e) {
      print('Error updating FCM token: $e');
      rethrow;
    }
  }

  // Remove FCM token
  Future<void> removeFCMToken(String userId, String token) async {
    try {
      await usersCollection.doc(userId).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });
    } catch (e) {
      print('Error removing FCM token: $e');
      rethrow;
    }
  }
}
