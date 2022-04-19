import 'package:cadevo/constants/firebase.dart';
import 'package:cadevo/screens/authentication/auth.dart';
import 'package:cadevo/screens/home/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  RxBool isLoggedIn = false.obs;
  Rx<User> firebaseUser;
  Rx<UserModel> userModel;

  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtpassword = TextEditingController();
  TextEditingController txtname = TextEditingController();

  TextEditingController txtName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();

  Rx<User> firebaseUser;

  @override
  void onReady() {
    firebaseUser = Rx<User>(auth.currentUser);
    firebaseUser.bindStream(auth.userChanges());
    ever(firebaseUser, (user) {
      _setInitialScreen(user);
    });
    super.onReady();
  }

  _setInitialScreen(User user) {
    if (user == null) {
      Get.offAll(() => AuthenticationScreen());
    } else {
      Get.offAll(() => HomeScreen());
    }
  }

  Widget circular() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  signInUser() async {
    Get.dialog(circular(), barrierDismissible: false);
    String email = txtEmail.text.trim();
    String password = txtPassword.text;
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      Get.back();
      Get.snackbar("Authentication Error", "Invalid Email or Password");
    }
  }

  signOut() async {
    await auth.signOut();
  }

  signUp() async {
    Get.dialog(circular(), barrierDismissible: false);
    String name = txtName.text.trim();
    String email = txtEmail.text.trim();
    String password = txtPassword.text;
    try {
      await auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        Map<String, dynamic> mapp = {
          "UID": value.user.uid,
          "Name": name,
          "Email": email,
          "Password": password,
        };

        await firebaseFirestore
            .collection(userCollection)
            .doc(value.user.uid)
            .set(mapp);
      });
    } catch (e) {
      Get.back();
      Get.snackbar("REgistration Failed", e.toString());
    }
  }
}
