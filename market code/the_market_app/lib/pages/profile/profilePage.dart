import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_market_app/widgets.dart';

import '../../constants.dart';
import '../../model/item.dart';
import '../../routes.dart';
import '../../model/algolia.dart';

///////////////////////////////////////// LOCAL CONSTANTS/WIDGETS /////////////////////////////////////////

///////////////////////////////////////// CONTROLLER/BINDING/UI /////////////////////////////////////////
class ProfilePageController extends GetxController {
  late SharedPreferences prefs;

  bool hasUserData = false;
  late GetArguments getArgs;
  late PageViewType pageViewType;

  final FirebaseAuth auth = FirebaseAuth.instance;
  late CollectionReference sellingItems;
  // late Algolia algolia;
  Algolia algolia = Algolia.init();

  // List<Map<String, dynamic>> itemsForSale = [];
  List<Item> itemsForSale = [];
  late Map<String, dynamic> userData;
  late CollectionReference users;
  late String uid;
  late String username;
  RxString profilePictureUrl = ''.obs;

  @override
  void onInit() async {
    super.onInit();
    uid = auth.currentUser!.uid;
  }

  // retrieves the users' items
  Future<void> fetchUserItems() async {
    try {
      String query = uid;
      dynamic body = await algolia.query("selling_items_index", query);
      itemsForSale = algolia.getItemList(body, true, uid);
      // itemsForSale = algolia.getItemList(body, true, uid);
      // for (Item item in items) {
      //   item.printItem();
      // }
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }
}

class ProfilePageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ProfilePageController>(ProfilePageController());
  }
}

class ProfilePage extends GetView<ProfilePageController> {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final double profilePictureRadius = screenWidth / 7;

    /* Checking if the controller has user data saves the API from being 
       being called unecessarily if the page is already loaded in. There
       is a possibility for error, though, if the page gets updated in some
       way (ex: post gets deleted). In this case, the app would have to be
       refreshed in order for PROFILEPAGE to show the necessary updates. */
    if (controller.hasUserData) {
      return _profilePageScaffold(
          profilePictureRadius, screenWidth, screenHeight);
    } else {
      controller.getArgs = Get.arguments;
      controller.pageViewType =
          controller.getArgs.pageViewType ?? PageViewType.public;

      controller.users = FirebaseFirestore.instance
          .collection(FirebaseCollections.users.string);
      controller.sellingItems = FirebaseFirestore.instance
          .collection(FirebaseCollections.selling_items.string);
      return FutureBuilder(
          future: Future.wait([
            controller.users.doc(controller.uid).get(),
            controller.fetchUserItems(),
          ]),
          // TODO: change this to work with the new https get request
          builder:
              // (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('');
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else if (snapshot.hasData) {
              var userSnapshot = snapshot.data![0] as DocumentSnapshot;
              _configControllerData(userSnapshot, controller.uid);
              // controller.hasUserData = true;
              return _profilePageScaffold(
                  profilePictureRadius, screenWidth, screenHeight);
            } else {
              return const Text('no data available');
            }
            // return Center(child: CircularProgressIndicator());
          });
    }
  }

  // sets up the data for the controller in order for it to be displayed
  void _configControllerData(DocumentSnapshot snapshot, String uid) {
    controller.userData = snapshot.data() as Map<String, dynamic>;
    // get username
    controller.username =
        controller.userData[UserCollectionFields.username.string];

    if (!controller.userData.keys
        .contains(UserCollectionFields.profilePicture.string)) {
      // create profile picture space in firebase
      controller.users
          .doc(uid)
          .update({UserCollectionFields.profilePicture.string: ''});
      controller.userData[UserCollectionFields.profilePicture.string] = '';
    }
    // print(controller.userData[UserCollectionFields.profilePicture.name]);
    controller.profilePictureUrl.value =
        controller.userData[UserCollectionFields.profilePicture.string];

    if (!controller.userData.keys.contains(UserCollectionFields.items.string)) {
      // creates item space in firebase
      controller.users.doc(uid).update({UserCollectionFields.items.string: []});
      controller.userData[UserCollectionFields.items.string] = [];
    }
    // controller.itemIds = controller.userData[UserCollectionFields.items.name];
  }

  // returns the scaffold do be displayed in the future builder
  Widget _profilePageScaffold(
      double profilePictureRadius, double screenWidth, double screenHeight) {
    // ProfilePageController controller = Get.find();
    return Scaffold(
      appBar: _profileAppBar(controller.username, profilePictureRadius),
      body: _itemsForSaleDisplay(screenWidth, screenHeight),
      floatingActionButton: _newItemButton(),
      bottomSheet: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey, height: 1.0)),
      bottomNavigationBar: bottomNavigationBar(AppRoutes.profilePage),
    );
  }

  FloatingActionButton _newItemButton() {
    return FloatingActionButton(
      onPressed: () {
        GetArguments getArgs = GetArguments();
        getArgs.uid = controller.uid;
        Get.toNamed(AppRoutes.newPostPage, arguments: getArgs);
      },
      child: Icon(Icons.add),
      backgroundColor: Colors.blue,
    );
  }

  GetArguments toItemPageGetArgs(Item itemToDisplay) {
    GetArguments getArgs = GetArguments();
    getArgs.email = controller.userData[UserCollectionFields.email.string];
    getArgs.item = itemToDisplay;
    getArgs.uid = controller.uid;
    getArgs.username = controller.username;
    getArgs.profilePictureUrl = controller.profilePictureUrl.value;
    getArgs.pageViewType = controller.pageViewType;
    return getArgs;
  }

  Widget _itemsForSaleDisplay(double screenWidth, double screenHeight) {
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 3 items per row
          crossAxisSpacing: STANDARD_PADDING, //
          mainAxisSpacing: STANDARD_PADDING,
          childAspectRatio: screenWidth / (screenHeight / 2),
          mainAxisExtent: screenWidth / 2,
        ),
        padding: const EdgeInsets.only(
          left: STANDARD_PADDING,
          right: STANDARD_PADDING,
          bottom: STANDARD_PADDING,
          top: STANDARD_PADDING,
        ),
        itemCount: controller.itemsForSale.length,
        itemBuilder: (BuildContext context, int index) {
          Item itemToDisplay = controller.itemsForSale[index];
          GetArguments getArgs = toItemPageGetArgs(itemToDisplay);
          return controller.itemsForSale.isNotEmpty
              ? buildGridItemBoxes(
                  getArgs, index, screenWidth, screenHeight, context)
              : const Center(child: Text("no posts yet!"));
        });
  }

  // returns profile picture
  Widget _profilePicture(double profilePictureRadius) {
    return GestureDetector(
      onTap: () async {
        await _updateProfilePicture();
      },
      child: _displayProfilePicture(profilePictureRadius),
    );
  }

  // returns the proper displayed image regarding the user's current image status
  Widget _displayProfilePicture(double profilePictureRadius) {
    return Container(
      child: Obx(() => controller.profilePictureUrl.value != ''
          ? CircleAvatar(
              backgroundImage: NetworkImage(controller.profilePictureUrl.value),
              radius: profilePictureRadius,
            )
          : CircleAvatar(
              radius: profilePictureRadius,
              child: const Icon(Icons.person, size: 30, color: Colors.white),
            )),
    );
  }

  // Sets new profile picutre url
  Future<void> _updateProfilePicture() async {
    try {
      // final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      final XFile? image =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) {
        return;
      }

      // upload image to firestore
      String filename = 'profile_picture_of_${controller.username}';
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImages = referenceRoot.child("images");
      Reference referenceImageToUpload = referenceDirImages.child(filename);
      await referenceImageToUpload.putFile(File(image.path));

      // get image url and upload firebase user's profilePicture field
      controller.profilePictureUrl.value =
          await referenceImageToUpload.getDownloadURL();
      controller.users
          .doc(controller.uid)
          .update({'profilePicture': controller.profilePictureUrl.value});

      // update local data
      controller.userData['profilePicture'] =
          controller.profilePictureUrl.value;
    } on PlatformException catch (e) {
      print('failed to update image: $e');
    }
  }

  PreferredSizeWidget _profileAppBar(
      String username, double profilePictureRadius) {
    return AppBar(
        automaticallyImplyLeading: false, // removes back arrow
        centerTitle: false,
        leading: Padding(
            padding: EdgeInsets.only(left: STANDARD_PADDING),
            child: _profilePicture(profilePictureRadius)),
        // leading: null,
        title: Text(
          // TODO: figure out how to insert the proper username
          username,
          style: const TextStyle(
              color: Colors.black,
              fontSize: 27.0,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0),
        ),
        backgroundColor: const Color.fromARGB(237, 255, 255, 255),
        elevation: 0.1,
        actions: <Widget>[
          // Settings Button
          IconButton(
              icon: const Icon(Icons.settings),
              color: Colors.black,
              onPressed: () {
                // TODO: this is temporary. Will become messagesPage
                Get.toNamed(AppRoutes.settingsPage);
              })
        ],
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Container(color: Colors.grey, height: 1.0)));
  }
}
