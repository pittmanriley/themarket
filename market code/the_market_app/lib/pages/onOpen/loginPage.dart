import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_market_app/constants.dart';
import '../../routes.dart';
import '../../widgets.dart';

class LoginPageController extends GetxController {
  late TextEditingController emailTextController;
  late TextEditingController passwordTextController;

  @override
  void onInit() {
    super.onInit();
    emailTextController = TextEditingController();
    passwordTextController = TextEditingController();
  }
}

class LoginPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<LoginPageController>(LoginPageController());
  }
}

class LoginPage extends GetView<LoginPageController> {
// class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);
  // final LoginPageController controller = Get.find();

  // get transition => null;

  @override
  Widget build(BuildContext context) {
    // TextEditingController passwordTextController = TextEditingController();
    // TextEditingController emailTextController = TextEditingController();
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(color: Colors.white),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                STANDARD_PADDING, screenHeight * 0.2, STANDARD_PADDING, 0),
            child: Column(
              children: <Widget>[
                Image.asset(
                  'assets/images/logo.png',
                  height: screenHeight / 4,
                  width: screenWidth / 1.5,
                  alignment: Alignment.center,
                ),
                SizedBox(
                  height: STANDARD_PADDING,
                ),
                textField(
                  "Enter Email",
                  Icons.person_outline,
                  false,
                  controller.emailTextController,
                ),
                /*
                TextField(
                  controller: controller.emailTextController,
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.black.withOpacity(0.9)),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person_outline,
                        color: Colors.black.withOpacity(0.9)),
                    labelText: "Enter Email",
                  ),
                ),
                */
                SizedBox(
                  height: 10,
                ),
                textField("Enter Password", Icons.lock_outline, true,
                    controller.passwordTextController),
                logInSignUpButton(context, true, () async {
                  try {
                    UserCredential userCredential =
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: controller.emailTextController.text,
                      password: controller.passwordTextController.text,
                    );
                    if (!userCredential.user!.emailVerified) {
                      Get.snackbar(
                        'Email Verification Required',
                        'Please verify your email before logging in.',
                        snackPosition: SnackPosition.BOTTOM,
                        colorText: Colors.white,
                        backgroundColor: Colors.red,
                      );
                      // Optionally, you can sign the user out to prevent further access
                      await FirebaseAuth.instance.signOut();
                      return;
                    }

                    // Navigate to the home page if the user is signed in successfully

                    // Save user info to Firestore
                    // await FirebaseFirestore.instance
                    //     .collection('users')
                    //     .doc(userCredential.user!.uid)
                    //     .set({
                    //   'uid': userCredential.user!.uid,
                    //   'email': controller.emailTextController.text,
                    //   'username': controller.usernameTextController.text
                    // });

                    Get.offAndToNamed(AppRoutes.homePage);
                  } on FirebaseAuthException catch (e) {
                    switch (e.code) {
                      case "invalid-email":
                      case "user-not-found":
                        Get.snackbar(
                          'Email error',
                          '${e.toString()}',
                          snackPosition: SnackPosition.BOTTOM,
                          colorText: Colors.white,
                          backgroundColor: Colors.red,
                        );
                        return;
                      default:
                        Get.snackbar(
                          'Login Failed',
                          'A login error occurred. Please try again.',
                          snackPosition: SnackPosition.BOTTOM,
                          colorText: Colors.white,
                          backgroundColor: Colors.red,
                        );
                    }
                  }
                }),
                signUpOption()
              ],
            ),
          ),
        ),
      ),
    );
  }

  // display the text underneath the username and password texts to allow users to sign up if they haven't already
  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(color: Colors.black),
        ),
        TextButton(
          onPressed: () {
            Get.offAndToNamed(AppRoutes.signUpPage);
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// Image logoWidget(String imageName, Size size) {
//   return Image.asset(imageName, fit: BoxFit.fitWidth, width: 300, height: 300);
// }
