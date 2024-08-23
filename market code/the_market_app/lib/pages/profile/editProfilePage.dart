/*
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:the_market_app/constants.dart';
import 'package:the_market_app/pages/profile/formatters/maxLengthInLineFormatter.dart';
import 'package:the_market_app/pages/profile/formatters/maxLinesFormatter.dart';
import 'package:the_market_app/pages/profile/profilePage.dart';
import 'package:the_market_app/routes.dart';

// defines the maximum number of characters in the bio text field
const _maxCharactersInBio = 40;

// want edit profile page to be a subclass of profile page so we dont need to reload the data
class EditProfilePageController extends GetxController {
  // ProfilePageController profController = Get.find();

  late GetArguments getArgs;

  // is set to true if anything is modified
  var modifiedAny = false.obs;
  var modifiedProfilePicture = false.obs;
  bool modifiedBio = false;

  // late String profilePicture;
  late XFile tempProfilePicture;
  late String username;
  TextEditingController bioTextEditingController = TextEditingController();

  // data received from profilePage
  late String profilePictureUrl;
  late String bio;
  late String uid;

  // late Map<String, String?> getParams;

  @override
  void onInit() {
    // bioTextEditingController.text = Get.parameters['bio'] ?? '';
    // this is required to be here because otherwise bio errors arise
    bioTextEditingController.text = Get.arguments.bio ?? '';
    super.onInit();
  }
}

class EditProfilePageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<EditProfilePageController>(EditProfilePageController());
  }
}

@Deprecated("Removed social media feature. To be removed soon.")
class EditProfilePage extends GetView<EditProfilePageController> {
// class EditProfilePage extends StatelessWidget {
  EditProfilePage({Key? key}) : super(key: key);

  final FocusNode bioTextFieldFocusNode = FocusNode();

  // TextEditingController bioTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final double profilePictureRadius = screenWidth / 9;

    controller.getArgs = Get.arguments;
    controller.bio = controller.getArgs.bio ?? '';
    controller.profilePictureUrl = controller.getArgs.profilePictureUrl ?? '';
    controller.uid = controller.getArgs.uid ?? '';

    return Scaffold(
        appBar: _editProfileAppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: STANDARD_PADDING,
            ),
            Row(children: [
              GestureDetector(
                  onTap: () async {
                    // Handle the button click here, for example, navigate to a new page
                    // print("Button clicked");
                    await _selectTempProfilePicture();
                  },
                  child: _displaySelectedProfilePicture(profilePictureRadius)),
              Padding(
                  padding: EdgeInsets.only(left: STANDARD_PADDING),
                  child: const Text('tap picture to change',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold)))
            ]),
            Padding(
                padding: EdgeInsets.only(
                    left: STANDARD_PADDING * 2, top: STANDARD_PADDING * 2),
                child: const Text('bio',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold))),
            Padding(
                padding: EdgeInsets.only(left: STANDARD_PADDING * 2),
                child: const Text('a quick description about your shop!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ))),
            _bioTextField(),
          ],
        ));
  }

  Widget _bioTextField() {
    // controller.bioTextEditingController.text = controller.bio;
    // puts cursor at the end of the line when tapped
    return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: STANDARD_PADDING * 2, vertical: STANDARD_PADDING / 2),
        child: Container(
            padding: EdgeInsets.only(left: STANDARD_PADDING / 2),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1.0),
              borderRadius: BorderRadius.circular(STANDARD_PADDING),
            ),
            child: TextField(
              maxLength: _maxCharactersInBio,
              maxLines: 1,
              // keyboardType: TextInputType.text,
              style: const TextStyle(fontSize: 13),
              // focusNode: bioTextFieldFocusNode,
              controller: controller.bioTextEditingController,
              onChanged: (value) {
                controller.modifiedAny.value = true;
                controller.modifiedBio = true;
              },
              // onEditingComplete: () {},
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                border: InputBorder.none,
                hintText: 'enter your bio...',
              ),
            )));
  }

  // Sets temporary profile picture before user clicks submit
  Future<void> _selectTempProfilePicture() async {
    try {
      // final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      final XFile? image =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) {
        return;
      }
      controller.tempProfilePicture = image;
      controller.modifiedProfilePicture.value = true;
      controller.modifiedAny.value = true;
    } on PlatformException catch (e) {
      print('failed to pick image: $e');
    }
  }

  // returns the proper displayed image regarding the user's current image status
  Widget _displaySelectedProfilePicture(double profilePictureRadius) {
    // ProfilePageController profController = Get.find();
    EditProfilePageController controller = Get.find();

    bool hasProfilePicture = controller.profilePictureUrl != '' ? true : false;

    return Padding(
      padding: EdgeInsets.only(left: STANDARD_PADDING),
      child: CircleAvatar(
        backgroundColor: Colors.blue,
        radius: profilePictureRadius,
        child: ClipOval(
          child: SizedBox(
            width: profilePictureRadius * 2,
            height: profilePictureRadius * 2,
            child: Obx(
              () => controller.modifiedProfilePicture.value
                  ? Image.file(
                      File(controller.tempProfilePicture.path),
                      fit: BoxFit.cover,
                    )
                  : hasProfilePicture
                      ? Image.network(
                          controller.profilePictureUrl,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

Future<bool> _exitWithoutSavingDialog() async {
  bool retVal = false;

  await Get.dialog(
      CupertinoAlertDialog(title: Text('exit without saving?'), actions: [
    CupertinoDialogAction(
        child: Text('cancel'),
        onPressed: () {
          retVal = false;
          navigateBack();
        }),
    CupertinoDialogAction(
        child: Text('confirm'),
        onPressed: () {
          retVal = true;
          navigateBack();
        })
  ]));
  return retVal;
}

void navigateBack() {
  GetArguments getArgs = GetArguments();
  getArgs.pageViewType = PageViewType.personal;
  Get.offAndToNamed(AppRoutes.profilePage, arguments: getArgs);
}

PreferredSizeWidget _editProfileAppBar() {
  EditProfilePageController controller = Get.find();
  return AppBar(
      automaticallyImplyLeading: true, // adds back arrow
      centerTitle: false,
      leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
          onPressed: () {
            if (controller.modifiedAny.value) {
              _exitWithoutSavingDialog().then((value) {
                if (value) {
                  navigateBack();
                }
              });
            } else {
              navigateBack();
            }
          }),
      title: const Text(
        'edit your profile',
        style: TextStyle(
            color: Colors.black,
            fontSize: 20.0,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0),
      ),
      backgroundColor: const Color.fromARGB(237, 255, 255, 255),
      elevation: 0.1,
      actions: <Widget>[
        Padding(
            padding: EdgeInsets.only(right: STANDARD_PADDING * 2),
            child: Obx(() => Visibility(
                visible: controller.modifiedAny.value,
                child: TextButton(
                  child: const Text('save'),
                  onPressed: () async {
                    /*
                    await _getChangedValuesAsParams().then((params) =>
                        Get.offAndToNamed(AppRoutes.profilePage,
                            parameters: params));
                    */
                    await _getGetArguments().then((getArgs) {
                      Get.offAndToNamed(AppRoutes.profilePage,
                          arguments: getArgs);
                    });
                  },
                ))))
      ]);
}

// called by the save button, returns the parameters to be used in routing
// Future<Map<String, String>> _getChangedValuesAsParams() async {
Future<GetArguments> _getGetArguments() async {
  EditProfilePageController controller = Get.find();

  // Map<String, String> backParams = {};
  GetArguments getArgs = GetArguments();
  // because coming from editProfilePage
  getArgs.pageViewType = PageViewType.personal;

  if (controller.modifiedProfilePicture.value) {
    // backParams['profilePictureUrl'] = await _uploadAndGetProfilePictureUrl();
    getArgs.profilePictureUrl = await _uploadAndGetProfilePictureUrl();
  }
  // backParams['bio'] = await _uploadAndSaveBio();
  if (controller.modifiedBio) {
    // backParams['bio'] = controller.bioTextEditingController.text;
    // print('edit page, ${controller.bio}');
    // backParams['bio'] = controller.bioTextEditingController.text;
    getArgs.bio = controller.bioTextEditingController.text;
  }

  // return backParams;
  return getArgs;
}

// uploads new prof pic to firebase and returns profile picture url
Future<String> _uploadAndGetProfilePictureUrl() async {
  // ProfilePageController profController = Get.find();
  EditProfilePageController controller = Get.find();

  // creates image filename if not present
  String filename = 'profile_picture_of_${controller.uid}';
  // Upload to Firebase Storage
  Reference referenceRoot = FirebaseStorage.instance.ref();
  Reference referenceDirImages = referenceRoot.child("images");
  Reference referenceImageToUpload = referenceDirImages.child(filename);

  late String profilePictureUrl;
  try {
    // upload to firestore
    await referenceImageToUpload
        .putFile(File(controller.tempProfilePicture.path));
    // success: get the download URL
    profilePictureUrl = await referenceImageToUpload.getDownloadURL();
  } catch (e) {
    print('Error uploading $e');
  }
  return profilePictureUrl;
}
*/
