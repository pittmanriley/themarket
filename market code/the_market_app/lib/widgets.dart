/*
widgets.dart

README!
This file defines widgets to be used across the entire application. For widgets referenced 
in only one page, please define them in the page they are referenced.

DEVELOPERS: 
Widget Creation: 
  When adding a new widget to the page, ensure that it is named well or commented
  thoroughly. The reader must understand where and how it is used.
  All widgets will be in camelCaseNotation.

Widget Editing: 
  Often, during development, you may need to change some widgets functionality. Ensure that
  in your branch, when you change the functionality, you save the original widget clearly commented. That
  way, when merge conflicts occur, which they will, we will have a much easier time debugging. 

*/

import 'dart:ffi';

import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:the_market_app/constants.dart';
import 'model/item.dart';
import 'routes.dart';

///////////////////////////////////////////////// CONSTANTS /////////////////////////////////////////////////

const double ICON_BUTTON_VERTICAL_PADDING_SIZE = 16;

///////////////////////////////////////////////// WIDGETS /////////////////////////////////////////////////

// Defines the bar at the top of the page,
PreferredSizeWidget topAppBar(String title) {
  // TODO: wrap AppBar in preferedSize widget to change the size?
  return AppBar(
      centerTitle: false,
      automaticallyImplyLeading: false,
      leading: null,
      title: Text(
        title,
        style: TextStyle(
            color: Colors.black,
            fontSize: TITLE_FONT_SIZE,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0),
      ),
      backgroundColor: Colors.white,
      elevation: STANDARD_ELEVATION * 5,
      actions: <Widget>[
        // DMs button
        IconButton(
            icon: const Icon(Icons.send),
            color: Colors.black,
            onPressed: () {
              Get.toNamed(AppRoutes.messagesPage);
            })
      ]);
}

// Defines the bottom navigation bar for switching between the pages on the bottom
Widget bottomNavigationBar(String currentPage) {
  // var loginButton = const Icon(Icons.login);
  var homePageIcon = Icon(currentPage == AppRoutes.homePage
          ? Icons.home_sharp
          : Icons.home_outlined)
      .obs;

  var searchPageIcon = Icon(currentPage == AppRoutes.searchPage
          ? Icons.search_sharp
          : Icons.search_outlined)
      .obs;

  // TODO: when post page and profile page are created, make them ternary
  // var postPageIcon =
  //     const Icon(Icons.new_label_outlined).obs; // new_label_sharp when on
  var profilePageIcon = Icon(currentPage == AppRoutes.profilePage
          ? Icons.person_sharp
          : Icons.person_outline)
      .obs;
  // const Icon(Icons.person_outlined).obs; // search_sharp when on

  return Padding(
    padding: const EdgeInsets.only(bottom: ICON_BUTTON_VERTICAL_PADDING_SIZE),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Obx(() => IconButton(
            icon: homePageIcon.value, // is this the right icon
            onPressed: () {
              // add check if not on home page because data loading
              if (currentPage == AppRoutes.homePage) {
                return;
              }
              // send to home page (or refresh if already there?)
              // Get.offAndToNamed(AppRoutes.homePage);
              GetArguments getArgs = GetArguments();
              Get.toNamed(AppRoutes.homePage, arguments: getArgs);
              // TODO: manually updating the values, can this be better
              homePageIcon.value = const Icon(Icons.home_sharp);
              searchPageIcon.value = const Icon(Icons.search_outlined);
              // postPageIcon.value = const Icon(Icons.new_label_outlined);
              profilePageIcon.value = const Icon(Icons.person_outlined);
            })),
        Obx(() => IconButton(
            icon: searchPageIcon.value,
            onPressed: () {
              if (currentPage == AppRoutes.searchPage) {
                return;
              }
              // navigate to search page (or refresh if there)
              // Get.offAndToNamed(AppRoutes.searchPage);
              GetArguments getArgs = GetArguments();
              Get.toNamed(AppRoutes.searchPage, arguments: getArgs);
              homePageIcon.value = const Icon(Icons.home_outlined);
              searchPageIcon.value = const Icon(Icons.search_sharp);
              // postPageIcon.value = const Icon(Icons.new_label_outlined);
              profilePageIcon.value = const Icon(Icons.person_outlined);
            })),
        Obx(() => IconButton(
              icon: profilePageIcon.value,
              onPressed: () {
                if (currentPage == AppRoutes.profilePage) {
                  return;
                }
                // send to profile page (or refresh if already there?)
                /*
                Get.offAndToNamed(AppRoutes.profilePage, arguments: [
                  true
                ]); // argument is used if current user is going to their own page
                */
                GetArguments getArgs = GetArguments();
                getArgs.pageViewType = PageViewType.personal;
                Get.toNamed(AppRoutes.profilePage, arguments: getArgs);
                // navigate to profile page
                homePageIcon.value = const Icon(Icons.home_outlined);
                searchPageIcon.value = const Icon(Icons.search_outlined);
                // postPageIcon.value = const Icon(Icons.new_label_outlined);
                profilePageIcon.value = const Icon(Icons.person_sharp);
              },
            )),
      ],
    ),
    // SizedBox(width: screenWidth, height: screenHeight / 32, child: null)
  );
}

// this is a text field that's used in both the login and sign up pages
TextField textField(String text, IconData icon, bool isPasswordType,
    TextEditingController controller) {
  return TextField(
    controller: controller,
    obscureText: isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: Colors.black,
    style: TextStyle(color: Colors.black.withOpacity(0.9)),
    decoration: InputDecoration(
      prefixIcon: Icon(
        icon,
        color: Colors.black.withOpacity(0.9),
      ),
      labelText: text,
      labelStyle: TextStyle(color: Colors.black.withOpacity(0.9)),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: Colors.black.withOpacity(0.15),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(width: 0, style: BorderStyle.none)),
    ),
    keyboardType: isPasswordType
        ? TextInputType.visiblePassword
        : TextInputType.emailAddress,
  );
}

// this is a button used for the login and sign up pages
Container logInSignUpButton(
    BuildContext context, bool isLogin, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      child: Text(isLogin ? "Log In" : "Sign Up",
          style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16)),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black26;
            }
            return Colors.white;
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))),
    ),
  );
}

// used for loading up the items in the search and searchExtensionPage
Widget buildGridItemBoxes(GetArguments getArgs, int index, double screenWidth,
    double screenHeight, BuildContext context) {
  Item item = getArgs.item!;
  return GestureDetector(
    onTap: () {
      // print(itemToDisplay.keys);
      // GetArguments getArgs = GetArguments();

      // getArgs.itemToDisplay = itemToDisplay;
      // getArgs.pageViewType = pageViewType;
      Get.toNamed(AppRoutes.itemPage, arguments: getArgs);
    },
    child: Container(
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(STANDARD_RADIUS)),
      child: Column(children: [
        // the following is commented out for now so I don't have to look at the Firebase errors
        ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(STANDARD_RADIUS),
              topRight: Radius.circular(STANDARD_RADIUS),
              bottomLeft: Radius.circular(STANDARD_RADIUS),
              bottomRight: Radius.circular(STANDARD_RADIUS)),
          child: Image.network(
            // "${getArgs.item?["images"][0]}",
            item.images[0],
            height: screenWidth / 2.75, // DO NOT CHANGE
            width: double.infinity, // DO NOT CHANGE
            fit: BoxFit.cover, // Adjust the fit property as needed
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              top: STANDARD_PADDING / 4,
              left: STANDARD_PADDING / 4,
              right: STANDARD_PADDING / 4,
              bottom: STANDARD_PADDING / 8),
          child: Text(
            // "${truncateDescriptionGridView(getArgs.item?["name"], screenWidth, DESCRIPTION_FONT_SIZE)}",
            truncateNameGridView(item.name, screenWidth, DESCRIPTION_FONT_SIZE),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: DESCRIPTION_FONT_SIZE,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              top: 0,
              left: STANDARD_PADDING / 4,
              right: STANDARD_PADDING / 4,
              bottom: STANDARD_PADDING / 4),
          child: Text(
            // "\$${truncatePrice(getArgs.item?["price"], screenWidth)}",
            "\$${truncatePrice(item.price.toString(), screenWidth)}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: DESCRIPTION_FONT_SIZE,
            ),
          ),
        )
      ]),
    ),
  );
}

// used for loading up the items in the search and searchExtensionPage
Widget buildSingleItemBoxes(GetArguments getArgs, int index, double screenWidth,
    double screenHeight, BuildContext context) {
  Item item = getArgs.item!;
  return GestureDetector(
    onTap: () {
      Get.toNamed(AppRoutes.itemPage, arguments: getArgs);
    },
    child: Container(
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(STANDARD_RADIUS)),
      child: Column(children: [
        // the following is commented out for now so I don't have to look at the Firebase errors
        ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(STANDARD_RADIUS),
              topRight: Radius.circular(STANDARD_RADIUS),
              bottomLeft: Radius.circular(STANDARD_RADIUS),
              bottomRight: Radius.circular(STANDARD_RADIUS)),
          child: Image.network(
            // "${item["images"][0]}",
            item.images[0],
            height: screenWidth / 1.5, // DO NOT CHANGE
            width: double.infinity, // DO NOT CHANGE
            fit: BoxFit.cover, // Adjust the fit property as needed
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              top: STANDARD_PADDING / 4,
              left: STANDARD_PADDING / 4,
              right: STANDARD_PADDING / 4,
              bottom: STANDARD_PADDING / 8),
          child: Text(
            // "${truncateDescriptionSingleView(item["name"], screenWidth, DESCRIPTION_FONT_SIZE)}",
            truncateNameSingleView(
                item.name, screenWidth, DESCRIPTION_FONT_SIZE),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: DESCRIPTION_FONT_SIZE,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              top: 0,
              left: STANDARD_PADDING / 4,
              right: STANDARD_PADDING / 4,
              bottom: STANDARD_PADDING / 4),
          child: Text(
            // "\$${truncatePrice(item["price"], screenWidth)}",
            "\$${truncatePrice(item.price.toString(), screenWidth)}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: DESCRIPTION_FONT_SIZE,
            ),
          ),
        )
      ]),
    ),
  );
}

String truncateNameGridView(String name, double screenWidth, double fontSize) {
  const int maxLength = 15; // Set your desired maximum length
  int maxChars = (screenWidth / (fontSize)).floor();
  maxChars = (maxChars / 2.5).floor();

  return (name.length > maxChars) ? '${name.substring(0, maxChars)}...' : name;
}

String truncateNameSingleView(
    String name, double screenWidth, double fontSize) {
  const int maxLength = 15; // Set your desired maximum length
  final maxChars = (screenWidth / (fontSize)).floor();

  return (name.length > maxChars) ? '${name.substring(0, maxChars)}...' : name;
}

String truncatePrice(String price, double screenWidth) {
  const int maxLength = 7; // Set your desired maximum length
  return (price.length > maxLength)
      ? '${price.substring(0, maxLength)}...'
      : price;
}

String convertListToString(List<String> list) {
  return list.join(" ");
}

Widget errorPageDisplay() {
  return const Scaffold(body: Text('Error, no user to display'));
}
