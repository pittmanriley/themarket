import 'dart:convert';
import 'item.dart';

import 'package:http/http.dart' as http;

enum AlgoliaIndexes { sellingItemsIndex }

final Map<AlgoliaIndexes, String> ALGOLIA_INDEX_TO_STRING = {
  AlgoliaIndexes.sellingItemsIndex: "selling_items_index",
};

class Algolia {
  // regular constructor
  Algolia.init();

  final String _apiKey = "9ec3581e13124af61d546a05e5569aec";
  final String _applicationId = "CE11YKVOFD";

  Future<dynamic> query(String index, String query) async {
    final headers = {
      'X-Algolia-API-Key': _apiKey,
      'X-Algolia-Application-Id': _applicationId
    };
    final params = {'query': query};
    final url =
        Uri.parse('https://$_applicationId-dsn.algolia.net/1/indexes/$index')
            .replace(queryParameters: params);
    final result = await http.get(url, headers: headers);
    int status = result.statusCode;
    if (status != 200) {
      throw Exception('http.get error: status code: $status');
    }
    // print(result.body);
    final body = json.decode(result.body);
    return body;
  }

  // List<Map<String, dynamic>> getItemsAsMap(dynamic body) {
  //   List<Map<String, dynamic>> data = [];

  //   for (var hit in body["hits"]) {
  //     Map<String, dynamic> curHit = {
  //       "images": hit["images"],
  //       "description": hit["description"],
  //       "price": hit["price"],
  //       "condition": hit["condition"]
  //     };
  //     data.add(curHit);
  //   }
  //   return data;
  // }

  List<Item> getItemList(
      dynamic body, bool gettingPersonalItems, String userUid) {
    List<Item> items = [];

    List<dynamic> hits = body["hits"];
    for (var hit in hits) {
      String uid = hit[ItemField.uid.string];
      if (!gettingPersonalItems && (userUid == uid)) {
        continue;
      }

      String name = hit[ItemField.name.string] ?? '';
      String sCategory = hit[ItemField.category.string];
      ItemCategory category = ItemCategoryExtension.fromString(sCategory);
      String sCondition = hit[ItemField.condition.string];
      ItemCondition condition = ItemConditionExtension.fromString(sCondition);
      String description = hit[ItemField.description.string];
      List<dynamic> images = hit[ItemField.images.string];
      int price = hit[ItemField.price.string];

      Item item = Item(
          name: name,
          category: category,
          condition: condition,
          description: description,
          images: images,
          price: price,
          uid: uid);

      items.add(item);
    }
    return items;
  }
}
