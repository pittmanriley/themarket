import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_market_app/model/appPrefs.dart';
import 'package:the_market_app/pages/itemPage.dart';
import 'package:the_market_app/pages/onOpen/loginPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:the_market_app/pages/messaging/messagesPage.dart';
import 'package:the_market_app/pages/profile/newPost.dart';
import 'package:the_market_app/pages/profile/newPostPage.dart';
import 'package:the_market_app/pages/profile/profilePage.dart';
import 'package:the_market_app/pages/search/searchExtensionPage.dart';
import 'package:the_market_app/pages/settings/reportUserPage.dart';
import 'package:the_market_app/pages/settings/settingsPage.dart';
import 'package:the_market_app/pages/onOpen/signUpPage.dart';
import 'package:the_market_app/pages/settings/privacyPolicyPage.dart';
import 'pages/homePage.dart';
import 'pages/search/searchPage.dart';
import 'routes.dart';
import 'pages/onOpen/splashPage.dart';
import 'package:the_market_app/pages/settings/termsOfServicePage.dart';
import 'notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      // for the lines below: I thought we needed them earlier, but not sure if we need them
      // anymore. It's working without them, but don't remove just yet

      // options: const FirebaseOptions(
      //   apiKey: "AIzaSyDSsA80Jxcbsxq3ATrU_BNx9Ai519GamLE",
      //   appId: "1:446302672981:android:d8f3dc69b5c67c6f8a1cdc",
      //   messagingSenderId: "446302672981",
      //   projectId: "the-ma-53488",
      // ),
      );
  // await AppPrefs.init();
//   await Notifications().initNotifications();
  await AppPrefs.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // const MyApp({Key?: key}) : super(key: key);
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: 'The Market',
        initialRoute: AppRoutes.splashPage,
        initialBinding: SplashPageBinding(),
        getPages: _getRoutes());
  }
}

_getRoutes() {
  return [
    GetPage(
        name: AppRoutes.splashPage,
        page: () => SplashPage(),
        binding: SplashPageBinding(),
        transition: Transition.noTransition),
    GetPage(
        name: AppRoutes.homePage,
        page: () => HomePage(),
        binding: HomePageBinding(),
        transition: Transition.noTransition),
    GetPage(
        name: AppRoutes.searchPage,
        page: () => const SearchPage(),
        binding: SearchPageBinding(),
        transition: Transition.noTransition),
    GetPage(
        name: AppRoutes.loginPage,
        page: () => LoginPage(),
        binding: LoginPageBinding(),
        transition: Transition.noTransition),
    GetPage(
        name: AppRoutes.signUpPage,
        page: () => const SignUpPage(),
        binding: SignUpPageBinding(),
        transition: Transition.noTransition),
    GetPage(
        name: AppRoutes.profilePage,
        page: () => const ProfilePage(),
        binding: ProfilePageBinding(),
        transition: Transition.noTransition),
    GetPage(
        name: AppRoutes.newPostPage,
        page: () => const NewPostPage(),
        binding: NewPostPageBinding(),
        transition: Transition.noTransition),
    GetPage(
        name: AppRoutes.messagesPage,
        page: () => const MessagesPage(),
        binding: MessagesPageBinding(),
        transition: Transition.noTransition),
    GetPage(
        name: AppRoutes.settingsPage,
        page: () => const SettingsPage(),
        binding: SettingsPageBinding(),
        transition: Transition.noTransition),
    GetPage(
        name: AppRoutes.itemPage,
        page: () => const ItemPage(),
        binding: ItemPageBinding(),
        transition: Transition.noTransition),
    GetPage(
        name: AppRoutes.searchExtensionPage,
        page: () => const SearchExtensionPage(),
        binding: SearchExtensionPageBinding(),
        transition: Transition.noTransition),
    /*
    GetPage(
        name: AppRoutes.editProfilePage,
        page: () => EditProfilePage(),
        binding: EditProfilePageBinding(),
        transition: Transition.noTransition),
    */
    GetPage(
        name: AppRoutes.privacyPolicyPage,
        page: () => const PrivacyPolicyPage(),
        binding: PrivacyPolicyPageBinding(),
        transition: Transition.noTransition),
    GetPage(
        name: AppRoutes.termsOfServicePage,
        page: () => const TermsOfServicePage(),
        binding: TermsOfServicePageBinding(),
        transition: Transition.noTransition),
    GetPage(
        name: AppRoutes.reportUserPage,
        page: () => const ReportUserPage(),
        binding: ReportUserPageBinding(),
        transition: Transition.noTransition),
    // GetPage(
    //     name: AppRoutes.newPostSelectImagesPage,
    //     page: () => const NewPostPage(),
    //     binding: NewPostPageBinding(),
    //     transition: Transition.noTransition),
    // GetPage(
    //     name: AppRoutes.newPostConfigurePage,
    //     page: () => const NewPostConfigurePage(),
    //     binding: NewPostConfigurePageBinding(),
    //     transition: Transition.noTransition),
  ];
}
