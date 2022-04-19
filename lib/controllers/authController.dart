import 'package:cadevo/constants/firebase.dart';
import 'package:cadevo/models/user.dart';
import 'package:cadevo/screens/authentication/auth.dart';
import 'package:cadevo/screens/home/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  RxBool isLoggedIn = false.obs;
  Rx<User> firebaseUser;
  Rx<UserModel> userModel;

  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtpassword = TextEditingController();
  TextEditingController txtname = TextEditingController();

  @override
  void onReady() {
    super.onReady();
    firebaseUser = Rx<User>(auth.currentUser);
    firebaseUser.bindStream(auth.userChanges());

    ever(firebaseUser, (s) {
      _setInitialScreen();
    });
  }

  _setInitialScreen() {
    if (!isLoggedIn.value) {
      Get.offAll(() => AuthenticationScreen());
    } else {
      Get.offAll(() => HomeScreen());
    }
  }

  singIn() async {
    try {
      await auth
          .signInWithEmailAndPassword(
              email: txtEmail.text.trim(), password: txtpassword.text)
          .then((value) {
        initUserModel(value.user.uid);
      });
    } catch (e) {
      Get.snackbar("Sign-In Failed", "Invalid Credentials");
    }
  }

  singOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      Get.snackbar("Sign-out Failed", "Something went wrong!");
    }
  }

  singUp() async {
    try {
      await auth
          .createUserWithEmailAndPassword(
              email: txtEmail.text.trim(), password: txtpassword.text)
          .then((value) => () {
                String userID = value.user.uid;
                Map<String, dynamic> map = <String, dynamic>{
                  "Name": txtname.text.trim(),
                  "Email": txtEmail.text.trim(),
                  "Password": txtpassword.text.trim(),
                };

                firebaseFirestore
                    .collection(userCollection)
                    .doc(userID)
                    .set(map);
                initUserModel(userID);
              });
    } catch (e) {
      Get.snackbar("Registration Failed", "Something went Wrong");
    }
  }

  initUserModel(String uid) async {
    userModel.value = await firebaseFirestore
        .collection(userCollection)
        .doc(uid)
        .get()
        .then((value) => UserModel.fromSnapshot(value));
  }
}
