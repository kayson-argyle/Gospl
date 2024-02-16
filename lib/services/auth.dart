import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:gospl/main.dart';
import 'package:gospl/models/user.dart';

class AuthService {
  AppUser? _userFromFirebaseUser(User? user, {String? username}) {
    return user != null ? AppUser(uid: user.uid, name: username ?? user.displayName ?? '') : null;
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? firebaseUser;

  //auth change user stream
  Stream<AppUser?> get user {
    return _auth.authStateChanges().map((User? user) {
      firebaseUser = user;
      return _userFromFirebaseUser(user);
    });
  }

  //sign in with email and pwd
  Future<AppUser?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      isar.writeTxn(() async {
        isar.appUsers.put(AppUser(uid: user!.uid, name: user.displayName ?? 'auth.dart error'));
      });

      return _userFromFirebaseUser(user);
    } catch (e) {
      return null;
    }
  }

  //register with email and pwd
  Future<AppUser?> registerWithEmailAndPassword(String email, String password, String username) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      user?.updateDisplayName(username);
      isar.writeTxn(() async {
        await isar.appUsers.put(AppUser(uid: user!.uid, name: username));
      });

      log('typed: $username');
      log("saved: ${user?.displayName}");
      return _userFromFirebaseUser(user, username: username);
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  //sign out
  Future signOut() async {
    try {
      isar.writeTxn(() async {
        await isar.appUsers.put(AppUser(uid: 'none', name: 'none'));
      });
      return await _auth.signOut();
    } catch (e) {
      return null;
    }
  }

  //delete account
  Future deleteWithEmailAndPassword({required String email, required String password}) async {
    try {
        UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
        User? user = result.user;
        return await user!.delete();
      
    } catch (e) {
      return e;
    }
  }
}
