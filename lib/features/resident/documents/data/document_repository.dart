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
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('docs/$uid/$docType.jpg');
    
    final metadata = SettableMetadata(
      contentType: file.mimeType ?? 'image/jpeg', 
      customMetadata: {'uploadedBy': uid},
    );
    
    UploadTask uploadTask;
    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      uploadTask = storageRef.putData(bytes, metadata);
    } else {
      uploadTask = storageRef.putFile(File(file.path), metadata);
    }
    
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}


final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepository(FirebaseFirestore.instance);
});

final residentDocumentsProvider = FutureProvider.family<ResidentDocumentModel?, String>((ref, uid) {
  return ref.watch(documentRepositoryProvider).getDocuments(uid);
});
