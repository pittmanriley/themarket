import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class TermsOfServicePageController extends GetxController {
  @override
  void onInit() {
    super.onInit();
  }
}

class TermsOfServicePageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<TermsOfServicePageController>(TermsOfServicePageController());
  }
}

class TermsOfServicePage extends GetView<TermsOfServicePageController> {
  const TermsOfServicePage({Key? key}) : super(key: key);
  // final String pageTitle = 'Terms of Service';

  Future<String> _loadText() async {
    // Load your text file
    final String text =
        await rootBundle.loadString('assets/terms_of_service.txt');
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
          'Terms of Service',
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
