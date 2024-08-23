import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportUserPageController extends GetxController {
  late TextEditingController usernameController;
  late TextEditingController explanationController;
  @override
  void onInit() {
    super.onInit();
    usernameController = TextEditingController();
    explanationController = TextEditingController();
  }
}

class ReportUserPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ReportUserPageController>(ReportUserPageController());
  }
}

class ReportUserPage extends GetView<ReportUserPageController> {
  const ReportUserPage({Key? key}) : super(key: key);
  final String pageTitle = 'Search';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Report User",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            GetArguments getArgs = GetArguments();
            Get.toNamed(AppRoutes.settingsPage, arguments: getArgs);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller.usernameController,
              decoration: InputDecoration(labelText: 'Username to report'),
              maxLines: 1,
            ),
            SizedBox(height: STANDARD_PADDING),
            TextField(
              controller: controller.explanationController,
              decoration: InputDecoration(labelText: 'Reason for reporting'),
              maxLines: 3,
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                // Implement your submission logic here
                Map<String, dynamic> data = {
                  "username": controller.usernameController.text,
                  "explanation": controller.explanationController.text,
                };
                if (data["username"] != '' && data["explanation"] != '') {
                  FirebaseFirestore.instance.collection("reports").add(data);
                }
                // Reset text field controllers
                controller.usernameController.clear();
                controller.explanationController.clear();
                Get.back();
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
