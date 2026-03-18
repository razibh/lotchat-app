import 'dart:typed_data';
import 'dart:io';  // ← এই লাইনটি যোগ করুন (File এর জন্য)
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ==================== Auth Methods ====================

  /// Sign in with email and password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign in error: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Sign in error: $e');
      return null;
    }
  }

  /// Sign up with email and password
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign up error: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Sign up error: $e');
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // ==================== Firestore Methods ====================

  /// Add a document to a collection
  Future<DocumentReference<Map<String, dynamic>>> addDocument(
      String collection,
      Map<String, dynamic> data
      ) {
    return _firestore.collection(collection).add(data);
  }

  /// Set a document with custom ID
  Future<void> setDocument(
      String collection,
      String docId,
      Map<String, dynamic> data
      ) {
    return _firestore.collection(collection).doc(docId).set(data);
  }

  /// Get a document
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
      String collection,
      String docId
      ) {
    return _firestore.collection(collection).doc(docId).get();
  }

  /// Update a document
  Future<void> updateDocument(
      String collection,
      String docId,
      Map<String, dynamic> data
      ) {
    return _firestore.collection(collection).doc(docId).update(data);
  }

  /// Delete a document
  Future<void> deleteDocument(String collection, String docId) {
    return _firestore.collection(collection).doc(docId).delete();
  }

  /// Get all documents from a collection
  Future<QuerySnapshot<Map<String, dynamic>>> getCollection(String collection) {
    return _firestore.collection(collection).get();
  }

  /// Listen to a collection (real-time)
  Stream<QuerySnapshot<Map<String, dynamic>>> listenToCollection(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  /// Listen to a document (real-time)
  Stream<DocumentSnapshot<Map<String, dynamic>>> listenToDocument(
      String collection,
      String docId
      ) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }

  /// Query with conditions
  Query<Map<String, dynamic>> queryCollection(String collection) {
    return _firestore.collection(collection);
  }

  // ==================== Storage Methods ====================

  /// Upload a file (bytes)
  Future<String?> uploadFile(
      String path,
      String fileName,
      Uint8List bytes
      ) async {
    try {
      final Reference ref = _storage.ref().child(path).child(fileName);
      final UploadTask uploadTask = ref.putData(bytes);
      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  /// Upload a file from path
  Future<String?> uploadFileFromPath(
      String path,
      String fileName,
      String filePath
      ) async {
    try {
      final Reference ref = _storage.ref().child(path).child(fileName);
      final UploadTask uploadTask = ref.putFile(File(filePath));  // ← File now works
      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  /// Delete a file by URL
  Future<void> deleteFile(String url) async {
    try {
      final Reference ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }

  /// Get download URL
  Future<String?> getDownloadUrl(String path, String fileName) async {
    try {
      final Reference ref = _storage.ref().child(path).child(fileName);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Get download URL error: $e');
      return null;
    }
  }

  // ==================== Batch Operations ====================

  /// Create a batch write
  WriteBatch batch() {
    return _firestore.batch();
  }

  /// Run a transaction
  Future<T> runTransaction<T>(
      Future<T> Function(Transaction transaction) handler
      ) {
    return _firestore.runTransaction(handler);
  }
}