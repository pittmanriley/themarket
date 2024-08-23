import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderEmail;
  final String senderDisplayName;
  final String receiverId;
  final String message;
  final DateTime timestamp;

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.senderDisplayName,
    required this.receiverId,
    required this.timestamp,
    required this.message,
  });

  // convert to map
  Map<String, dynamic> toMap() {
    return {
      'senderId' : senderId,
      'senderEmail' : senderEmail,
      'senderDisplayName' : senderDisplayName,
      'receiverId' : receiverId,
      'message' : message,
      'timestamp' : timestamp,
    };
  }
}