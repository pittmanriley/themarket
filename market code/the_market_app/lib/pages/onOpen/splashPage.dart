/* 
 * name: splashPage.dart
 * summary: creates the boot up screen (formally called splash screen)
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:the_market_app/pages/homePage.dart';
import 'package:the_market_app/pages/onOpen/loginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:the_market_app/routes.dart';

class SplashPageController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Future.delayed(const Duration(seconds: 1), () {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // User is signed in, navigate to the main content
        Get.offAndToNamed(AppRoutes.homePage);
      } else {
        // No user signed in, navigate to the login page
        Get.offAndToNamed(AppRoutes.loginPage);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }
}

class SplashPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<SplashPageController>(SplashPageController());
  }
}

class SplashPage extends StatelessWidget {
  SplashPageController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(
            'assets/images/logo.png',
            height: 250,
            width: 270,
          )
        ]),
      ),
    );
  }
}
/*

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => LoginPage(),
      ));
    });
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(
            'assets/images/logo.png',
            height: 250,
            width: 270,
          )
          // const Text('The Market',
          //     style: TextStyle(
          //         fontStyle: FontStyle.normal,
          //         color: Colors.black,
          //         fontSize: 30,
          //         fontWeight: FontWeight.w800,
          //         letterSpacing: -1.0))
        ]),
      ),
    );
  }
}
*/
