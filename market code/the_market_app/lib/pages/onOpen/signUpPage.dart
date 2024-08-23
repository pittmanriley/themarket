import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_market_app/constants.dart';
import '../../routes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../widgets.dart';

class SignUpPageController extends GetxController {
  late TextEditingController emailTextController;
  late TextEditingController passwordTextController;
  late TextEditingController confirmPasswordTextController;
  late TextEditingController usernameTextController;
  @override
  void onInit() {
    super.onInit();
    emailTextController = TextEditingController();
    passwordTextController = TextEditingController();
    confirmPasswordTextController = TextEditingController();
    usernameTextController = TextEditingController();
  }
}

class SignUpPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<SignUpPageController>(SignUpPageController());
  }
}

class SignUpPage extends GetView<SignUpPageController> {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TextEditingController _userNameTextController = TextEditingController();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.offAndToNamed(AppRoutes.loginPage);
          },
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(color: Colors.white),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).size.height * 0.2,
              20,
              0,
            ),
            child: Column(
              children: <Widget>[
                SizedBox(height: STANDARD_PADDING / 1.5),
                textField(
                  "Enter Username",
                  Icons.person_outline,
                  false,
                  controller.usernameTextController,
                ),
                /*
                TextField(
                    controller: __usernameTextController,
                    cursorColor: Colors.black,
                    style: TextStyle(color: Colors.black.withOpacity(0.9)),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person_outline,
                          color: Colors.black.withOpacity(0.9)),
                      labelText: "Enter Username",
                    ),
                    onChanged: (value) {
                      __usernameTextController.text = value;
                    }),
                    */
                SizedBox(height: STANDARD_PADDING / 1.5),
                textField(
                  "Enter Stanford Email",
                  Icons.mail_outline,
                  false,
                  controller.emailTextController,
                ),
                SizedBox(height: STANDARD_PADDING / 1.5),
                textField(
                  "Enter Password",
                  Icons.lock_outline,
                  true,
                  controller.passwordTextController,
                ),
                SizedBox(height: STANDARD_PADDING / 1.5),
                textField(
                  "Confirm Password",
                  Icons.lock_outline,
                  true,
                  controller.confirmPasswordTextController,
                ),
                SizedBox(height: STANDARD_PADDING / 2),
                logInSignUpButton(context, false, () async {
                  // Custom email validation
                  if (!controller.emailTextController.text
                      .endsWith("@stanford.edu")) {
                    // Invalid email format
                    Get.snackbar(
                      'Invalid Email',
                      'Email must be a valid Stanford email',
                      snackPosition: SnackPosition.BOTTOM,
                      colorText: Colors.white,
                      backgroundColor: Colors.red,
                    );
                    return;
                  }
                  // Function to check if an email is already taken
                  Future<bool> isEmailAlreadyTaken(String email) async {
                    QuerySnapshot querySnapshot = await FirebaseFirestore
                        .instance
                        .collection('users')
                        .where('email', isEqualTo: email)
                        .get();
                    return querySnapshot.docs.isNotEmpty;
                  }

                  // Check if the email has been used before
                  bool isEmailTaken = await isEmailAlreadyTaken(
                      controller.emailTextController.text);
                  if (isEmailTaken) {
                    Get.snackbar(
                      'Email already in use',
                      'This email is already associated with an account.',
                      snackPosition: SnackPosition.BOTTOM,
                      colorText: Colors.white,
                      backgroundColor: Colors.red,
                    );
                    return;
                  }

                  // Function to check if a username is already taken
                  Future<bool> isUsernameAlreadyTaken(String username) async {
                    QuerySnapshot querySnapshot = await FirebaseFirestore
                        .instance
                        .collection('users')
                        .where('username', isEqualTo: username)
                        .get();
                    return querySnapshot.docs.isNotEmpty;
                  }

                  // Check if the username has been used before
                  bool isUsernameTaken = await isUsernameAlreadyTaken(
                      controller.usernameTextController.text);
                  if (isUsernameTaken) {
                    Get.snackbar(
                      'Username already taken',
                      'This username is already in use. Please choose another.',
                      snackPosition: SnackPosition.BOTTOM,
                      colorText: Colors.white,
                      backgroundColor: Colors.red,
                    );
                    return;
                  }

                  // Custom username strength validation
                  if (controller.usernameTextController.text.length < 6) {
                    // username is too short
                    Get.snackbar(
                      'Username too short',
                      'Username must be at least 6 characters long.',
                      snackPosition: SnackPosition.BOTTOM,
                      colorText: Colors.white,
                      backgroundColor: Colors.red,
                    );
                    return;
                  }

                  // Custom password strength validation
                  if (controller.passwordTextController.text.length < 8) {
                    // Password is too short
                    Get.snackbar(
                      'Weak Password',
                      'Password must be at least 8 characters long.',
                      snackPosition: SnackPosition.BOTTOM,
                      colorText: Colors.white,
                      backgroundColor: Colors.red,
                    );
                    return;
                  }
                  // ignore: unrelated_type_equality_checks
                  if (controller.confirmPasswordTextController.text !=
                      controller.passwordTextController.text) {
                    // Passwords do not match
                    Get.snackbar(
                      'Passwords do not match',
                      '',
                      snackPosition: SnackPosition.BOTTOM,
                      colorText: Colors.white,
                      backgroundColor: Colors.red,
                    );
                    return;
                  }

                  // Continue with user creation if email and password are valid
                  try {
                    UserCredential userCredential = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                      email: controller.emailTextController.text,
                      password: controller.passwordTextController.text,
                    );

                    // Send email verification
                    await userCredential.user!.sendEmailVerification();

                    // Inform the user to check their email for verification
                    // TODO: figure out how to not initialize the user in firebase before they are verified
                    Get.snackbar(
                      'Email Verification',
                      'A verification email has been sent to ${controller.emailTextController.text}. Please verify your email before logging in.',
                      snackPosition: SnackPosition.BOTTOM,
                      colorText: Colors.white,
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 4),
                    );
                    String? fcmToken =
                        await FirebaseMessaging.instance.getToken();

                    // Save user info to Firestore
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userCredential.user!.uid)
                        .set({
                      'uid': userCredential.user!.uid,
                      'email': controller.emailTextController.text,
                      'username': controller.usernameTextController.text,
                      'fcmToken': fcmToken
                    });

                    // You can choose to navigate to the home page or display a message here
                    Get.offAndToNamed(
                      AppRoutes.loginPage,
                    );
                  } catch (error) {
                    // print("Error: ${error.toString()}");
                    Get.snackbar(
                      'Error',
                      '${error.toString()}',
                      snackPosition: SnackPosition.BOTTOM,
                      colorText: Colors.white,
                      backgroundColor: Colors.red,
                    );
                    return;

                    // Handle other authentication errors as needed
                    // You can display appropriate error messages using Get.snackbar or other methods
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
