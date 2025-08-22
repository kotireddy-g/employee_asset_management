import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static late Box _box;

  static Future<void> init() async {
    _box = await Hive.openBox('app_storage');
  }

  static Future<void> setString(String key, String value) async {
    await _box.put(key, value);
  }

  static String? getString(String key) {
    return _box.get(key);
  }

  static Future<void> setBool(String key, bool value) async {
    await _box.put(key, value);
  }

  static bool? getBool(String key) {
    return _box.get(key);
  }

  static Future<void> setInt(String key, int value) async {
    await _box.put(key, value);
  }

  static int? getInt(String key) {
    return _box.get(key);
  }

  static Future<void> remove(String key) async {
    await _box.delete(key);
  }

  static Future<void> clear() async {
    await _box.clear();
  }
}