import 'package:cloud_firestore/cloud_firestore.dart';
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

class ChatBubble extends StatelessWidget {
  final String message;
  final Color messColor;
  final Color texColor;
  final int characterLimitPerLine;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  ChatBubble(
      {required this.message,
      required this.messColor,
      required this.texColor,
      this.characterLimitPerLine = 35});

  List<String> splitTextIntoLines(String text) {
    List<String> lines = [];
    List<String> words = text.split(' ');

    String currentLine = '';

    for (String word in words) {
      if ((currentLine + ' ' + word).length <= characterLimitPerLine) {
        currentLine += (currentLine.isEmpty ? '' : ' ') + word;
      } else {
        lines.add(currentLine);
        currentLine = word;
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }

    return lines;
  }

  @override
  Widget build(BuildContext context) {
    List<String> lines = splitTextIntoLines(message);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        color: messColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines
            .map((line) => Text(
                  line,
                  style: TextStyle(fontSize: 16, color: texColor),
                ))
            .toList(),
      ),
    );
  }
}
