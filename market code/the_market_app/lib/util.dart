/*
util.dart

Defines all the global functions for the app
*/

import 'model/item.dart';

import 'dart:math'; // used for random value generation
// Utility Functions

// TEST: this creates x number of random ITEM variables for testing purposes only

String getRandomIntString(int length) {
  return List.generate(length, (index) => Random().nextInt(10).toString())
      .join('');
}

/*
List<Item> getNItemList(int n) {
  int strLen = 10;
  List<Item> retList = [];
  for (int i = 1; i < n + 1; i++) {
    // String name = getRandomIntString(strLen);
    String name = i.toString();
    String image = getRandomIntString(strLen);
    String notes = getRandomIntString(strLen);
    Item item = Item(name: name, images: image, notes: notes);
    retList.add(item);
  }
  return retList;
}
*/
