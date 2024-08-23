import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PrivacyPolicyPageController extends GetxController {
  @override
  void onInit() {
    super.onInit();
  }
}

class PrivacyPolicyPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<PrivacyPolicyPageController>(PrivacyPolicyPageController());
  }
}

class PrivacyPolicyPage extends GetView<PrivacyPolicyPageController> {
  const PrivacyPolicyPage({Key? key}) : super(key: key);
  final String pageTitle = 'Privacy Policy';

  Future<String> _loadText() async {
    // Load your text file
    // Replace 'assets/privacy_policy.txt' with your actual text file path
    final String text =
        await rootBundle.loadString('assets/privacy_policy.txt');
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Privacy Policy",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<String>(
          future: _loadText(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  snapshot.data!,
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
