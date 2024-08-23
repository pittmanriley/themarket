class Item {
  String name = '';
  ItemCategory category;
  ItemCondition condition;
  String description = '';
  // List<String> images = [];
  List<dynamic> images = [];
  int price = 0;
  String uid = '';

  Item({
    // required this.name,
    this.name = '',
    required this.category,
    required this.condition,
    required this.description,
    required this.images,
    required this.price,
    required this.uid,
  });
  // Item.blank();

  void printItem() {
    print("Name: $name");
    print("Category: ${category.string}");
    print("Condition: ${condition.string}");
    print("Description: $description");
    print("Image1: ${images[0]}");
    print("Price: $price");
    print("uid: $uid");
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> retMap = {
      ItemField.name.string: name,
      ItemField.category.string: category.string,
      ItemField.condition.string: condition.string,
      ItemField.description.string: description,
      ItemField.images.string: images,
      ItemField.price.string: price,
      ItemField.uid.string: uid
    };

    return retMap;
  }

  // TODO: need to/from JSON functions for storage???
  // This should be in firebase eventually, once we set that up
}

// ############################################################################################################################

List<String> ITEM_FIELD_DISPLAY = [
  "Name",
  "Category",
  "Condition",
  "Description",
  "Images",
  "Price",
  "UID"
];

/* Describes the Item Fields that each item has in Firebase. 
   WARNING: the enums match exactly with Firebase. Changing the names of 
   the enumerated values will cause errors. */
enum ItemField { name, category, condition, description, images, price, uid }

/* Item Field Extension */
extension ItemFieldExtension on ItemField {
  /* returns the name of the enum as a string */
  String get string {
    return toString().split('.')[1];
  }

  /* Given a string, returns the enum */
  static ItemField fromString(String str) {
    return ItemField.values.firstWhere((e) => e.string == str, orElse: () {
      throw ArgumentError('No matching FirebaseItemFields for string $str');
    });
  }
}

Map<ItemField, String> FIELD_ENUM_TO_DISPLAYED = {
  ItemField.condition: "Condition",
  ItemField.category: "Category",
};

// ############################################################################################################################

/* Each item in firebase will have one of these enums as a string in
   their category field. WARNING: the enums match exactly with the 
   category of the item. Changing the names of the enumerated values
   will cause errors */
enum ItemCategory {
  bikes,
  electronics,
  clothes,
  freeItems,
  furniture,
  artsAndCrafts,
  books,
  homeDecor,
  fashion,
  beauty,
  appliances,
  miscellaneous
}

/* List the displayed item categories. WARNING: do not change the order 
   of the strings. Doing so will result in changing search parameters */
const List<String> CATEGORY_DISPLAYED = [
  "Bikes",
  "Electronics",
  "Clothes",
  "Free Items",
  "Furniture",
  "Arts & Crafts",
  "Books",
  "Home Decor",
  "Fashion",
  "Beauty",
  "Appliances",
  "Miscellaneous"
];
/* Lists the paths of the images of the item categories. 
   WARNING: do not change the order of the strings. Doing 
   so will result in changing search parameters */
List<String> ITEM_CATEGORY_IMAGES = [
  'assets/images/bikes.png',
  'assets/images/electronics.png',
  'assets/images/clothes.png',
  'assets/images/free.png',
  'assets/images/furniture.png',
  'assets/images/arts_crafts.png',
  'assets/images/books.png',
  'assets/images/home_decor.png',
  'assets/images/fashion.png',
  'assets/images/beauty.png',
  'assets/images/appliances.png',
  'assets/images/miscellaneous.png',
];

Map<String, ItemCategory> CATEGORY_DISPLAYED_TO_ENUM = {
  "Bikes": ItemCategory.bikes,
  "Electronics": ItemCategory.electronics,
  "Clothes": ItemCategory.clothes,
  "Free Items": ItemCategory.freeItems,
  "Furniture": ItemCategory.furniture,
  "Arts & Crafts": ItemCategory.artsAndCrafts,
  "Books": ItemCategory.books,
  "Home Decor": ItemCategory.homeDecor,
  "Fashion": ItemCategory.fashion,
  "Beauty": ItemCategory.beauty,
  "Appliances": ItemCategory.appliances,
  "Miscellaneous": ItemCategory.miscellaneous
};

Map<ItemCategory, String> CATEGORY_ENUM_TO_DISPLAYED = {
  ItemCategory.bikes: "Bikes",
  ItemCategory.electronics: "Electronics",
  ItemCategory.clothes: "Clothes",
  ItemCategory.freeItems: "Free Items",
  ItemCategory.furniture: "Furniture",
  ItemCategory.artsAndCrafts: "Arts & Crafts",
  ItemCategory.books: "Books",
  ItemCategory.homeDecor: "Home Decor",
  ItemCategory.fashion: "Fashion",
  ItemCategory.beauty: "Beauty",
  ItemCategory.appliances: "Appliances",
  ItemCategory.miscellaneous: "Miscellaneous",
};

extension ItemCategoryExtension on ItemCategory {
  /* Given an enum, returns its string */
  String get string {
    return toString().split('.')[1];
  }

  static ItemCategory fromString(String str) {
    return ItemCategory.values.firstWhere((e) => e.string == str, orElse: () {
      throw ArgumentError('No matching Item Category for string $str');
    });
  }
}

// ############################################################################################################################

enum ItemCondition { veryUsed, semiUsed, likeNew, brandNew }

List<String> CONDITION_DISPLAYED = [
  'Brand New',
  'Like New',
  'Semi-Used',
  'Very Used'
];

extension ItemConditionExtension on ItemCondition {
  String get string {
    return toString().split('.')[1];
  }

  static ItemCondition fromString(String str) {
    return ItemCondition.values.firstWhere((e) => e.string == str, orElse: () {
      throw ArgumentError('No matching Item Condition for string $str');
    });
  }
}

Map<String, ItemCondition> CONDITION_DISPLAYED_TO_ENUM = {
  'Very Used': ItemCondition.veryUsed,
  'Semi-Used': ItemCondition.semiUsed,
  'Like New': ItemCondition.likeNew,
  'Brand New': ItemCondition.brandNew
};
Map<ItemCondition, String> CONDITION_ENUM_TO_DISPLAYED = {
  ItemCondition.veryUsed: 'Very Used',
  ItemCondition.semiUsed: 'Semi-Used',
  ItemCondition.likeNew: 'Like New',
  ItemCondition.brandNew: 'Brand New'
};
