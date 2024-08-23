// import 'dart:io';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../constants.dart';
// import '../../model/item.dart';
// import '../../routes.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:dots_indicator/dots_indicator.dart';

// class NewPostPageController extends GetxController {
//   var notSelectedPic = true.obs;
//   String imageURL = ''.obs.value;
//   RxList<String> imageURLs = <String>[].obs;
//   RxList<XFile> xFileImages = <XFile>[].obs;
//   var uploadedImages = <XFile>[].obs;
//   var hasUploadedImages = false.obs;
//   // List<String> conditions = ['Very Used', 'Semi-Used', 'Like New', 'Brand New'];
//   String itemCondition = ''.obs.value;
//   RxInt selectedCategoryIndex = (-1).obs;
//   late RxInt currentIndex = 0.obs;

//   @override
//   void onInit() {
//     super.onInit();
//   }
// }

// class NewPostPageBinding implements Bindings {
//   @override
//   void dependencies() {
//     Get.put<NewPostPageController>(NewPostPageController());
//   }
// }

// class NewPostPage extends GetView<NewPostPageController> {
//   const NewPostPage({Key? key}) : super(key: key);
//   final String pageTitle = 'The Market';

//   @override
//   Widget build(BuildContext context) {
//     // String imageURL = '';
//     TextEditingController _priceTextController = TextEditingController();
//     TextEditingController _descriptionTextController = TextEditingController();
//     RxString selectedCategory = DISPLAYED_ITEM_CATEGORY_STRINGS[11]
//         .obs; // Initialize this variable to miscellaneous
//     User? user = FirebaseAuth.instance.currentUser;
//     String userId = user?.uid ?? '';

//     double screenHeight = MediaQuery.of(context).size.height;
//     double screenWidth = MediaQuery.of(context).size.width;

//     FixedExtentScrollController scrollController =
//         FixedExtentScrollController(initialItem: 0);

//     CupertinoPicker cupertinoPicker = CupertinoPicker.builder(
//       scrollController: scrollController,
//       itemExtent: 50.0,
//       onSelectedItemChanged: (int index) {
//         selectedCategory.value = DISPLAYED_ITEM_CATEGORY_STRINGS[index];
//         // print(selectedCategory);
//       },
//       childCount: DISPLAYED_ITEM_CATEGORY_STRINGS.length,
//       itemBuilder: (BuildContext context, int index) {
//         return Center(
//           child: Text(
//             DISPLAYED_ITEM_CATEGORY_STRINGS[index],
//             style: TextStyle(fontSize: 18.0), // Adjust font size as needed
//           ),
//         );
//       },
//     );

//     return Scaffold(
//       appBar: _newPostPageAppBar(context, _priceTextController,
//           _descriptionTextController, userId, selectedCategory),
//       body: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Column(
//               children: [
//                 SizedBox(height: STANDARD_PADDING),
//                 Obx(
//                   () => Center(
//                     //child: controller.uploadedImages.isEmpty
//                     child: !controller.hasUploadedImages.value
//                         ? _emptyCarouselBuilder()
//                         : _imageCarouselBuilder(screenHeight),
//                   ),
//                 ),
//                 SizedBox(height: STANDARD_PADDING * 2),
//                 _buildCategoryCarousel(screenWidth),
//                 SizedBox(height: STANDARD_PADDING * 1.5),
//                 _userTextBox("Price", _priceTextController, screenWidth),
//                 SizedBox(
//                     height: screenHeight *
//                         0.01), // space between the "Search" and the search bar
//                 _userTextBox(
//                     "Description", _descriptionTextController, screenWidth),
//                 SizedBox(
//                   height: screenHeight * 0.01,
//                 ), // space between the "Description" field and the dropdown
//                 // _categorySelector(screenHeight, cupertinoPicker),
//                 _categorySelectorButton(screenWidth),
//                 Padding(
//                     padding: EdgeInsets.only(
//                         bottom: STANDARD_PADDING *
//                             4)), // add space at bottom to allow the scroll
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _categorySelectorButton(double screenWidth) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
//       child: TextButton(
//         onPressed: () {
//           // Handle button press
//         },
//         style: ButtonStyle(
//           shape: MaterialStateProperty.all(
//             RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(STANDARD_RADIUS / 5),
//               side: BorderSide(
//                 color:
//                     Colors.black, // Set the same border color as the text box
//                 width: 1.0, // Set the same border width as the text box
//               ),
//             ),
//           ),
//         ),
//         child: Text('Select Item Category'),
//       ),
//     );
//   }

//   PreferredSizeWidget _newPostPageAppBar(
//       BuildContext context,
//       TextEditingController _priceTextController,
//       TextEditingController _descriptionTextController,
//       String userId,
//       RxString selectedCategory) {
//     return AppBar(
//         // title: const Text("New Post"),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios),
//           color: Colors.black,
//           onPressed: () {
//             // Get.offAndToNamed(AppRoutes.profilePage);
//             // TODO: also need a dialog warning in case changes were made
//             GetArguments getArgs = GetArguments();
//             getArgs.pageViewType = PageViewType.personal;
//             Get.offAndToNamed(AppRoutes.profilePage, arguments: getArgs);
//           },
//         ),
//         actions: [
//           _postItemButton(context, _priceTextController,
//               _descriptionTextController, userId, selectedCategory)
//         ]);
//   }

//   Widget _categorySelector(
//       double screenHeight, CupertinoPicker cupertinoPicker) {
//     return Padding(
//       padding: EdgeInsets.all(screenHeight * 0.02),
//       child: SizedBox(
//         height: screenHeight * 0.2, // Adjust the height to show more items
//         child: cupertinoPicker,
//       ),
//     );
//   }

//   Widget _postItemButton(
//       BuildContext context,
//       TextEditingController _priceTextController,
//       TextEditingController _descriptionTextController,
//       String userId,
//       RxString selectedCategory) {
//     return Padding(
//       padding: const EdgeInsets.all(10.0),
//       child: TextButton.icon(
//           icon: Icon(Icons.add, color: Colors.blue),
//           onPressed: () async {
//             if (!controller.hasUploadedImages.value) {
//               ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                 content: Text("Please upload an image"),
//                 backgroundColor: Colors.blue,
//                 duration: Duration(seconds: 1),
//               ));
//               return;
//             }

//             String cur_Url = '';
//             for (XFile image in controller.uploadedImages) {
//               try {
//                 // create unique name for the image
//                 String uniqueName =
//                     DateTime.now().millisecondsSinceEpoch.toString();

//                 // Upload to Firebase Storage
//                 Reference referenceRoot = FirebaseStorage.instance.ref();
//                 Reference referenceDirImages = referenceRoot.child("images");
//                 Reference referenceImageToUpload =
//                     referenceDirImages.child(uniqueName);

//                 // store the file using the unique name generated
//                 await referenceImageToUpload.putFile(File(image.path));
//                 // success: get the download URL
//                 cur_Url = await referenceImageToUpload.getDownloadURL();
//                 controller.imageURLs.add(cur_Url);
//               } catch (error) {
//                 // TODO: handle this
//                 throw Exception('Error: $error');
//               }
//             }
//             // controller.imageURL = controller.imageURLs[0];

//             // TODO: add in checking to make sure the price, condition, and description are filled
//             Map<String, dynamic> data = {
//               "images": controller.imageURLs,
//               "price": _priceTextController.text,
//               "condition": controller.itemCondition,
//               "description": _descriptionTextController.text,
//               "uid": userId,
//               "category": selectedCategory.value
//             };
//             FirebaseFirestore.instance.collection("selling_items").add(data);

//             GetArguments getArgs = GetArguments();
//             getArgs.pageViewType = PageViewType.personal;
//             Get.offAndToNamed(AppRoutes.profilePage, arguments: getArgs);
//           },
//           label: Text(
//             "Post Item",
//             style: TextStyle(
//               color: Colors.blue, // Text color
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           style: ButtonStyle(
//             // backgroundColor:
//             //     MaterialStateProperty.all<Color>(Colors.blue),
//             minimumSize: MaterialStateProperty.all<Size>(
//               Size(10, 10),
//             ),
//             shape: MaterialStateProperty.all<OutlinedBorder>(
//               RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(5.0),
//               ),
//             ),
//           )),
//     );
//   }

//   Widget _userTextBox(String textBoxName, TextEditingController controller,
//       double screenWidth) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
//       child: TextField(
//         decoration: InputDecoration(
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(STANDARD_RADIUS / 5),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderSide: BorderSide(
//               color: Colors.black, // Set the desired border color
//               width: 1.0, // Set the desired border width
//             ),
//           ),
//           hintText: textBoxName,
//         ),
//         maxLines: textBoxName == "Price" ? null : 4,
//         controller: controller,
//       ),
//     );
//   }

//   Widget _buildCategoryCarousel(double screenWidth) {
//     return Container(
//       height: 35.0,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
//         width: double.infinity,
//         child: ListView(
//           scrollDirection: Axis.horizontal,
//           children: [
//             _buildCategoryContainer(0),
//             SizedBox(width: STANDARD_PADDING / 2),
//             _buildCategoryContainer(1),
//             SizedBox(width: STANDARD_PADDING / 2),
//             _buildCategoryContainer(2),
//             SizedBox(width: STANDARD_PADDING / 2),
//             _buildCategoryContainer(3),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoryContainer(int index) {
//     return Obx(
//       () => TextButton(
//         onPressed: () {
//           _updateButtonColors(index);
//           // controller.itemCondition = controller.conditions[index];
//           controller.itemCondition = ITEM_CONDITIONS[index];
//         },
//         style: TextButton.styleFrom(
//           backgroundColor: index == controller.selectedCategoryIndex.value
//               ? Colors.grey[300]
//               : Colors.blue,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(STANDARD_RADIUS / 2),
//           ),
//         ),
//         child: Text(
//           // controller.conditions[index],
//           ITEM_CONDITIONS[index],
//           style: index != controller.selectedCategoryIndex.value
//               ? TextStyle(
//                   color: Colors.white,
//                 )
//               : TextStyle(color: Colors.black),
//         ),
//       ),
//     );
//   }

//   void _updateButtonColors(int categoryIndex) {
//     // Set the previously selected button back to blue
//     if (controller.selectedCategoryIndex != -1) {
//       controller.selectedCategoryIndex.value = -1;
//     }

//     // Set the pressed button to white
//     controller.selectedCategoryIndex.value = categoryIndex;
//   }

//   // this is the thing that shows before you add any photos
//   Widget _emptyCarouselBuilder() {
//     return CarouselSlider.builder(
//       itemCount: 1,
//       itemBuilder: (BuildContext context, int index, int realIndex) {
//         return _buildEmptyCarousel(context);
//       },
//       options: CarouselOptions(
//         height: 250.0,
//         aspectRatio: 16 / 9,
//         viewportFraction: 0.8,
//         initialPage: 0,
//         enableInfiniteScroll: false,
//         reverse: false,
//         autoPlay: false,
//         autoPlayInterval: Duration(seconds: 3),
//         autoPlayAnimationDuration: Duration(milliseconds: 800),
//         autoPlayCurve: Curves.fastOutSlowIn,
//         enlargeCenterPage: true,
//         onPageChanged: (index, reason) {
//           // Callback function for when the page changes
//         },
//         scrollDirection: Axis.horizontal,
//       ),
//     );
//   }

//   Widget _buildEmptyCarousel(BuildContext context) {
//     return Container(
//       width: 250.0,
//       // height: 350.0,
//       decoration: BoxDecoration(
//         border: Border.all(
//           color: Colors.black, // You can set the border color
//           width: 1, // You can set the border width
//         ),
//         borderRadius: BorderRadius.circular(
//             STANDARD_PADDING), // You can adjust the border radius
//       ),
//       alignment: Alignment.center,
//       child: ElevatedButton(
//         onPressed: () async {
//           List<XFile>? selectedImages = await ImagePicker().pickMultiImage();

//           if (selectedImages.length > 4) {
//             selectedImages.clear();
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(
//                   'Please select up to 4 images',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 backgroundColor: Colors.red,
//               ),
//             );
//             return;
//           }

//           if (selectedImages != null && selectedImages.isNotEmpty) {
//             controller.uploadedImages = RxList<XFile>.from(selectedImages);
//             controller.hasUploadedImages.value = true;
//           }
//         },
//         child: Text('Add Photos', style: TextStyle(color: Colors.blue)),
//       ),
//     );
//   }

//   Widget _imageCarouselBuilder(double screenHeight) {
//     return Column(
//       children: [
//         CarouselSlider.builder(
//           itemCount: controller.uploadedImages.length,
//           itemBuilder: (BuildContext context, int index, int realIndex) {
//             return _buildImageCarouselContainer(index);
//           },
//           options: CarouselOptions(
//             height: 250.0,
//             // aspectRatio: 16 / 9,
//             viewportFraction: 0.75,
//             initialPage: 0,
//             enableInfiniteScroll: false,
//             reverse: false,
//             autoPlay: false,
//             enlargeCenterPage: true,
//             scrollDirection: Axis.horizontal,
//             onPageChanged: (index, reason) {
//               controller.currentIndex.value = index;
//               // print(controller.currentIndex);
//             },
//           ),
//         ),
//         if (controller.uploadedImages.length > 1)
//           Obx(
//             () => DotsIndicator(
//               dotsCount: controller.uploadedImages.length,
//               position: controller.currentIndex.value,
//               decorator: DotsDecorator(
//                 color: Colors.grey, // Inactive dot color
//                 activeColor: Colors.blue, // Active dot color
//                 spacing: EdgeInsets.all(3.0),
//                 size: const Size(8.0, 8.0),
//                 activeSize: const Size(10.0, 10.0),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildImageCarouselContainer(int index) {
//     return Container(
//       width: double.infinity,
//       // decoration: BoxDecoration(
//       //   border: Border.all(
//       //     color: Colors.black,
//       //     width: 0.5,
//       //   ),
//       // ),
//       child: ClipRRect(
//         child: Image.file(
//           File(controller.uploadedImages[index].path),
//           fit: BoxFit.cover,
//         ),
//       ),
//     );
//   }
// }
