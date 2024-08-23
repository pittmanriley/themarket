/* Direct Messages Page
 * Name: messagesPage.dart
 * Page that allows users to communicate with other users
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_market_app/pages/messaging/chatPage.dart';
import 'package:the_market_app/pages/homePage.dart';
import 'package:the_market_app/routes.dart';
import 'package:the_market_app/widgets.dart';

final String uid = FirebaseAuth.instance.currentUser!.uid;

class MessagesPageController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // populate item list
  }
  // some functions for the variables for data manipulation
}

class MessagesPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<HomePageController>(HomePageController());
  }
}

class MessagesPage extends GetView<MessagesPageController> {
  const MessagesPage({Key? key}) : super(key: key);
  final String pageTitle = 'Messages';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: messagesAppBar(pageTitle),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('error'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text('loading...'));
          }

          // Pass the snapshot to _buildUserList
          return _buildUserList(snapshot.data!);
        },
      ),
    );
  }

  Future<List<String>> getUserChatUIDs() async {
    CollectionReference usersChat = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('user_chat_rooms');

    QuerySnapshot chatSnapshot = await usersChat.get();
    List<String> userChatUIDs = chatSnapshot.docs.map((doc) => doc.id).toList();

    return userChatUIDs;
  }

  // build a list of users except for the current logged in user
  Widget _buildUserList(QuerySnapshot snapshot) {
    return FutureBuilder<List<String>>(
      future: getUserChatUIDs(),
      builder: (context, userChatSnapshot) {
        if (userChatSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text('loading...'));
        }

        if (userChatSnapshot.hasError) {
          return Center(child: Text('error'));
        }

        List<String> userChatUIDs = userChatSnapshot.data!;

        // Extract the documents from the snapshot
        final List<DocumentSnapshot> documents = snapshot.docs;

        // Filter documents based on whether the user's UID is in the userChatUIDs list
        List<DocumentSnapshot> filteredDocuments = documents
            .where((doc) => userChatUIDs.contains(doc['uid']))
            .toList();

        return ListView.builder(
          itemCount: filteredDocuments.length,
          itemBuilder: (context, index) {
            // Add a Divider between items, except for the last item
            return Column(
              children: [
                _buildUserListItem(filteredDocuments[index], context),
                if (index < filteredDocuments.length - 1)
                  const Divider(
                    height: 2,
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document, BuildContext context) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    // display all but current user
    if (FirebaseAuth.instance.currentUser!.email != data['email']) {
      return ListTile(
          title: Text(data['username']),
          onTap: () {
            // pass the clicked users UID to the chat page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  receiverUserEmail: data['email'],
                  receiverDisplayName: data['username'],
                  receiverUserID: data['uid'],
                ),
              ),
            );
          });
    } else {
      return Container();
    }
  }

  PreferredSizeWidget messagesAppBar(String title) {
    // TODO: wrap AppBar in preferedSize widget to change the size?
    return AppBar(
      centerTitle: true,
      leading: IconButton(
        color: Colors.black,
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () {
          // Get.toNamed(AppRoutes.homePage);
          Get.back();
        },
      ),
      title: Text(
        title,
        style: TextStyle(
            color: Colors.black,
            fontSize: 27.0,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0),
      ),
      backgroundColor: const Color.fromARGB(237, 255, 255, 255),
      elevation: 0.1,
    );
  }
}
