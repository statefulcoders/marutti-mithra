import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class AssetsUtils {
  static Future<Map<String, dynamic>> loadJson(String path) async {
    try {
      final String jsonString = await rootBundle.loadString(path);
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      return jsonData;
    } catch (e) {
      
      return {};
    }
  }

  static Future<List<dynamic>> loadJsonList(String path) async {
    try {
      final String jsonString = await rootBundle.loadString(path);
      final List<dynamic> jsonData = jsonDecode(jsonString);
      return jsonData;
    } catch (e) {
      
      return [];
    }
  }

  static Future<String> loadText(String path) async {
    try {
      final String str = await rootBundle.loadString(path);
      return str;
    } catch (e) {
      
      return 'Unavailable';
    }
  }

}
