import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants.dart';
import '../../model/item.dart';
import '../../routes.dart';
import 'profilePage.dart';

class NewPostPageController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Item item = Item();
  String name = '';
  // late ItemCategory category;
  Rx<ItemCategory> category = ItemCategory.miscellaneous.obs;
  // late ItemCondition condition;
  Rx<ItemCondition> condition = ItemCondition.brandNew.obs;
  String description = '';
  List<dynamic> itemImages = [];
  int price = 0;
  late String uid;

  // List of local files that point to images
  var localImages = <File>[].obs;
  var hasSelectedName = false.obs;
  var hasSelectedImages = false.obs;
  var hasSelectedCategory = false.obs;
  var hasSelectedCondition = false.obs;
  bool hasSelectedPrice = false;
  bool hasSelectedDescription = false;

  TextEditingController nameTC = TextEditingController();
  TextEditingController descriptionTC = TextEditingController();
  TextEditingController priceTC = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    uid = auth.currentUser!.uid;
  }

  bool isReadyToPost() {
    return hasSelectedPrice &&
        hasSelectedCategory.value &&
        hasSelectedCondition.value &&
        hasSelectedImages.value &&
        hasSelectedName.value &&
        hasSelectedDescription;
  }
}

class NewPostPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<NewPostPageController>(NewPostPageController());
  }
}

class NewPostPage extends GetView<NewPostPageController> {
  const NewPostPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // GetArguments getArgs = Get.arguments ?? GetArguments();
    // controller.uid = getArgs.uid ?? '';

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: _newPostAppBar(),
        body: SingleChildScrollView(
            child: Column(children: [
          _selectImagesBody(context, screenWidth, screenHeight),
          const Padding(
              padding: EdgeInsets.symmetric(vertical: STANDARD_PADDING)),
          Container(height: 1, width: screenWidth, color: Colors.grey),
          // name text box
          _itemFieldTextEntry(
              controller.nameTC, ItemField.name.string, 1, ItemField.name),
          Container(height: 1, width: screenWidth, color: Colors.grey),
          // description text box
          _itemFieldTextEntry(controller.descriptionTC,
              ItemField.description.string, 3, ItemField.description),
          Container(height: 1, width: screenWidth, color: Colors.grey),
          // category selection
          _itemCategorySelection(context),
          Container(height: 1, width: screenWidth, color: Colors.grey),
          // condition selection
          _itemConditionSelection(context),
          Container(height: 1, width: screenWidth, color: Colors.grey),
          // price selection
          _itemPriceSelection(context),
        ])));
  }

  Widget _itemFieldTextEntry(TextEditingController tc, String hintText,
      int maxLines, ItemField field) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextField(
          controller: tc,
          maxLines: maxLines,
          decoration:
              InputDecoration(hintText: hintText, border: InputBorder.none),
          onChanged: (value) {
            if (value.isEmpty) {
              if (field == ItemField.name) {
                controller.hasSelectedName.value = false;
              } else {
                controller.hasSelectedDescription = false;
              }
            } else {
              if (field == ItemField.name) {
                controller.hasSelectedName.value = true;
              } else {
                controller.hasSelectedDescription = true;
              }
            }
            field == ItemField.name
                ? controller.name = value
                : controller.description = value;
          },
        ));
  }

  bool _isNumeric(String str) {
    // This pattern matches any string that consists only of digits
    final RegExp numericRegExp = RegExp(r'^\d+$');
    return numericRegExp.hasMatch(str);
  }

  Widget _itemPriceSelection(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: GestureDetector(
            child: Column(children: [
              // Row(children: [
              //   TextButton(
              //     child: Text("Cancel"),
              //     onPressed: () {},
              //   ),
              //   TextButton(
              //     child: Text("Done"),
              //     onPressed: () {},
              //   )
              // ]),
              TextField(
                  controller: controller.priceTC,
                  textInputAction: TextInputAction.done,
                  // onSubmitted: (value) {
                  //   FocusScope.of(context).unfocus();
                  // },
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                  maxLines: 1,
                  decoration: InputDecoration(
                      hintText: ItemField.price.string,
                      border: InputBorder.none,
                      prefixText: "\$"),
                  onChanged: (value) {
                    // do i do anything here?
                    if (value.isEmpty) {
                      controller.hasSelectedPrice = false;
                    } else {
                      controller.hasSelectedPrice = true;
                      controller.price = int.parse(value);
                      // print(value);
                      // if (_isNumeric(value)) {
                      //   controller.price = int.parse(value);
                      // } else {
                      //   controller.priceTC.text = '';
                      // }
                    }
                  })
            ]),
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            }));
  }

  Widget _itemCategorySelection(BuildContext context) {
    return TextButton(
        child: Container(
            // padding: const EdgeInsets.only(left: 0),
            width: double.infinity, // makes button whole row
            child: Obx(() => !controller.hasSelectedCategory.value
                ? Row(children: [
                    const Icon(Icons.category_outlined, color: Colors.black),
                    Text(" select ${ItemField.category.string}",
                        style: const TextStyle(color: Colors.black))
                  ])
                : Text(
                    " ${CATEGORY_ENUM_TO_DISPLAYED[controller.category.value]!}",
                    style: const TextStyle(color: Colors.black)))),
        onPressed: () {
          // do some shit
          _showCategorySlideUpWindow(context);
        });
  }

  Widget _itemConditionSelection(BuildContext context) {
    return TextButton(
        child: Container(
            // padding: const EdgeInsets.only(left: 0),
            width: double.infinity, // makes button whole row
            child: Obx(() => !controller.hasSelectedCondition.value
                ? Row(children: [
                    const Icon(Icons.folder_zip_outlined, color: Colors.black),
                    Text(" select ${ItemField.condition.string}",
                        style: const TextStyle(color: Colors.black))
                  ])
                : Text(
                    " ${CONDITION_ENUM_TO_DISPLAYED[controller.condition.value]!}",
                    style: const TextStyle(color: Colors.black)))),
        onPressed: () {
          // do some shit
          _showConditionSlideUpWindow(context);
        });
  }

  void _showCategorySlideUpWindow(BuildContext context) {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text(FIELD_ENUM_TO_DISPLAYED[ItemField.category]!),
            cancelButton: CupertinoActionSheetAction(
              child: Text("cancel", style: TextStyle(color: Colors.black)),
              onPressed: () {
                Get.back();
              },
            ),
            actions: CATEGORY_DISPLAYED
                .map((category) => CupertinoActionSheetAction(
                    child:
                        Text(category, style: TextStyle(color: Colors.black)),
                    onPressed: () {
                      controller.category.value =
                          CATEGORY_DISPLAYED_TO_ENUM[category]!;
                      controller.hasSelectedCategory.value = true;
                      Get.back();
                    }))
                .toList(),
          );
        });
  }

  void _showConditionSlideUpWindow(BuildContext context) {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text(FIELD_ENUM_TO_DISPLAYED[ItemField.condition]!),
            cancelButton: CupertinoActionSheetAction(
              child: Text("cancel", style: TextStyle(color: Colors.black)),
              onPressed: () {
                Get.back();
              },
            ),
            actions: CONDITION_DISPLAYED
                .map((condition) => CupertinoActionSheetAction(
                    child:
                        Text(condition, style: TextStyle(color: Colors.black)),
                    onPressed: () {
                      controller.condition.value =
                          CONDITION_DISPLAYED_TO_ENUM[condition]!;
                      controller.hasSelectedCondition.value = true;
                      Get.back();
                    }))
                .toList(),
          );
        });
  }

  AppBar _newPostAppBar() {
    return AppBar(
        title: const Text("New Post"),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Get.back();
            }),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: STANDARD_PADDING),
            child: GestureDetector(
                child: Text(
                  "Post",
                  style: TextStyle(
                      // color: controller.hasSelectedImages.value
                      color: controller.isReadyToPost()
                          ? Colors.blue
                          : Colors.grey),
                ),
                onTap: () async {
                  // check all required values are present:
                  if (controller.isReadyToPost()) {
                    print("ready to post");
                    // CollectionReference users = FirebaseFirestore.instance
                    //     .collection(FirebaseCollections.users.string);
                    for (File image in controller.localImages) {
                      try {
                        String uniqueName =
                            DateTime.now().microsecondsSinceEpoch.toString();
                        Reference referenceRoot =
                            FirebaseStorage.instance.ref();
                        Reference referenceDirImages =
                            referenceRoot.child("images");
                        Reference referenceImageToUpload =
                            referenceDirImages.child(uniqueName);
                        await referenceImageToUpload.putFile(image);
                        String imageUrl =
                            await referenceImageToUpload.getDownloadURL();
                        controller.itemImages.add(imageUrl);
                      } catch (e) {
                        throw Exception("Error: $e");
                      }
                    }

                    Item item = Item(
                        name: controller.name,
                        category: controller.category.value,
                        condition: controller.condition.value,
                        description: controller.description,
                        images: controller.itemImages,
                        price: controller.price,
                        uid: controller.uid);

                    Map<String, dynamic> itemAsMap = item.toMap();

                    // then post image
                    await FirebaseFirestore.instance
                        .collection(FirebaseCollections.selling_items.string)
                        .add(itemAsMap);
                    /* Ensure profile page reloads on the get.back() */
                    // ProfilePageController ppController = Get.find();
                    // ppController.hasUserData = false;
                    // Get.back();

                    GetArguments getArgs = GetArguments();
                    Get.toNamed(AppRoutes.profilePage, arguments: getArgs);
                  }
                }),
          )
        ]);
  }

  Widget _selectImagesBody(
      BuildContext context, double screenWidth, double screenHeight) {
    return Obx(() => !controller.hasSelectedImages.value
        ? SizedBox(
            height: screenWidth * 2 / 3,
            child: Center(child: _selectImagesButton(context)))
        : _displayImages(context, screenWidth, screenHeight));
  }

  Widget _selectImagesButton(BuildContext context) {
    return Container(
      // height: screenWidth * 2 / 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
            STANDARD_RADIUS / 1.5), // Adjust the border radius as needed
        color: Colors.blue.withOpacity(0.7), // Set the background color
      ),
      child: TextButton(
        onPressed: () async {
          List<XFile>? selectedImages = await ImagePicker().pickMultiImage();
          if (selectedImages.length > MAX_IMAGES_PER_ITEM) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    "You selected ${selectedImages.length} images, please only $MAX_IMAGES_PER_ITEM",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                backgroundColor: Colors.red,
              ),
            );
            selectedImages.clear();
            return;
          }
          if (selectedImages.isNotEmpty) {
            for (var image in selectedImages) {
              controller.localImages.add(File(image.path));
            }
            // controller.localImages = selectedImages;
            controller.hasSelectedImages.value = true;
          }
        },
        child: const Text(
          "add images",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold // Set the text color
              ),
        ),
      ),
    );
  }

  Widget _displayImages(
      BuildContext context, double screenWidth, double screenHeight) {
    double imageWidth = screenWidth * 2 / 3;
    double imageHeight = screenWidth * 2 / 3;
    // double imageHeight = screenHeight;
    return SizedBox(
        height: imageHeight,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.localImages.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // delete or replace image
                // print("image tapped");
                _showEditImageSlideUpWindow(context, index, screenWidth);
              },
              child: // Column(children: [
                  Obx(() => Container(
                      // color: Colors.black,
                      width: imageWidth,
                      height: imageHeight,
                      margin:
                          EdgeInsets.symmetric(horizontal: STANDARD_PADDING),
                      child: Image.file(
                        controller.localImages[index],
                        fit: BoxFit.cover,
                      ))),
              // index < controller.localImages.length - 1
              //     ? Container(height: 3, color: Colors.grey)
              //     : Text('')
            ); // );
          },
        ));
  }

  void _showEditImageSlideUpWindow(
      BuildContext context, int index, double screenWidth) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
              child: Wrap(children: [
            ListTile(
                leading: const Icon(Icons.find_replace),
                title: const Text('Replace'),
                onTap: () async {
                  await _replaceImage(index);
                  Get.back();
                }),
            ListTile(
                leading: const Icon(Icons.remove, color: Colors.red),
                title:
                    const Text('Remove', style: TextStyle(color: Colors.red)),
                onTap: () {
                  _removeImage(index);
                  Get.back();
                }),
            SizedBox(height: STANDARD_PADDING, width: screenWidth)
          ]));
        });
  }

  Future<void> _replaceImage(int index) async {
    XFile? newImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (newImage!.path.isEmpty) {
      return;
    }
    controller.localImages[index] = File(newImage.path);
  }

  void _removeImage(int index) {
    controller.localImages.removeAt(index);
    if (controller.localImages.isEmpty) {
      controller.hasSelectedImages.value = false;
    }
  }
}

class NewPostConfigurePage extends GetView<NewPostPageController> {
  const NewPostConfigurePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
