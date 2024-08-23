import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_market_app/model/algolia.dart';
import 'package:the_market_app/widgets.dart';

import '../../constants.dart';
import '../../model/item.dart';
import '../../routes.dart';
// import 'package:algolia/algolia.dart';

///////////////////////////////////////// LOCAL CONSTANTS/WIDGETS /////////////////////////////////////////

///////////////////////////////////////// CONTROLLER/BINDING/UI /////////////////////////////////////////

class SearchPageController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late String uid;
  // late Algolia algolia;
  Algolia algolia = Algolia.init();
  // final applicationId = 'CE11YKVOFD';
  // late String applicationId;
  // final apiKey = '0ad9af2c6a72ad9b90675efa9f0cb905';
  // List<Map<String, dynamic>> dataList = [];
  List<Item> itemList = [];
  final TextEditingController searchTextController = TextEditingController();
  final TextEditingController queryTextController = TextEditingController();
  String get searchQuery => queryTextController.text;

  @override
  void onInit() {
    super.onInit();
    uid = auth.currentUser!.uid;
  }

  Future<void> fetchItems() async {
    try {
      dynamic body = await algolia.query(
          ALGOLIA_INDEX_TO_STRING[AlgoliaIndexes.sellingItemsIndex]!,
          searchQuery);
      itemList = algolia.getItemList(body, false, uid);
    } catch (e) {
      Center(
        child: Text('Error: ${e.toString()}'),
      );
    }
  }
}

class SearchPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<SearchPageController>(SearchPageController());
  }
}

class SearchPage extends GetView<SearchPageController> {
  const SearchPage({Key? key}) : super(key: key);
  final String pageTitle = 'Search';

  @override
  Widget build(BuildContext context) {
    // AppPrefs.algoliaAPIKey = '0ad9af2c6a72ad9b90675efa9f0cb905';
    // AppPrefs.algoliaApplicationId = 'CE11YKVOFD';
    // print(AppPrefs.algoliaAPIKey);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              height: STANDARD_PADDING *
                  5), // TODO: make this padding depend on screen height
          // I think we shouldn't include the Search title but I'll keep it below in case
          // SizedBox(height: 40.0), // space above "Search"
          // Padding(
          //   padding: const EdgeInsets.only(left: 16.0, top: 50.0),
          //   child: Text(
          //     "Search",
          //     style: TextStyle(
          //         fontWeight: FontWeight.w800,
          //         fontSize: 30.0,
          //         letterSpacing: -1.0),
          //   ),
          // ),
          SizedBox(
              height: 10.0), // space between the "Search" and the search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: STANDARD_PADDING),
            child: searchTextField(
                "Search for an item", Icons.search, false, controller),
          ),
          // Scrollable(), child is a Column and inside that is the padding and the Expanded()
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 20.0),
            child: Text(
              "Browse Categories",
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20.0,
                  letterSpacing: -1.0),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns in the grid
                crossAxisSpacing: 8.0, // Spacing between columns
                mainAxisSpacing: 8.0, // Spacing between rows
                childAspectRatio:
                    1.8, // controls how wide vs. tall the boxes are
              ),
              itemCount: 12,
              padding: EdgeInsets.all(16.0),
              itemBuilder: (context, index) {
                return buildCategoryBox(index);
              },
            ),
          ),
          bottomNavigationBar(AppRoutes.searchPage),
          // Other content can be added here
        ],
      ),
    );
  }

  Widget buildCategoryBox(int index) {
    return GestureDetector(
      onTap: () async {
        controller.queryTextController.text = CATEGORY_DISPLAYED[index];
        await controller.fetchItems();
        /* In this one case here the Get.arguments are a list of Items */
        Get.toNamed(AppRoutes.searchExtensionPage,
            arguments: controller.itemList);
      },
      child: Container(
        decoration: BoxDecoration(
          // Use AssetImage to load the image from the assets folder
          image: DecorationImage(
            image: AssetImage(
                ITEM_CATEGORY_IMAGES[index]), // Replace with your image path
            fit: BoxFit.cover, // Adjust the BoxFit property as needed
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.only(bottom: 2.0),
            child: Text(
              CATEGORY_DISPLAYED[index],
              style: TextStyle(
                  color: Colors.white, // Customize the text color
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0),
            ),
          ),
        ),
      ),
    );
  }

  TextField searchTextField(String text, IconData icon, bool isPasswordType,
      SearchPageController controller) {
    return TextField(
      controller: controller.searchTextController,
      obscureText: isPasswordType,
      enableSuggestions: !isPasswordType,
      autocorrect: !isPasswordType,
      cursorColor: Color.fromARGB(255, 157, 157, 157),
      style:
          TextStyle(color: Color.fromARGB(255, 157, 157, 157).withOpacity(0.9)),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 12.0),
        prefixIcon: Icon(icon),
        labelText: text,
        labelStyle: TextStyle(
            color: const Color.fromARGB(255, 157, 157, 157).withOpacity(
                0.9)), // changes how visible the words in the text box before you type in it are
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: const Color.fromARGB(255, 157, 157, 157)
            .withOpacity(0.3), // makes the fill color transparent
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: const BorderSide(width: 0, style: BorderStyle.none)),
      ),
      keyboardType:
          isPasswordType ? TextInputType.visiblePassword : TextInputType.text,
      onSubmitted: (String query) async {
        controller.queryTextController.text = query;
        // query = controller._searchTextController.text;
        await controller.fetchItems();

        Get.toNamed(AppRoutes.searchExtensionPage,
            arguments: controller.itemList);
        // Get.toNamed(AppRoutes.searchExtensionPage, arguments: query);
      },
    );
  }
}
