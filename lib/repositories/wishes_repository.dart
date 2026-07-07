import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wish_model.dart';

class WishesRepository {
  static const _key = 'wishes_data';
  static const _categoriesKey = 'wish_categories';
  static const defaultCategories = ['旅行', '美食', '体验', '购物', '学习'];

  Future<List<WishModel>> loadWishes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => WishModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveWishes(List<WishModel> wishes) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(wishes.map((e) => e.toJson()).toList());
    await prefs.setString(_key, raw);
  }

  Future<List<String>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_categoriesKey);
    return raw ?? defaultCategories;
  }

  Future<void> saveCategories(List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_categoriesKey, categories);
  }
}
