import 'package:shared_preferences/shared_preferences.dart';

class ClickTrackingService {
  static const _prefix = 'click_';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static int getClickCount(String path) =>
      _prefs?.getInt('$_prefix${path.toLowerCase()}') ?? 0;

  static Future<void> recordClick(String path) async {
    await init();
    final key = '$_prefix${path.toLowerCase()}';
    await _prefs!.setInt(key, (_prefs!.getInt(key) ?? 0) + 1);
  }
}
