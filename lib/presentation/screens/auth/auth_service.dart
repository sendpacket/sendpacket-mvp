import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> createUserWithEmailAndPassword(
      String email,
      String password, {
        String? firstName,
        String? lastName,
      }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          "firstName": firstName ?? "",
          "lastName": lastName ?? "",
          "email": email,
          "joinDate": FieldValue.serverTimestamp(),
          "isVerified": true,
          "isSuspended": false,
          "role": "user",
          "profileImage": "",
          "phone": "",
        });
      }

      return user;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<User?> loginUserWithEmailAndPassword(
      String email,
      String password,
      ) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<void> signout() async {
    await _auth.signOut();
  }
}
