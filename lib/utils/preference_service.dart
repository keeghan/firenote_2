import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _gridViewKey = 'isGridView';
  
  static Future<bool> getIsGridView() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_gridViewKey) ?? true;
  }
  
  static Future<void> setIsGridView(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_gridViewKey, value);
  }
}