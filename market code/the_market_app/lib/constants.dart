/*
constants.dart

README!

This file defines constants to be used across the entire application. For constants referenced 
in only one file, please define them in the file they are referenced.

DEVELOPERS: 
Constant Creation: 
  When adding a new constant to this file, ensure that it is named well or commented
  thoroughly. The reader must understand where and how it is used.
  All constants will be in CAPITAL_SNAKE_CASE


Constant Editing: 
  Often, during development, you may need to change some constants' value. Ensure that
  in your branch, when you change the constants' value, you save the original value clearly commented. That
  way, when merge conflicts occur, which they will, we will have a much easier time debugging. 

*/
import 'package:firebase_auth/firebase_auth.dart';
import 'package:the_market_app/model/item.dart';

const double STANDARD_PADDING = 16.0;
const double STANDARD_RADIUS = 20.0;
const double STANDARD_ELEVATION = 1.0;
const double DESCRIPTION_FONT_SIZE = 12.0;
const double TITLE_FONT_SIZE = 28.0;

const int MAX_ALGOLIA_ATTEMPTS = 3;

const int MAX_IMAGES_PER_ITEM = 4;

/* the names of the collections we have in firebase */
enum FirebaseCollections { selling_items, users, chat_rooms, reports }

extension FirebaseCollectionsExtension on FirebaseCollections {
  String get string {
    return toString().split('.')[1];
  }
}

enum UserCollectionFields {
  email,
  items,
  profilePicture,
  uid,
  username,
}

extension UserCollectionFieldsExtension on UserCollectionFields {
  String get string {
    return toString().split('.')[1];
  }
}

// to differentiate between the different views of pages
enum PageViewType { personal, public }

class GetArguments {
  PageViewType? pageViewType;
  // dynamic data; // nullable by default
  String? uid;
  String? profilePictureUrl;
  String? email;
  String? username;
  Item? item;

  GetArguments();
}
