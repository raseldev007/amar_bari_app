import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ResidentDocumentModel {
  final String? nidNumber;
  final String? nidFrontUrl;
  final String? photoUrl; // Passport size photo
  final String? birthCertUrl;
  final String status; // 'pending' | 'verified' | 'rejected'

  ResidentDocumentModel({
    this.nidNumber,
    this.nidFrontUrl,
    this.photoUrl,
    this.birthCertUrl,
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() {
    return {
      'nidNumber': nidNumber,
      'nidFrontUrl': nidFrontUrl,
      'photoUrl': photoUrl,
      'birthCertUrl': birthCertUrl,
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory ResidentDocumentModel.fromJson(Map<String, dynamic> json) {
    return ResidentDocumentModel(
      nidNumber: json['nidNumber'] as String?,
      nidFrontUrl: json['nidFrontUrl'] as String?,
      photoUrl: json['photoUrl'] as String?,
      birthCertUrl: json['birthCertUrl'] as String?,
      status: json['status'] as String? ?? 'pending',
    );
  }
}

class DocumentRepository {
  final FirebaseFirestore _firestore;

  DocumentRepository(this._firestore);

  Future<void> saveDocuments(String uid, ResidentDocumentModel docs) async {
    // Using 'tenant_profiles' keyed by UID as per new requirements
    await _firestore.collection('tenant_profiles').doc(uid).set(
      docs.toJson(),
      SetOptions(merge: true),
    );
  }

  Future<ResidentDocumentModel?> getDocuments(String uid) async {
    final doc = await _firestore.collection('tenant_profiles').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return ResidentDocumentModel.fromJson(doc.data()!);
    }
    return null;
  }

  Future<String> uploadDocument(String uid, String docType, XFile file) async {
    print('[Repo] Processing $docType for $uid (Base64 Mode)...');
    
    // 1. Read bytes
    final bytes = await file.readAsBytes();
    
    // 2. Compress (Simple resize via Flutter Image library is heavy, so we rely on ImagePicker quality)
    // Note: In real app, we should use 'flutter_image_compress' package.
    // Since we don't have that package installed and cannot easily add it without restart/approval,
    // we rely on the `imageQuality: 25` passed from UI.
    
    // 3. Convert to Base64
    final base64String = base64Encode(bytes);
    
    // 4. Return Data URI
    // We mock a delay to simulate "upload" and ensure UI feedback
    await Future.delayed(const Duration(milliseconds: 500));
    
    return 'data:image/jpeg;base64,$base64String';
  }
}


final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepository(FirebaseFirestore.instance);
});

final residentDocumentsProvider = FutureProvider.family<ResidentDocumentModel?, String>((ref, uid) {
  return ref.watch(documentRepositoryProvider).getDocuments(uid);
});
