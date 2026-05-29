import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class HotKeyService {
  static final _hotkeyStreamController = StreamController<bool>.broadcast();

  static Stream<bool> get hotkeyStream => _hotkeyStreamController.stream;

  static Future<void> registerHotkey() async {
    try {
      await hotKeyManager.unregisterAll();
      final hotkey = HotKey(
        key: LogicalKeyboardKey.keyX,
        modifiers: [HotKeyModifier.alt],
        scope: HotKeyScope.system,
      );
      await hotKeyManager.register(
        hotkey,
        keyDownHandler: (_) => _hotkeyStreamController.add(true),
      );
    } catch (e) {
      print('Error registering hotkey: $e');
    }
  }

  static void dispose() {
    _hotkeyStreamController.close();
  }
}
