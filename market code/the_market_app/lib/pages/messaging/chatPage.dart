import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_market_app/components/chatBubble.dart';
import 'package:the_market_app/constants.dart';
import 'package:the_market_app/services/chat/chatServices.dart';
import 'package:the_market_app/widgets.dart';
import 'package:get/get.dart';
import 'package:the_market_app/routes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverDisplayName;
  final String receiverUserID;

  const ChatPage({
    super.key,
    required this.receiverUserEmail,
    required this.receiverDisplayName,
    required this.receiverUserID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();

  void sendMessage() async {
    // send message if not empty
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverUserID, _messageController.text);
      // clear the controller after sendin message
      _messageController.clear();
    }
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.receiverUserID)
        .get();

    Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>?;
    String fcmToken = userData!['fcmToken'];

    _sendPushNotification(fcmToken);
    // String receiverFCMToken =
  }

  void _sendPushNotification(String fcmToken) {
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverDisplayName),
        leading: IconButton(
          color: Colors.black,
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            // Get.toNamed(AppRoutes.homePage);
            Get.back();
          },
        ),
      ),
      body: Column(
        children: [
          // messages
          Expanded(
            child: _buildMessageList(),
          ),

          // user input
          _buildMessageInput(),
        ],
      ),
    );
  }

  // build message list
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
          widget.receiverUserID, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        // Scroll to the bottom whenever new messages arrive
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        });

        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs
              .map<Widget>((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  // build message item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    DateTime dateTime = data['timestamp'].toDate();
    // final DateTime timestamp = data['timestamp'];
    String formattedTimestamp = DateFormat('h:mm a MM/dd/yy').format(dateTime);

    // align the messages to the right if sender, left if receiver
    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    Color messageColor = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Colors.lightBlue
        : Colors.grey.shade300;

    Color textColor = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Colors.white
        : Colors.black;

    return Container(
        alignment: alignment,
        child: Padding(
          padding: EdgeInsets.all(STANDARD_PADDING / 2),
          child: Column(
            crossAxisAlignment:
                (data['senderId'] == _firebaseAuth.currentUser!.uid)
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
            mainAxisAlignment:
                (data['senderId'] == _firebaseAuth.currentUser!.uid)
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
            children: [
              // Text(data['senderEmail']),
              // const SizedBox(height: 5),
              ChatBubble(
                message: data['message'],
                messColor: messageColor,
                texColor: textColor,
              ),
              // const SizedBox(height: 5),
              Text(formattedTimestamp,
                  style: const TextStyle(
                    fontSize: 10,
                  ))
            ],
          ),
        ));
  }

  // build message input
  Widget _buildMessageInput() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(
            bottom: STANDARD_PADDING + 2), // Adjust the value as needed
        child: Row(
          children: [
            // textfield
            Padding(padding: EdgeInsets.all(STANDARD_PADDING)),
            Expanded(
              child: TextField(
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Enter message',
                ),
                controller: _messageController,
                obscureText: false,
              ),
            ),
            IconButton(
              onPressed: sendMessage,
              icon: const Icon(
                Icons.arrow_upward,
                size: 40, // we might want to make this dependent on screen size
              ),
            )
          ],
        ),
      ),
    );
  }
}
