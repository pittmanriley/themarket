import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:the_market_app/routes.dart';
import '../constants.dart';
import 'package:the_market_app/pages/messaging/chatPage.dart';
import 'package:dots_indicator/dots_indicator.dart';

import '../model/item.dart';

class ItemPageController extends GetxController {
  // to check to see if item is your own item

  late GetArguments getArgs;
  late PageViewType pageViewType;

  // for displaying the data
  late CollectionReference users;
  // late Map<String, dynamic> userData;
  late Item? itemToDisplay;
  late String email;
  late String username;
  late String profilePictureUrl;
  late String uid;
  late RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // populate item list
  }

  String imageURL = ''.obs.value;
  var isBookmarked = false.obs;
  void toggleBookmark() {
    isBookmarked.toggle();
  }

  // on every navigation to item page, controller data is configured with getArgs
  void configureControllerData() {
    pageViewType = getArgs.pageViewType ?? PageViewType.public;
    itemToDisplay = getArgs.item;
    email = getArgs.email ?? '';
    uid = getArgs.uid ?? '';
    profilePictureUrl = getArgs.profilePictureUrl ?? '';
    username = getArgs.username ?? '';
  }
}

class ItemPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ItemPageController>(ItemPageController());
  }
}

class ItemPage extends GetView<ItemPageController> {
  const ItemPage({Key? key}) : super(key: key);
  final String pageTitle = 'The Market';

  @override
  Widget build(BuildContext context) {
    // final dynamic thisItem = Get.arguments;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // controller.itemToDisplay = Get.arguments;
    controller.getArgs = Get.arguments ?? GetArguments();
    controller.configureControllerData();

    // no need to grab data if we already have it
    if (controller.uid != '' &&
        controller.email != '' &&
        controller.username != '') {
      return _itemPageScaffold(context, screenWidth, screenHeight);
    } else {
      controller.users = FirebaseFirestore.instance
          .collection(FirebaseCollections.users.string);
      return FutureBuilder(
          future: controller.users
              .where(UserCollectionFields.uid.string,
                  isEqualTo: controller.itemToDisplay!.uid)
              .get(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: Text(
                      '')); // TODO: replace with loading circle or some sheeyat
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              // var querySnapshot = snapshot.data![0] as QuerySnapshot;
              if (snapshot.data!.docs.isNotEmpty) {
                var userDocument = snapshot.data!.docs.first;
                // controller.userData = userDocument.data() as Map<String, dynamic>;
                Map<String, dynamic> userData =
                    userDocument.data() as Map<String, dynamic>;
                // controller.userData = userData;
                controller.email = userData[UserCollectionFields.email.string];
                controller.uid = userData[UserCollectionFields.uid.string];
                controller.profilePictureUrl =
                    userData[UserCollectionFields.profilePicture.string];
                controller.username =
                    userData[UserCollectionFields.username.string];
                return _itemPageScaffold(context, screenWidth, screenHeight);
              } else {
                return Text("snapshot returned but no data");
              }
            } else {
              return Text("No data available");
            }
          });
    }
  }

  Widget _itemPageScaffold(
    BuildContext context,
    double screenWidth,
    double screenHeight,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // don't want the app bar to look separate from the page
        leading: IconButton(
          color: Colors.black,
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          _buildTopRow(context, screenWidth),
          const Padding(padding: EdgeInsets.only(bottom: STANDARD_PADDING)),
          _imageCarouselBuilder(controller.itemToDisplay, screenHeight),
          const Padding(padding: EdgeInsets.only(bottom: STANDARD_PADDING)),
          // _itemNameTextBuilder("NAME OF ITEM"),
          _displayNamePriceCategoryCondition(),
          _displayDescription(ItemField.description.string),
          Padding(padding: EdgeInsets.only(bottom: STANDARD_PADDING * 2)),
          _messageUserButton(context),
          Padding(
              padding: EdgeInsets.only(
                  bottom: STANDARD_PADDING *
                      5)), // allows the user to scroll without the message button extending below the page
        ]),
      ),
    );
  }

  Widget _displayNamePriceCategoryCondition() {
    return Padding(
      padding: EdgeInsets.only(left: STANDARD_PADDING, right: STANDARD_PADDING),
      child: ListTile(
        title: Text(
          controller.itemToDisplay!.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("\$${controller.itemToDisplay!.price}"),
            Text(controller.itemToDisplay!.category.string),
            Text(controller.itemToDisplay!.condition.string),
            // Add more Text widgets for additional subtitles as needed
          ],
        ),
      ),
    );
  }

  Widget _displayDescription(String itemField) {
    return Padding(
      padding: EdgeInsets.only(left: STANDARD_PADDING, right: STANDARD_PADDING),
      child: ListTile(
        title: Text(
          itemField,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "${controller.itemToDisplay!.description}",
          // controller.itemToDisplay!.
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  Widget _messageUserButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
            STANDARD_RADIUS / 1.5), // Adjust the border radius as needed
        color: Colors.blue.withOpacity(0.7), // Set the background color
      ),
      child: controller.pageViewType == PageViewType.public
          ? TextButton(
              onPressed: () {
                // Future<String> user = getCurrentUserInfo();
                // TODO: check to make sure a user can't message themself. Potentially create the DisplayName field?
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      receiverUserEmail: controller.email, // data['email'],
                      receiverDisplayName:
                          controller.username, // data['username'],
                      receiverUserID: controller.uid, // data['uid'],
                    ),
                  ),
                );
              },
              child: Text(
                "Message @${controller.username}",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold // Set the text color
                    ),
              ),
            )
          : null,
    );
  }

  Widget _buildTopRow(BuildContext context, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(padding: EdgeInsets.only(left: STANDARD_PADDING)),
        Container(
          // padding: EdgeInsets.only(left: STANDARD_PADDING),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 0.1)),
          child: controller.profilePictureUrl != ''
              ? CircleAvatar(
                  // Your user profile picture goes here
                  backgroundImage: NetworkImage(controller.profilePictureUrl),
                  radius: screenWidth / 12,
                )
              : const Icon(Icons.person, size: 50, color: Colors.white),
        ),
        Padding(padding: EdgeInsets.all(STANDARD_PADDING / 2)),
        // GestureDetector(
        //     child: Text(
        //       controller.username,
        //       style: const TextStyle(
        //         color: Colors.black,
        //         fontSize: 20.0,
        //         fontWeight: FontWeight.bold,
        //       ),
        //     ),
        //     onTap: () {
        //       if (controller.pageViewType == PageViewType.public) {
        //         GetArguments getArgs = GetArguments();
        //         getArgs.pageViewType = PageViewType.public;
        //         getArgs.username = controller.username;
        //         getArgs.profilePictureUrl = controller.profilePictureUrl;
        //         getArgs.uid = controller.uid;
        //         Get.toNamed(AppRoutes.profilePage, arguments: getArgs);
        //       }
        //     }),
        Text(
          controller.username,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),

        const Spacer(),
        Padding(
            padding: const EdgeInsets.only(right: STANDARD_PADDING),
            child: IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {
                // TODO: add slide up panel here?
                showSlideUpWindow(context, screenWidth);
              },
            ))
      ],
    );
  }

  void showSlideUpWindow(BuildContext context, double screenWidth) {
    // showModalBottomSheet(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return Container(
    //         child: controller.pageViewType == PageViewType.personal
    //             ? _showPersonalSlideUpOptions(context, screenWidth)
    //             : publicSlideUpOptions(screenWidth),
    //       );
    //     });
    controller.pageViewType == PageViewType.personal
        ? _showPersonalSlideUpOptions(context, screenWidth)
        : publicSlideUpOptions(screenWidth);
  }

  void _showPersonalSlideUpOptions(BuildContext context, double screenWidth) {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
              cancelButton: CupertinoActionSheetAction(
                  child: Text("cancel", style: TextStyle(color: Colors.red)),
                  onPressed: () => Get.back()),
              actions: [
                CupertinoActionSheetAction(
                    child: const Row(children: [
                      Icon(Icons.archive),
                      Text(' archive', style: TextStyle(color: Colors.black)),
                    ]),
                    onPressed: () {
                      // archivePost();
                      Get.back();
                    }),
                CupertinoActionSheetAction(
                    child: const Row(children: [
                      Icon(Icons.delete),
                      Text(' delete', style: TextStyle(color: Colors.red)),
                    ]),
                    onPressed: () {
                      // deletePost();
                      print(controller.itemToDisplay?.name);
                      FirebaseFirestore.instance
                          .collection('selling_items')
                          .where('uid', isEqualTo: controller.uid)
                          .where('name',
                              isEqualTo: controller.itemToDisplay?.name)
                          .get()
                          .then((QuerySnapshot querySnapshot) {
                        querySnapshot.docs.forEach((doc) {
                          doc.reference.delete();
                          print('Document ${doc.id} successfully deleted!');
                        });
                      }).catchError((error) =>
                              print("Failed to delete item: $error"));

                      GetArguments getArgs = GetArguments();
                      Get.toNamed(AppRoutes.profilePage, arguments: getArgs);
                    }),
              ]);
        });
  }

  void deleteItem() {
    // return
  }

  Widget publicSlideUpOptions(double screenWidth) {
    return Wrap(children: [
      ListTile(
          leading: const Icon(Icons.report),
          title: const Text('Report', style: TextStyle(color: Colors.red)),
          onTap: () {
            // reportPost()
          }),
      ListTile(
          leading: const Icon(Icons.share),
          title: const Text('Share', style: TextStyle(color: Colors.black)),
          onTap: () {
            // share()
          }),
      SizedBox(height: STANDARD_PADDING, width: screenWidth),
    ]);
  }

  Widget _imageCarouselBuilder(final dynamic thisItem, double screenHeight) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: thisItem.images.length,
          itemBuilder: (BuildContext context, int index, int realIndex) {
            return _buildImageCarouselContainer(index, thisItem);
          },
          options: CarouselOptions(
            height: screenHeight / 2.5,
            aspectRatio: 16 / 9,
            viewportFraction: 1,
            initialPage: 0,
            enableInfiniteScroll: false,
            reverse: false,
            autoPlay: false,
            enlargeCenterPage: true,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              controller.currentIndex.value = index;
              // print(controller.currentIndex);
            },
          ),
        ),
        // if (thisItem["images"].length > 1)
        if (thisItem.images.length > 1)
          Obx(
            () => DotsIndicator(
              dotsCount: thisItem.images.length,
              position: controller.currentIndex.value,
              decorator: const DotsDecorator(
                color: Colors.grey, // Inactive dot color
                activeColor: Colors.blue, // Active dot color
                spacing: EdgeInsets.all(3.0),
                size: Size(8.0, 8.0),
                activeSize: Size(10.0, 10.0),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageCarouselContainer(int index, Item item) {
    return Container(
      width: double.infinity,
      // margin: EdgeInsets.symmetric(horizontal: STANDARD_PADDING / 4),
      // decoration: BoxDecoration(
      //   // borderRadius: BorderRadius.circular(STANDARD_RADIUS / 2),
      //   border: Border.all(
      //     // color: Colors.black,
      //     width: 0.5,
      //   ),
      // ),
      child: ClipRRect(
        // borderRadius: BorderRadius.circular(STANDARD_RADIUS),
        child: Image.network(
          // "${thisItem["images"][index]}", // DO NOT CHANGE// DO NOT CHANGE
          "${item.images[index]}", // I changed it you pussy riley
          fit: BoxFit.cover, // Adjust the fit property as needed
        ),
      ),
    );
  }
}
