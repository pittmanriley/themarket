import 'package:shared_preferences/shared_preferences.dart';

// TODO: THESE ARE JUST FOR REFERENCE!! DELETE DURING PRODUCTION!!
// apiKey: "9ec3581e13124af61d546a05e5569aec");
// applicationId: "CE11YKVOFD",

const _algoliaApplicationIdKey = 'aaidk';
const _algoliaAPIKeyKey = 'aapikk';

const _seenMessageKey = 'smk';

class AppPrefs {
  static late SharedPreferences? _prefs;

  static init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String get algoliaApplicationId =>
      _prefs?.getString(_algoliaApplicationIdKey) ?? '';
  static set algoliaApplicationId(String algoliaApplicationId) {
    _prefs?.setString(_algoliaApplicationIdKey, algoliaApplicationId);
  }

  static String get algoliaAPIKey => _prefs?.getString(_algoliaAPIKeyKey) ?? '';
  static set algoliaAPIKey(String algoliaAPIKey) {
    _prefs?.setString(_algoliaAPIKeyKey, algoliaAPIKey);
  }
}
