import 'package:shared_preferences/shared_preferences.dart';
import '../models/portfolio_item.dart';

class PortfolioService {
  static const String _key = 'user_portfolio';
  static final PortfolioService _instance = PortfolioService._internal();

  factory PortfolioService() => _instance;
  PortfolioService._internal();

  Future<List<PortfolioItem>> getItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsStr = prefs.getStringList(_key) ?? [];
    return itemsStr.map((str) => PortfolioItem.fromJson(str)).toList();
  }

  Future<void> addItem(PortfolioItem item) async {
    final currentItems = await getItems();
    currentItems.add(item);
    await _saveItems(currentItems);
  }

  Future<void> removeItem(String id) async {
    final currentItems = await getItems();
    currentItems.removeWhere((i) => i.id == id);
    await _saveItems(currentItems);
  }

  Future<void> _saveItems(List<PortfolioItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final itemsStr = items.map((i) => i.toJson()).toList();
    await prefs.setStringList(_key, itemsStr);
  }
}
