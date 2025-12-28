import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:amar_bari/models/user_model.dart';

abstract class UserRepository {
  Future<UserModel?> getUser(String uid);
  Future<void> createUser(UserModel user);
  Future<void> updateUserRole(String uid, String role);
  Future<void> updateUser(UserModel user);
  Future<String> uploadProfilePhoto(String uid, XFile file);
}

class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;

  FirestoreUserRepository(this._firestore);

  @override
  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromJson(doc.data()!);
  }

  @override
  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toJson());
  }

  @override
  Future<void> updateUserRole(String uid, String role) async {
    await _firestore.collection('users').doc(uid).set({'role': role}, SetOptions(merge: true));
  }

  @override
  Future<void> updateUser(UserModel user) async {
    // Only update fields that are editable via profile to allow granular updates if needed, 
    // but here we can just merge the whole model or specific fields.
    // Ideally we assume user model passed has the updated values.
    await _firestore.collection('users').doc(user.uid).set(user.toJson(), SetOptions(merge: true));
  }

  @override
  Future<String> uploadProfilePhoto(String uid, XFile file) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('profile_photos/$uid.jpg');
    
    // Use putData for cross-platform compatibility
    final metadata = SettableMetadata(contentType: 'image/jpeg');
    final bytes = await file.readAsBytes();
    final uploadTask = storageRef.putData(bytes, metadata);
    
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return FirestoreUserRepository(FirebaseFirestore.instance);
});

// Watch current user data
final userProfileProvider = StreamProvider.family<UserModel?, String>((ref, uid) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) => doc.exists ? UserModel.fromJson(doc.data()!) : null);
});
