import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_market_app/model/message.dart';
import 'package:intl/intl.dart';

class ChatService extends ChangeNotifier {
  // get instance of auth and firestore
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  // send message
  Future<void> sendMessage(String receiverId, String message) async {
    // get current user information
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final String currentUserDisplayName =
        _firebaseAuth.currentUser!.displayName.toString();
    final DateTime timestamp = DateTime.now();

    // create a new message
    Message newMessage = Message(
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        senderDisplayName: currentUserDisplayName,
        receiverId: receiverId,
        timestamp: timestamp,
        message: message);

    // construct a chat room id from curr user id and reciever user id
    List<String> ids = [currentUserId, receiverId];
    ids.sort(); // sort to make sure chat room id is same for both people (CJRiley same as RileyCJ)
    String chatRoomId = ids.join("_");

    // add new message to database
    await _firebaseFirestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());

    await _firebaseFirestore
        .collection('users')
        .doc(currentUserId)
        .collection('user_chat_rooms')
        .doc(receiverId)
        .set({'receiverId': receiverId});
    await _firebaseFirestore
        .collection('users')
        .doc(receiverId)
        .collection('user_chat_rooms')
        .doc(currentUserId)
        .set({'receiverId': currentUserId});
  }

  // receive message
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    // construct chat room from user ids
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firebaseFirestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
