import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart';
import '../../constants.dart';
import '../../routes.dart';

///////////////////////////////////////// LOCAL CONSTANTS/WIDGETS /////////////////////////////////////////

///////////////////////////////////////// CONTROLLER/BINDING/UI /////////////////////////////////////////

class SettingsPageController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // populate item list
  }
}

class SettingsPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<SettingsPageController>(SettingsPageController());
  }
}

class SettingsPage extends GetView<SettingsPageController> {
  const SettingsPage({Key? key}) : super(key: key);
  final String pageTitle = 'Search';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Settings",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            GetArguments getArgs = GetArguments();
            Get.toNamed(AppRoutes.homePage, arguments: getArgs);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(STANDARD_PADDING),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, // Set the background color
              borderRadius:
                  BorderRadius.circular(10.0), // Set the border radius
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5), // Set the shadow color
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 2), // changes the shadow direction
                ),
              ],
            ),
            child: Column(
              children: [
                _settingsCategoryBuilder('Report a User', context,
                    '/reportUserPage', Icons.emoji_flags),
                _dividerBuilder(),
                _settingsCategoryBuilder("Privacy Policy", context,
                    '/privacyPolicyPage', Icons.lock_outlined),
                _dividerBuilder(),
                _settingsCategoryBuilder('Terms of Service', context,
                    '/termsOfServicePage', Icons.description_outlined),
                _dividerBuilder(),
                _logoutButton(context)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: STANDARD_PADDING, right: STANDARD_PADDING),
      child: ListTile(
        leading: Icon(Icons.logout),
        title: Text('Logout'),
        onTap: () async {
          bool confirmLogout = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Logout"),
                content: Text("Are you sure you want to logout?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop(false); // Dismiss the dialog and return false
                    },
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop(true); // Dismiss the dialog and return true
                    },
                    child: Text("Logout"),
                  ),
                ],
              );
            },
          );

          // If the user confirms the logout, proceed with the logout logic
          if (confirmLogout == true) {
            try {
              await FirebaseAuth.instance.signOut();
              Get.offAllNamed(AppRoutes.loginPage);
            } catch (e) {
              // Handle errors, if any
              Center(child: Text("Error logging out"));
            }
          }
        },
      ),
    );
  }

  Widget _dividerBuilder() {
    return Padding(
      padding: EdgeInsets.only(left: STANDARD_PADDING, right: STANDARD_PADDING),
      child: Divider(),
    );
  }

  Widget _settingsCategoryBuilder(
      String category, BuildContext context, String route, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(left: STANDARD_PADDING, right: STANDARD_PADDING),
      child: ListTile(
        leading: Icon(icon),
        title: Text(category),
        onTap: () {
          Navigator.pushNamed(context, route);
        },
      ),
    );
  }
}
