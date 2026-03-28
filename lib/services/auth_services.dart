import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // LOGIN DENGAN HANDLING ERROR SPESIFIK
  Future<Map<String, dynamic>> loginWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return {'user': result.user, 'error': null};
    } on FirebaseAuthException catch (e) {
      String message = "Terjadi kesalahan";
      if (e.code == 'user-not-found') {
        message = "Email-nya belum terdaftar nih sayang..";
      } else if (e.code == 'wrong-password') {
        message = "Password-nya salah, coba inget-inget lagi ya";
      } else if (e.code == 'invalid-email') {
        message = "Format email-nya salah tuh";
      }
      return {'user': null, 'error': message};
    } catch (e) {
      return {'user': null, 'error': e.toString()};
    }
  }

  // REGISTER TETAP KONSISTEN
  Future<User?> registerWithEmail(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'photoUrl': '',
          'status': 'Love is in the air',
          'roomId': '',
          'partnerId': '',
          'isProfileComplete': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } catch (e) {
      debugPrint("Error Register: ${e.toString()}");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> get userStatus => _auth.authStateChanges();
}