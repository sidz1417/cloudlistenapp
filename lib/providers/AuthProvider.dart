import 'package:cloudlisten/widgets/ErrorDialog.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool _isNewUser;

  bool get newUserStatus=>_isNewUser;
  
  set newUserStatus(bool isNewUser){
    _isNewUser = isNewUser;
    notifyListeners();
  }

  bool get loadingStatus => _isLoading;

  set loadingStatus(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  Stream<String> onAuthStateChanged() {
    return _firebaseAuth.onAuthStateChanged
        .map((user) => (user != null) ? user.uid : '');
  }

  void signIn(
      {@required String email,
      @required String password,
      @required BuildContext context}) async {
    try {
      loadingStatus = true;
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      loadingStatus = false;
    } catch (error) {
      errorDialog(
          context: context,
          errorTitle: "Auth Error",
          errorMessage: error.message);
      loadingStatus = false;
    }
  }

  void signUp(
      {@required String email,
      @required String password,
      @required BuildContext context}) async {
    try {
      loadingStatus = true;
      newUserStatus = true;
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      loadingStatus = false;
    } catch (error) {
      errorDialog(
          context: context,
          errorTitle: "Auth Error",
          errorMessage: error.message);
       loadingStatus = false;
    }
  }

  void signOut() async {
    await _firebaseAuth.signOut();
  }
}

