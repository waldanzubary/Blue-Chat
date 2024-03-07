import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;  

  Future<UserCredential> signInWithEmailandPassword(String email, String password,) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword
      (email: email, password: password);

      _firestore.collection('Users').doc(userCredential.user!.uid).set({
          'uid' : userCredential.user!.uid,
          'email' : email,
          
        }, SetOptions(merge: true)
        );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }
  //ini buat regis
  Future<UserCredential> signUpWithEmailandPassword(String email, String password, String username) async {
  try{
    UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email, 
      password: password,
    );

    await userCredential.user!.updateDisplayName(username); // Menambahkan displayName

    _firestore.collection('Users').doc(userCredential.user!.uid).set({
      'uid' : userCredential.user!.uid,
      'email' : email,
      'username': username,
    });

    return userCredential;
  } on FirebaseAuthException catch (e) {
    throw Exception(e.code);
  }
}
  //yang ini buat login nya
  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }
}