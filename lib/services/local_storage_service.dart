import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static final LocalStorageService _i = LocalStorageService();

  static LocalStorageService get i => _i;

  late final Future<SharedPreferences> _pref = SharedPreferences.getInstance();

  Future<void> setValueOnStorage(String key, String storeValue) async {
    SharedPreferences value = await _pref;
    value.setString(key, storeValue);
  }

  Future<String> getStorageValue(String key) async {
    SharedPreferences value = await _pref;

    if (value.containsKey(key)) {
      String data = value.getString(key)!;
      return data;
    }
    return '';
  }

  Future<void> removeToken(String key) async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove(key);
  }
}
