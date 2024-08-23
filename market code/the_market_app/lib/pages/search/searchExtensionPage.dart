/*
This page is not to be confused with the searchPage.dart. This page is what pops
up when a user types in a query or clicks on a category icon in the search page. 
*/
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_market_app/widgets.dart';
import '../../constants.dart';
import '../../model/item.dart';

class SearchExtensionPageController extends GetxController {
  List<Item> itemList = [];
  @override
  void onInit() {
    super.onInit();
  }
}

class SearchExtensionPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<SearchExtensionPageController>(SearchExtensionPageController());
  }
}

class SearchExtensionPage extends GetView<SearchExtensionPageController> {
  const SearchExtensionPage({Key? key}) : super(key: key);
  final String pageTitle = 'The Market';

  @override
  Widget build(BuildContext context) {
    controller.itemList = Get.arguments;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          color: Colors.black,
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            // Get.toNamed(AppRoutes.homePage);
            Get.back();
          },
        ),
      ),
      body: controller.itemList.isEmpty
          ? Center(
              child: Text(
              "No items yet!",
              style: TextStyle(
                  fontSize: DESCRIPTION_FONT_SIZE * 1.5,
                  fontWeight: FontWeight.bold),
            ))
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of items per row
                crossAxisSpacing: STANDARD_PADDING, // Spacing between columns
                mainAxisSpacing: STANDARD_PADDING / 2, // Spacing between rows
                childAspectRatio:
                    screenWidth / (screenHeight / 2), // DO NOT CHANGE
                mainAxisExtent: screenWidth / 2, // DO NOT CHANGE
              ),
              padding: EdgeInsets.only(
                  left: STANDARD_PADDING,
                  right: STANDARD_PADDING,
                  bottom: STANDARD_PADDING,
                  top: STANDARD_PADDING / 2),
              itemCount: controller.itemList.length,
              itemBuilder: (BuildContext context, int index) {
                // Get the item at this index
                // Map itemToDisplay = data[index];
                Item itemToDisplay = controller.itemList[index];
                GetArguments getArgs = toItemPageGetArgs(itemToDisplay);
                // final description = thisItem["description"] ?? "No Name";
                // var thisItem = snapshot.data!.docs[index];
                // Return the widget for the grid items
                return buildGridItemBoxes(
                    getArgs, index, screenWidth, screenHeight, context);
              },
            ),
    );
  }

  GetArguments toItemPageGetArgs(Item itemToDisplay) {
    GetArguments getArgs = GetArguments();
    // getArgs.email = controller.userData[UserCollectionFields.email];
    getArgs.item = itemToDisplay;
    // getArgs.uid = controller.uid;
    // getArgs.username = controller.username;
    // getArgs.profilePictureUrl = controller.profilePictureUrl.value;
    getArgs.pageViewType = PageViewType.public;
    return getArgs;
  }
}
