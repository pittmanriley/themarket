/*
homePage.dart

Defines the home page of the application
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_market_app/widgets.dart';
import '../model/item.dart';
import '../constants.dart';
import '../routes.dart';

///////////////////////////////////////// LOCAL CONSTANTS/WIDGETS /////////////////////////////////////////

final _front = 0;
final _itemsPerSnapshot = 20;
final _maxItems = 100;

///////////////////////////////////////// CONTROLLER/BINDING/UI /////////////////////////////////////////

class HomePageController extends GetxController {
  // late GetArguments getArgs;
  final FirebaseAuth auth = FirebaseAuth.instance;
  late String userUid;

  var itemList = <Item>[];
  var itemListDisp = <Item>[].obs;
  var showSingleView = false.obs;

  late CollectionReference sellingItems;

  @override
  void onInit() async {
    super.onInit();
    userUid = auth.currentUser!.uid;
  }
}

class HomePageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<HomePageController>(HomePageController());
  }
}

class HomePage extends GetView<HomePageController> {
  // HomePage({Key? key}) : super(key: key) {
  //   _stream = reference.snapshots();
  // }
  HomePage({Key? key}) : super(key: key);
  // CollectionReference reference =
  //     FirebaseFirestore.instance.collection("selling_items");
  // late Stream<QuerySnapshot> _stream;
  final String pageTitle = 'The Market';

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    controller.sellingItems = FirebaseFirestore.instance
        .collection(FirebaseCollections.selling_items.string);

    // controller.getArgs = Get.arguments ?? GetArguments();
    return FutureBuilder(
        future: controller.sellingItems.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('');
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (snapshot.hasData) {
            List<DocumentSnapshot> docs = snapshot.data!.docs;
            _configureItemList(docs);
            return _homePageScaffold(screenWidth, screenHeight);
          } else {
            return const Text('no data available');
          }
        });

    // return Scaffold(
    //   appBar: topAppBar(pageTitle),
    //   body: Column(
    //     children: [
    //       buildHomeBody(screenWidth, screenHeight),
    //     ],
    //   ),
    //   floatingActionButton: Padding(
    //     padding: EdgeInsets.only(top: STANDARD_PADDING * 3),
    //     child: _scrollViewButtons(),
    //   ),
    //   floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    //   bottomNavigationBar: bottomNavigationBar(AppRoutes.homePage),
    // );
  }

  /* This function is called every time HOME_PAGE is rebuilt. It adds n documents
     to the front of the list. If the length of ITEM_LIST > MAX_ITEMS, it removes
     n items from the back of the list. */
  void _configureItemList(List<DocumentSnapshot> docs) {
    controller.itemList.clear();
    /* Cannot use the algolia getItemList here because we are Document snapshot queries
       directly from Firebase. We also are not using a search here, but just getting
       the n most recently posted documents. TODO: ensure that the items are actually 
       the most recent and not the earliest */
    for (var doc in docs) {
      String uid = doc[ItemField.uid.string];
      /* disclude items that the current user posted */
      if (uid == controller.userUid) {
        continue;
      }

      String name = doc[ItemField.name.string];
      String sCategory = doc[ItemField.category.string];
      ItemCategory category = ItemCategoryExtension.fromString(sCategory);
      String sCondition = doc[ItemField.condition.string];
      ItemCondition condition = ItemConditionExtension.fromString(sCondition);
      String description = doc[ItemField.description.string];
      List<dynamic> images = doc[ItemField.images.string];
      int price = doc[ItemField.price.string].toInt();

      Item item = Item(
          name: name,
          category: category,
          condition: condition,
          description: description,
          images: images,
          price: price,
          uid: uid);

      controller.itemList.insert(_front, item);
    }
    if (controller.itemList.length > _maxItems) {
      controller.itemList.length -= _itemsPerSnapshot;
    }
  }

  Widget _homePageScaffold(double screenWidth, double screenHeight) {
    return Scaffold(
      appBar: topAppBar(pageTitle),
      body: Column(
        children: [
          buildHomeBody(screenWidth, screenHeight),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(top: STANDARD_PADDING * 3),
        child: _scrollViewButtons(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      bottomNavigationBar: bottomNavigationBar(AppRoutes.homePage),
    );
  }

  // define the toggle view buttons
  Widget _scrollViewButtons() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(Icons.grid_view_rounded),
            onPressed: () {
              controller.showSingleView.value = false;
            },
            color: controller.showSingleView.value ? Colors.grey : Colors.black,
          ),
          IconButton(
            icon: Icon(Icons.view_agenda_rounded),
            onPressed: () {
              controller.showSingleView.value = true;
            },
            color: controller.showSingleView.value ? Colors.black : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget buildHomeBodySnapshot(double screenWidth, double screenHeight) {
    return Expanded(child: Text(''));
  }

  Widget buildHomeBody(double screenWidth, double screenHeight) {
    /*
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Some error occurred"),
            );
          }
          if (snapshot.hasData) {
            QuerySnapshot querySnapshot = snapshot.data;
            List<QueryDocumentSnapshot> documents = querySnapshot.docs;
            List<Map> items = documents.map((e) => e.data() as Map).toList();
            items.shuffle();

            // Display the list in a grid.
            // return _homeGridBuilder(screenWidth, screenHeight, items);
            return Obx(() {
              return controller.showSingleView.value
                  ? _homeSingleGridBuilder(screenWidth, screenHeight, items)
                  : _homeGridBuilder(screenWidth, screenHeight, items);
            });
          }
          return Padding(
            padding: EdgeInsets.only(
                top: STANDARD_PADDING), // Adjust the top padding as needed
            child: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
    */
    return Expanded(
        child: Obx(() => controller.showSingleView.value
            ? _homeSingleGridBuilder(
                screenWidth, screenHeight, controller.itemList)
            : _homeGridBuilder(
                screenWidth, screenHeight, controller.itemList)));
  }

  GetArguments toItemPageGetArgs(Item item) {
    GetArguments getArgs = GetArguments();
    getArgs.item = item;
    getArgs.pageViewType = PageViewType.public;
    return getArgs;
  }

  Widget _homeGridBuilder(
      double screenWidth, double screenHeight, List<Item> items) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Number of items per row
        crossAxisSpacing: STANDARD_PADDING, // Spacing between columns
        mainAxisSpacing: STANDARD_PADDING / 2, // Spacing between rows
        childAspectRatio: screenWidth / (screenHeight / 2), // DO NOT CHANGE
        mainAxisExtent: screenWidth / 2, // DO NOT CHANGE
      ),
      padding: EdgeInsets.only(
          left: STANDARD_PADDING,
          right: STANDARD_PADDING,
          bottom: STANDARD_PADDING,
          top: STANDARD_PADDING * 3),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        // Map itemToDisplay = items[index];
        Item item = items[index];
        GetArguments getArgs = toItemPageGetArgs(item);
        // Return the widget for the grid items
        return buildGridItemBoxes(
            getArgs, index, screenWidth, screenHeight, context);
      },
    );
  }

  Widget _homeSingleGridBuilder(
      double screenWidth, double screenHeight, List<Item> items) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1, // Number of items per row
        crossAxisSpacing: STANDARD_PADDING, // Spacing between columns
        mainAxisSpacing: STANDARD_PADDING / 2, // Spacing between rows
        childAspectRatio: screenWidth / (screenHeight / 2), // DO NOT CHANGE
        mainAxisExtent: screenWidth / 1.25, // DO NOT CHANGE
      ),
      padding: EdgeInsets.only(
          left: STANDARD_PADDING,
          right: STANDARD_PADDING,
          bottom: STANDARD_PADDING,
          top: STANDARD_PADDING * 3),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        // Get the item at this index
        // Map thisItem = items[index];
        Item item = items[index];
        GetArguments getArgs = toItemPageGetArgs(item);
        // Return the widget for the grid items
        return buildSingleItemBoxes(
            getArgs, index, screenWidth, screenHeight, context);
      },
    );
  }
}
